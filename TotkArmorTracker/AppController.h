#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include <QQmlEngine>

class AppController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit AppController(QObject *qmlRootObject, QObject *parent = nullptr);

    Q_INVOKABLE bool appInitialize(QString armorConfigsPath);
    Q_INVOKABLE bool appPullSave(QUrl saveFilePath);

private:
    QObject *_qmlRootObject;

};

#endif // APPCONTROLLER_H
