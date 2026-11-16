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
#include <algorithm>

class DesktopBackend : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList pinnedApps READ pinnedApps NOTIFY pinnedAppsChanged)
    Q_PROPERTY(QVariantList availableApps READ availableApps CONSTANT)
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
                desktop.endGroup();
                if (id.isEmpty() || name.isEmpty() || appPaths.contains(id)) continue;
                appPaths.insert(id, path); appNames.insert(id, name);
            }
        }
        QStringList ids = appPaths.keys();
        std::sort(ids.begin(), ids.end(), [this](const QString &a, const QString &b) {
            return appNames.value(a).localeAwareCompare(appNames.value(b)) < 0;
        });
        for (const auto &id : ids)
            apps.append(QVariantMap{{"id", id}, {"name", appNames.value(id)}});
        QSettings settings("NEO-OS", "DesktopPreview");
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
    QStringList pinnedApps() const { return pins; }
    QVariantList availableApps() const { return apps; }
    Q_INVOKABLE QVariantMap appById(const QString &id) const {
        if (!appPaths.contains(id)) return {};
        return {{"id", id}, {"name", appNames.value(id)}};
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
private:
    void persist() {
        QSettings settings("NEO-OS", "DesktopPreview");
        settings.setValue("dock/pins", pins);
        settings.sync();
    }
    QHash<QString, QString> appPaths, appNames;
    QVariantList apps;
    QStringList pins;
};

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("NEO Desktop Preview");
    app.setOrganizationName("NEO-OS");
    DesktopBackend backend;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.load(QUrl("qrc:/qt/qml/NeoDesktop/Main.qml"));
    if (engine.rootObjects().isEmpty()) return 1;
    return app.exec();
}
#include "main.moc"
