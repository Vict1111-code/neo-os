#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QObject>
#include <QSettings>
#include <QStandardPaths>
#include <QDirIterator>
#include <QFileInfo>
#include <QProcess>
#include <QVariantMap>
#include <QDebug>
#include <QIcon>
#include <QQuickImageProvider>
#include <QPixmap>
#include <QHash>
#include <QImageReader>
#include <QImageWriter>
#include <QPainter>
#include <QLinearGradient>
#include <QRadialGradient>
#include <QRandomGenerator>
#include <QTemporaryDir>
#include <QTimer>
#include <QDir>
#include <QFile>
#include <QCryptographicHash>
#include <QUrl>
#include "MatrixPty.h"
#include <algorithm>

class AppIconProvider final : public QQuickImageProvider {
public:
    explicit AppIconProvider(const QHash<QString, QString> *icons)
        : QQuickImageProvider(QQuickImageProvider::Pixmap), icons_(icons) {}

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override {
        const QSize target = requestedSize.isValid() ? requestedSize : QSize(64, 64);
        const QString iconName = icons_->value(id, QStringLiteral("application-x-executable"));
        QIcon icon = QFileInfo(iconName).isAbsolute() ? QIcon(iconName) : QIcon::fromTheme(iconName);
        if (icon.isNull())
            icon = QIcon::fromTheme(QStringLiteral("application-x-executable"));
        QPixmap pixmap = icon.pixmap(target);
        if (size) *size = pixmap.size();
        return pixmap;
    }
private:
    const QHash<QString, QString> *icons_;
};

class DesktopBackend : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList pinnedApps READ pinnedApps NOTIFY pinnedAppsChanged)
    Q_PROPERTY(QVariantList availableApps READ availableApps CONSTANT)
    Q_PROPERTY(QString wallpaperUrl READ wallpaperUrl NOTIFY wallpaperUrlChanged)
    Q_PROPERTY(QVariantList wallpaperThemes READ wallpaperThemes NOTIFY wallpaperThemesChanged)
    Q_PROPERTY(double wallpaperDim READ wallpaperDim NOTIFY wallpaperDimChanged)
    Q_PROPERTY(QString wallpaperError READ wallpaperError NOTIFY wallpaperErrorChanged)
    Q_PROPERTY(QString accentTheme READ accentTheme NOTIFY accentThemeChanged)
