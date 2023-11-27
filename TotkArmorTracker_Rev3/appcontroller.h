#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <fstream>
#include <iostream>
#include <QDebug>
#include <QDir>
#include <QObject>
#include <QQmlEngine>
#include <armordata.h>
#include <armorsortfilter.h>

class AppController : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool saveIsLoaded MEMBER saveIsLoaded NOTIFY loadedSaveChanged)
    Q_PROPERTY(QString saveName MEMBER saveName NOTIFY saveNameChanged)

public:
    explicit AppController(QObject *parent = nullptr);
    ~AppController();

    // MODEL METHODS.
    Q_INVOKABLE ArmorSortFilter *getArmorData() const;
    Q_INVOKABLE ArmorSortFilter *getNewSaveArmorData() const;
    Q_INVOKABLE void clearNewSaveArmorData();

    // SAVE FILE METHODS.
    Q_INVOKABLE bool createNewSave(QString name);
    Q_INVOKABLE bool loadUserData(QUrl filePath);
    Q_INVOKABLE bool saveUserData();

    // SORT METHODS.
    Q_INVOKABLE QString currentSortType() const;
    Q_INVOKABLE bool currentSortIsAsc() const;
    Q_INVOKABLE void setSortType(QString sortType);
    Q_INVOKABLE void setSortDirection(bool ascending);

    // MODIFY ARMOR METHODS.
    // Default to modifying the main dataset. Additional parameters can be set
    // to instead run these methods on the secondary set for new save files.
    Q_INVOKABLE bool increaseArmorLevel(QString armorName, bool useNewSaveData = false);
    Q_INVOKABLE bool decreaseArmorLevel(QString armorName, bool useNewSaveData = false);
    Q_INVOKABLE bool toggleArmorUnlock(QString armorName, bool useNewSaveData = false);

    // EXPOSED QML PROPERTY.
    // Set to default values for no loaded save file.
    bool saveIsLoaded = false;
    QString saveName = "No Save Loaded";

private:
    QString _loadedSavePath = "";
    ArmorSortFilter *_armorData;
    ArmorSortFilter *_newSaveArmorData;

signals:
    void loadedSaveChanged(bool saveIsLoaded);
    void saveNameChanged(QString saveName);
};

#endif // APPCONTROLLER_H
