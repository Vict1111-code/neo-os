#include "MatrixPty.h"

#include <QByteArray>
#include <QRegularExpression>
#include <QSocketNotifier>

#include <cerrno>
#include <csignal>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <pty.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <unistd.h>

MatrixPty::MatrixPty(QObject *parent) : QObject(parent) {
    pollTimer_.setInterval(250);
    connect(&pollTimer_, &QTimer::timeout, this, &MatrixPty::checkChild);
}

MatrixPty::~MatrixPty() {
    stop();
}

void MatrixPty::appendOutput(const QString &chunk) {
    // Deliberately minimal text-only output. Not a complete ANSI/VT emulator.
    QString clean = chunk;
    static const QRegularExpression ansi(
        QStringLiteral("\\x1B\\[[0-?]*[ -/]*[@-~]"));
    clean.remove(ansi);
    clean.remove(QChar('\r'));
    output_ += clean;
    constexpr qsizetype maxChars = 100000;
    if (output_.size() > maxChars)
        output_ = output_.right(maxChars);
    emit outputChanged();
}

bool MatrixPty::start() {
    if (running()) return true;
    output_.clear();
    emit outputChanged();

    struct winsize ws {};
    ws.ws_row = 24;
    ws.ws_col = 80;
    const pid_t pid = forkpty(&masterFd_, nullptr, nullptr, &ws);
    if (pid < 0) {
        masterFd_ = -1;
        appendOutput(QStringLiteral("PTY initialization failed.\n"));
        return false;
    }
    if (pid == 0) {
        // In the child process: never elevate privileges or execute AI-generated text.
        setenv("TERM", "dumb", 1);
        setenv("PS1", "neo$ ", 1);
        unsetenv("PROMPT_COMMAND");
        const char *shell = "/bin/bash";
        execl(shell, shell, "--noprofile", "--norc", "-i", static_cast<char *>(nullptr));
        _exit(127);
    }

    childPid_ = pid;
    const int flags = fcntl(masterFd_, F_GETFL);
    if (flags >= 0) fcntl(masterFd_, F_SETFL, flags | O_NONBLOCK);
    notifier_ = new QSocketNotifier(masterFd_, QSocketNotifier::Read, this);
    connect(notifier_, &QSocketNotifier::activated, this, [this]() { readAvailable(); });
    pollTimer_.start();
    emit runningChanged();
    return true;
}

void MatrixPty::readAvailable() {
    if (masterFd_ < 0) return;
    char buffer[4096];
    while (true) {
        const ssize_t len = read(masterFd_, buffer, sizeof(buffer));
        if (len > 0) {
            appendOutput(QString::fromLocal8Bit(buffer, static_cast<qsizetype>(len)));
        } else if (len < 0 && errno == EINTR) {
            continue;
        } else {
            break;
        }
    }
}

bool MatrixPty::sendLine(const QString &text) {
    if (!running() || masterFd_ < 0) return false;
    QByteArray bytes = text.toUtf8();
    bytes.append('\n');
    qsizetype offset = 0;
    while (offset < bytes.size()) {
        const ssize_t written = write(masterFd_, bytes.constData() + offset,
                                       static_cast<size_t>(bytes.size() - offset));
        if (written > 0) offset += written;
        else if (written < 0 && errno == EINTR) continue;
        else return false;
    }
    return true;
}

void MatrixPty::interrupt() {
    if (!running() || masterFd_ < 0) return;
    const char interruptChar = 3; // PTY line discipline generates SIGINT for foreground process group.
    (void)write(masterFd_, &interruptChar, 1);
}

void MatrixPty::checkChild() {
    if (!running()) return;
    int status = 0;
    const pid_t result = waitpid(static_cast<pid_t>(childPid_), &status, WNOHANG);
    if (result != childPid_) return;
    readAvailable();
    const QString exitText = WIFEXITED(status)
        ? QStringLiteral("\n[Shell exited: %1]\n").arg(WEXITSTATUS(status))
        : QStringLiteral("\n[Shell terminated]\n");
    childPid_ = -1;
    pollTimer_.stop();
    if (notifier_) { delete notifier_; notifier_ = nullptr; }
    if (masterFd_ >= 0) { close(masterFd_); masterFd_ = -1; }
    appendOutput(exitText);
    emit runningChanged();
}

void MatrixPty::stop() {
    pollTimer_.stop();
    if (notifier_) { delete notifier_; notifier_ = nullptr; }
    if (masterFd_ >= 0) { close(masterFd_); masterFd_ = -1; }
    if (childPid_ > 0) {
        const pid_t pid = static_cast<pid_t>(childPid_);
        // Shell is a session leader. Hang up its session; reap with bounded wait.
        kill(pid, SIGHUP);
        bool reaped = false;
        int status = 0;
        for (int i = 0; i < 10; ++i) {
            if (waitpid(pid, &status, WNOHANG) == pid) { reaped = true; break; }
            usleep(10000);
        }
        if (!reaped) {
            kill(pid, SIGKILL);
            (void)waitpid(pid, &status, 0);
        }
        childPid_ = -1;
        emit runningChanged();
    }
}
