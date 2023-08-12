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

    // GENERAL METHODS.
    Q_INVOKABLE bool appInitialize(QString armorConfigsPath);
    Q_INVOKABLE bool appPullSave(QUrl saveFilePath);

    // APP ICON BAR METHODS.
    Q_INVOKABLE bool appSetSelectedArmor(QString armorName);
    Q_INVOKABLE void appDeselectAll();

private:
    QObject *_qmlRootObject;
    QObject *_selectedArmor;

    QObject *_getArmorIconByName(QString armorName);

};

#endif // APPCONTROLLER_H
