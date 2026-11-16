#include "MatrixPty.h"
#include <QCoreApplication>
#include <QTimer>
#include <QDebug>

// Integration smoke test: runs an actual unprivileged Bash shell attached to
// a PTY; only executes a fixed harmless echo command.
int main(int argc, char **argv) {
    QCoreApplication app(argc, argv);
    MatrixPty terminal;
    bool sent = false;

    QTimer timeout;
    timeout.setSingleShot(true);
    QObject::connect(&timeout, &QTimer::timeout, &app, [&]() {
        qCritical() << "PTY smoke test timed out; output:" << terminal.output();
        terminal.stop();
        app.exit(1);
    });

    QObject::connect(&terminal, &MatrixPty::outputChanged, &app, [&]() {
        if (!sent || !terminal.output().contains("\nNEO_PTY_INTEGRATION_OK\n")) return;
        terminal.stop();
        if (terminal.running()) {
            qCritical() << "PTY session still marked running after stop";
            app.exit(1);
            return;
        }
        qInfo() << "PTY shell echo and stop passed";
        app.exit(0);
    });

    if (!terminal.start()) {
        qCritical() << "Unable to start PTY";
        return 1;
    }
    timeout.start(10000);
    QTimer::singleShot(200, &app, [&]() {
        sent = true;
        if (!terminal.sendLine("echo NEO_PTY_INTEGRATION_OK")) {
            qCritical() << "Unable to send PTY test command";
            app.exit(1);
        }
    });
    return app.exec();
}
