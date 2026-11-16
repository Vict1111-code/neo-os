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
#include <QDir>
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
    Q_PROPERTY(QVariantList wallpaperThemes READ wallpaperThemes CONSTANT)
    Q_PROPERTY(double wallpaperDim READ wallpaperDim NOTIFY wallpaperDimChanged)
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
        const QString wallpaperDir = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
                                    + "/neo-os/wallpapers";
        QDir dir(wallpaperDir);
        const QFileInfoList images = dir.entryInfoList({"*.webp", "*.png", "*.jpg", "*.jpeg"},
                                       QDir::Files | QDir::Readable, QDir::Name);
        for (const QFileInfo &image : images) {
            if (!QImageReader(image.absoluteFilePath()).canRead()) continue;
            const QString url = QUrl::fromLocalFile(image.absoluteFilePath()).toString();
            themes_.append(QVariantMap{{"name", image.completeBaseName().replace('-', ' ')},
                                       {"url", url}});
        }
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
    void wallpaperDimChanged();
    void accentThemeChanged();
private:
    void persist() {
        QSettings settings("NEO-OS", "DesktopPreview");
        settings.setValue("dock/pins", pins);
        settings.sync();
    }
    QHash<QString, QString> appPaths, appNames, appIcons;
    QVariantList apps;
    QStringList pins;
    QString wallpaper_;
    QVariantList themes_;
    double wallpaperDim_ = 0.22;
    QString accent_ = "cyan";
};

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("NEO Desktop Preview");
    app.setOrganizationName("NEO-OS");
    DesktopBackend backend;
    MatrixPty matrixPty;
    QQmlApplicationEngine engine;
    engine.addImageProvider("appicons", new AppIconProvider(backend.icons()));
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.rootContext()->setContextProperty("matrixPty", &matrixPty);
    engine.load(QUrl("qrc:/qt/qml/NeoDesktop/Main.qml"));
    if (engine.rootObjects().isEmpty()) return 1;
    return app.exec();
}
#include "main.moc"