public:
    explicit DesktopBackend(QObject *parent = nullptr) : QObject(parent) {
        QStringList dirs = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);
        dirs << "/usr/share/applications" << "/usr/local/share/applications";
        dirs.removeDuplicates();
        for (const auto &directory : dirs) {
            QDirIterator iter(directory, {"*.desktop"}, QDir::Files, QDirIterator::Subdirectories);
            while (iter.hasNext()) {
                const QString path = iter.next();
                QSettings desktop(path, QSettings::IniFormat);
                desktop.beginGroup("Desktop Entry");
                if (desktop.value("Type").toString() != "Application" ||
                    desktop.value("Hidden").toBool() || desktop.value("NoDisplay").toBool()) {
                    desktop.endGroup(); continue;
                }
                const QString id = QFileInfo(path).fileName();
                const QString name = desktop.value("Name").toString().trimmed();
                const QString iconName = desktop.value("Icon").toString().trimmed();
                desktop.endGroup();
                if (id.isEmpty() || name.isEmpty() || appPaths.contains(id)) continue;
                appPaths.insert(id, path); appNames.insert(id, name);
                appIcons.insert(id, iconName.isEmpty() ? QStringLiteral("application-x-executable") : iconName);
            }
        }
        QStringList ids = appPaths.keys();
        std::sort(ids.begin(), ids.end(), [this](const QString &a, const QString &b) {
            return appNames.value(a).localeAwareCompare(appNames.value(b)) < 0;
        });
        for (const auto &id : ids)
            apps.append(QVariantMap{{"id", id}, {"name", appNames.value(id)}});
        QSettings settings("NEO-OS", "DesktopPreview");
        accent_ = settings.value("appearance/accent", "cyan").toString();
        if (accent_ != "cyan" && accent_ != "violet") accent_ = "cyan";
        wallpaperDim_ = qBound(0.0, settings.value("appearance/dim", 0.22).toDouble(), 0.72);
        ensureBuiltInWallpapers();
        refreshWallpapers();
        const QString oldWallpaper = settings.value("appearance/wallpaper").toString();
        if (!oldWallpaper.isEmpty()) {
            const QString local = QUrl(oldWallpaper).toLocalFile();
            if (!local.isEmpty() && QFileInfo(local).isReadable() &&
                QImageReader(local).canRead()) wallpaper_ = oldWallpaper;
        }
        if (wallpaper_.isEmpty() && !themes_.isEmpty())
            wallpaper_ = themes_.first().toMap().value("url").toString();
        const QStringList stored = settings.value("dock/pins").toStringList();
        for (const auto &id : stored)
            if (appPaths.contains(id) && !pins.contains(id)) pins << id;
        if (stored.isEmpty()) {
            for (const auto &id : ids) {
                if (pins.size() == 5) break;
                pins << id;
            }
        }
    }
    QString wallpaperUrl() const { return wallpaper_; }
    QVariantList wallpaperThemes() const { return themes_; }
    Q_INVOKABLE void refreshWallpapers() {
        const QString directory = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
                                  + "/neo-os/wallpapers";
        QDir dir(directory);
        QVariantList found;
        const QFileInfoList images = dir.entryInfoList({"*.webp", "*.png", "*.jpg", "*.jpeg"},
                                      QDir::Files | QDir::Readable | QDir::NoSymLinks, QDir::Name);
        for (const QFileInfo &image : images) {
            if (!QImageReader(image.absoluteFilePath()).canRead()) continue;
            found.append(QVariantMap{{"name", image.completeBaseName().replace('-', ' ')},
                                    {"url", QUrl::fromLocalFile(image.absoluteFilePath()).toString()}});
        }
        if (themes_ != found) {
            themes_ = found;
            emit wallpaperThemesChanged();
        }
    }
    QString wallpaperError() const { return wallpaperError_; }
    void reportWallpaperError(const QString &reason) {
        wallpaperError_ = reason;
        qWarning().noquote() << "NEO wallpaper:" << reason;
        emit wallpaperErrorChanged();
    }
    Q_INVOKABLE bool importWallpaper(const QString &source) {
        reportWallpaperError(QString());
        const QUrl selected(source);
        const QString path = selected.isLocalFile() ? selected.toLocalFile() : source;
        if (selected.scheme() != "" && !selected.isLocalFile()) {
            reportWallpaperError("Choose a local file, not a remote URL.");
            return false;
        }
        QFileInfo info(path);
        if (!info.exists() || !info.isFile() || !info.isReadable()) {
            reportWallpaperError("Selected file is missing or unreadable: " + path);
            return false;
        }
        if (info.size() <= 0 || info.size() > 25LL * 1024 * 1024) {
            reportWallpaperError("Image must be smaller than 25 MiB.");
            return false;
        }
        QImageReader reader(info.absoluteFilePath());
        reader.setAutoTransform(true);
        QImage image = reader.read();
        if (image.isNull()) {
            reportWallpaperError("Qt cannot decode this image: " + reader.errorString()
                              + ". For WebP on Ubuntu, install qt6-image-formats-plugins.");
            return false;
        }
        if (image.width() < 32 || image.height() < 32 ||
            static_cast<qint64>(image.width()) * image.height() > 32000000LL) {
            reportWallpaperError("Unsupported image dimensions.");
            return false;
        }
        const QString directory = wallpaperDirectory();
        if (!QDir().mkpath(directory)) {
            reportWallpaperError("Cannot create wallpaper library: " + directory);
            return false;
        }
        if (image.width() > 3840 || image.height() > 2160)
            image = image.scaled(QSize(3840, 2160), Qt::KeepAspectRatio, Qt::SmoothTransformation);
        QFile original(info.absoluteFilePath());
        if (!original.open(QIODevice::ReadOnly)) {
            reportWallpaperError("Could not read selected image.");
            return false;
        }
        const QByteArray hash = QCryptographicHash::hash(original.readAll(), QCryptographicHash::Sha256).toHex();
        const QString destination = directory + "/custom-" + QString::fromLatin1(hash.left(16)) + ".png";
        if (!QFileInfo::exists(destination) && !image.save(destination, "PNG")) {
            reportWallpaperError("Unable to save imported wallpaper as PNG.");
            return false;
        }
        if (!setWallpaperPath(destination)) {
            reportWallpaperError("Unable to activate imported image.");
            return false;
        }
        refreshWallpapers();
        return true;
    }
    double wallpaperDim() const { return wallpaperDim_; }
    Q_INVOKABLE void setWallpaperDim(double amount) {
        const double safe = qBound(0.0, amount, 0.72);
        if (qFuzzyCompare(wallpaperDim_ + 1.0, safe + 1.0)) return;
        wallpaperDim_ = safe;
        QSettings settings("NEO-OS", "DesktopPreview");
        settings.setValue("appearance/dim", wallpaperDim_);
        settings.sync();
        emit wallpaperDimChanged();
    }
    QString accentTheme() const { return accent_; }
    Q_INVOKABLE bool setWallpaperPath(const QString &input) {
        const QString path = input.startsWith("file:") ? QUrl(input).toLocalFile() : input;
        if (!path.isEmpty()) {
            QFileInfo file(path);
            if (!file.isFile() || !file.isReadable() || !QImageReader(path).canRead())
                return false;
        }
        const QString resolved = path.isEmpty() ? QString() : QUrl::fromLocalFile(QFileInfo(path).absoluteFilePath()).toString();
        if (wallpaper_ == resolved) return true;
        wallpaper_ = resolved;
        QSettings settings("NEO-OS", "DesktopPreview");
        settings.setValue("appearance/wallpaper", wallpaper_);
        settings.sync();
        emit wallpaperUrlChanged();
        return true;
    }
    Q_INVOKABLE bool setAccentTheme(const QString &theme) {
        if (theme != "cyan" && theme != "violet") return false;
        if (accent_ == theme) return true;
        accent_ = theme;
        QSettings settings("NEO-OS", "DesktopPreview");
        settings.setValue("appearance/accent", accent_);
        settings.sync();
        emit accentThemeChanged();
        return true;
    }
    QStringList pinnedApps() const { return pins; }
    QVariantList availableApps() const { return apps; }
    const QHash<QString, QString> *icons() const { return &appIcons; }
    Q_INVOKABLE QVariantMap appById(const QString &id) const {
        if (!appPaths.contains(id)) return {};
        return {{"id", id}, {"name", appNames.value(id)}, {"icon", appIcons.value(id)}};
    }
    Q_INVOKABLE bool launch(const QString &id) {
        // Only enumerate installed .desktop entries; never execute untrusted text from the UI.
        if (!appPaths.contains(id) || QStandardPaths::findExecutable("gio").isEmpty()) return false;
        return QProcess::startDetached("gio", {"launch", appPaths.value(id)});
    }
    Q_INVOKABLE bool pin(const QString &id) {
        if (!appPaths.contains(id) || pins.contains(id)) return false;
        pins << id; persist(); emit pinnedAppsChanged(); return true;
    }
    Q_INVOKABLE bool unpin(const QString &id) {
        if (!pins.removeOne(id)) return false;
        persist(); emit pinnedAppsChanged(); return true;
    }
    Q_INVOKABLE bool launchMatrix() {
        struct Candidate { QString executable; QStringList args; };
        const QList<Candidate> options = {
            {"xterm", {"-bg", "black", "-fg", "green", "-fa", "Monospace", "-fs", "12"}},
            {"kitty", {"--override", "background=#050a07", "--override", "foreground=#30f080"}},
            {"konsole", {}}, {"gnome-terminal", {}}, {"xfce4-terminal", {}}
        };
        for (const auto &option : options)
            if (!QStandardPaths::findExecutable(option.executable).isEmpty())
                return QProcess::startDetached(option.executable, option.args);
        return false;
    }
