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

    Q_PROPERTY(bool saveIsLoaded READ saveIsLoaded NOTIFY loadedSaveChanged)
    Q_PROPERTY(QString saveName READ getSaveName NOTIFY saveNameChanged)
    Q_PROPERTY(QList<QString> recentSaveNames MEMBER recentSaveNames NOTIFY recentSaveNamesChanged)
    Q_PROPERTY(bool sortIsAsc MEMBER sortIsAsc NOTIFY sortDirectionChanged)

public:
    explicit AppController(QObject *parent = nullptr);
    ~AppController();

    // MODEL METHODS.
    Q_INVOKABLE ArmorSortFilter *getArmorData() const;
    Q_INVOKABLE ArmorSortFilter *getNewSaveArmorData() const;
    Q_INVOKABLE void clearNewSaveArmorData();

    // SAVE FILE METHODS.
    Q_INVOKABLE bool createNewSave(QString name);
    Q_INVOKABLE bool loadSave(QUrl filePath);
    Q_INVOKABLE bool loadRecentSave(QString saveName);
    Q_INVOKABLE bool saveCurrentSave();
    // Class q_property definitions are given getters that return based on class state.
    Q_INVOKABLE bool saveIsLoaded();
    Q_INVOKABLE QString getSaveName();
    Q_INVOKABLE QList<QString> getRecentSaveNames();

    // APP CONFIG METHODS.
    bool loadAppConfig(QString filePath);
    bool addLocalSaveToAppConfig(QString saveName);
    bool removeLocalSaveFromAppConfig(QString saveName);
    bool setMostRecentlyAccessedSave(QString saveName);

    // SORT METHODS.
    Q_INVOKABLE QString currentSortType() const;
    Q_INVOKABLE void setSortType(QString sortType);
    Q_INVOKABLE void setSortDirection(bool ascending);
    Q_INVOKABLE void setSortSearchFilter(QString newSortString);

    // MODIFY ARMOR METHODS.
    // Default to modifying the main dataset. Additional parameters can be set
    // to instead run these methods on the secondary set for new save files.
    Q_INVOKABLE bool increaseArmorLevel(QString armorName, bool useNewSaveData = false);
    Q_INVOKABLE bool decreaseArmorLevel(QString armorName, bool useNewSaveData = false);
    Q_INVOKABLE bool toggleArmorUnlock(QString armorName, bool useNewSaveData = false);

    // Q_PROPERTY OBJECTS.
    QList<QString> recentSaveNames = QList<QString>();
    bool sortIsAsc = true;

private:
    QString _loadedSavePath = "";
    QString _loadedAppConfigPath = "";
    ArmorSortFilter *_armorData;
    ArmorSortFilter *_newSaveArmorData;

signals:
    void loadedSaveChanged(bool saveIsLoaded);
    void saveNameChanged(QString saveName);
    void recentSaveNamesChanged();
    void sortDirectionChanged();
};

#endif // APPCONTROLLER_H
