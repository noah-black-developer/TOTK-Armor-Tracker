#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <fstream>
#include <iostream>
#include <QDebug>
#include <QDir>
#include <QObject>
#include <QQmlEngine>
#include <armordata.h>

class AppController : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool saveIsLoaded MEMBER saveIsLoaded NOTIFY loadedSaveChanged)
    Q_PROPERTY(QString saveName MEMBER saveName NOTIFY saveNameChanged)

public:
    explicit AppController(QObject *parent = nullptr);

    Q_INVOKABLE ArmorData *getArmorData() const;
    Q_INVOKABLE bool createNewSave(QString name);
    Q_INVOKABLE bool loadUserData(QUrl filePath);
    Q_INVOKABLE bool saveUserData();
    Q_INVOKABLE bool increaseArmorLevel(QString armorName);
    Q_INVOKABLE bool decreaseArmorLevel(QString armorName);
    Q_INVOKABLE bool toggleArmorUnlock(QString armorName);

    // EXPOSED QML PROPERTY.
    // Set to default values for no loaded save file.
    bool saveIsLoaded = false;
    QString saveName = "No Save Loaded";

private:
    QString _loadedSavePath = "";
    ArmorData *_armorData = new ArmorData();

signals:
    void loadedSaveChanged(bool saveIsLoaded);
    void saveNameChanged(QString saveName);
};

#endif // APPCONTROLLER_H