signals:
    void pinnedAppsChanged();
    void wallpaperUrlChanged();
    void wallpaperThemesChanged();
    void wallpaperDimChanged();
    void wallpaperErrorChanged();
    void accentThemeChanged();
private:
    QString wallpaperDirectory() const {
        return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
               + "/neo-os/wallpapers";
    }
    void ensureBuiltInWallpapers() {
        const QString directory = wallpaperDirectory();
        if (!QDir().mkpath(directory)) {
            qWarning() << "Unable to create NEO wallpaper directory" << directory;
            return;
        }
        const QStringList names = {"01-nebula-orbit", "02-lunar-violet", "03-celestial-cyan", "04-midnight-aurora"};
        const QColor tops[] = {QColor("#07132e"), QColor("#120d35"),
                               QColor("#041b39"), QColor("#080e2a")};
        const QColor bottoms[] = {QColor("#44205b"), QColor("#5d245a"),
                                  QColor("#13617e"), QColor("#273d76")};
        for (int theme = 0; theme < names.size(); ++theme) {
            const QString path = directory + "/" + names[theme] + ".png";
            if (QFile::exists(path)) continue;
            QImage image(1280, 720, QImage::Format_RGB32);
            QPainter painter(&image);
            painter.setRenderHint(QPainter::Antialiasing);
            QLinearGradient sky(0, 0, 0, 720);
            sky.setColorAt(0, tops[theme]);
            sky.setColorAt(1, bottoms[theme]);
            painter.fillRect(image.rect(), sky);
            const QPointF planet(780 - theme * 42, 285 + theme * 12);
            QRadialGradient halo(planet, 315);
            halo.setColorAt(0, QColor(50 + theme * 12, 150, 245, 180));
            halo.setColorAt(0.8, QColor(79, 53, 184, 55));
            halo.setColorAt(1, Qt::transparent);
            painter.setBrush(halo);
            painter.setPen(Qt::NoPen);
            painter.drawEllipse(planet, 315, 315);
            QRadialGradient sphere(planet - QPointF(65, 65), 280);
            sphere.setColorAt(0, QColor("#397bb3"));
            sphere.setColorAt(0.58, theme % 2 ? QColor("#52356f") : QColor("#1b3977"));
            sphere.setColorAt(1, QColor("#080d2c"));
            painter.setBrush(sphere);
            painter.setPen(QPen(QColor("#42b5e9"), 3));
            painter.drawEllipse(planet, 205, 205);
            painter.setPen(QPen(QColor("#cf75f3"), 4));
            painter.setBrush(Qt::NoBrush);
            painter.save();
            painter.translate(planet);
            painter.rotate(-17);
            painter.drawEllipse(QRectF(-300, -75, 600, 150));
            painter.restore();
            QRandomGenerator rng(12345u + theme);
            painter.setPen(Qt::NoPen);
            for (int i = 0; i < 240; ++i) {
                painter.setBrush(QColor(198, 228, 255, 50 + static_cast<int>(rng.bounded(150u))));
                const qreal x = rng.bounded(1280u);
                const qreal y = rng.bounded(720u);
                const qreal radius = i % 9 ? 0.6 : 1.6;
                painter.drawEllipse(QPointF(x, y), radius, radius);
            }
            painter.end();
            if (!image.save(path, "PNG"))
                qWarning() << "Unable to save built-in wallpaper" << path;
        }
    }
    void persist() {
        QSettings settings("NEO-OS", "DesktopPreview");
        settings.setValue("dock/pins", pins);
        settings.sync();
    }
    QHash<QString, QString> appPaths, appNames, appIcons;
    QVariantList apps;
    QStringList pins;
    QString wallpaper_;
    QString wallpaperError_;
    QVariantList themes_;
    double wallpaperDim_ = 0.22;
    QString accent_ = "cyan";
};

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("NEO Desktop Preview");
    app.setOrganizationName("NEO-OS");
    DesktopBackend backend;
    if (QCoreApplication::arguments().contains("--wallpaper-self-test")) {
        // Headless CI probe of the same backend called by the native FileDialog.
        QTemporaryDir temporary;
        if (!temporary.isValid()) return 4;
        const QString png = temporary.filePath("NEO test wallpaper.png");
        QImage sample(1280, 720, QImage::Format_RGB32);
        sample.fill(QColor("#204c88"));
        if (!sample.save(png, "PNG")) return 5;
        const bool imported = backend.importWallpaper(QUrl::fromLocalFile(png).toString());
        const bool galleryPopulated = backend.wallpaperThemes().size() >= 5;
        const bool selected = !backend.wallpaperUrl().isEmpty() &&
                              QFileInfo(QUrl(backend.wallpaperUrl()).toLocalFile()).isReadable();
        if (!imported || !galleryPopulated || !selected) {
            qCritical().noquote() << "Wallpaper self-test failed" << backend.wallpaperError()
                                 << "gallery count:" << backend.wallpaperThemes().size();
            return 6;
        }
        qInfo() << "Wallpaper backend self-test passed; gallery count:"
                << backend.wallpaperThemes().size();
        return 0;
    }
    MatrixPty matrixPty;
    QQmlApplicationEngine engine;
    engine.addImageProvider("appicons", new AppIconProvider(backend.icons()));
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.rootContext()->setContextProperty("matrixPty", &matrixPty);
    engine.load(QUrl("qrc:/qt/qml/NeoDesktop/Main.qml"));
    if (engine.rootObjects().isEmpty()) return 1;
    if (QCoreApplication::arguments().contains("--desktop-smoke-test")) {
        QTimer::singleShot(800, &app, &QCoreApplication::quit);
    }
    return app.exec();
}
#include "main.moc"
