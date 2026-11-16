#pragma once

#include <QObject>
#include <QSocketNotifier>
#include <QTimer>
#include <QString>

class MatrixPty final : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString output READ output NOTIFY outputChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
public:
    explicit MatrixPty(QObject *parent = nullptr);
    ~MatrixPty() override;

    QString output() const { return output_; }
    bool running() const { return childPid_ > 0; }
    Q_INVOKABLE bool start();
    Q_INVOKABLE bool sendLine(const QString &text);
    Q_INVOKABLE void interrupt();
    Q_INVOKABLE void stop();

signals:
    void outputChanged();
    void runningChanged();

private:
    void appendOutput(const QString &chunk);
    void readAvailable();
    void checkChild();

    int masterFd_ = -1;
    qint64 childPid_ = -1;
    QString output_;
    QSocketNotifier *notifier_ = nullptr;
    QTimer pollTimer_;
};
