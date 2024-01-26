#ifndef ARMORDATA_H
#define ARMORDATA_H

#include <fstream>
#include <iostream>
#include <QAbstractListModel>
#include <QQmlEngine>
#include <QVariant>
#include <rapidxml-1.13/rapidxml.hpp>
#include <rapidxml-1.13/rapidxml_print.hpp>
#include <rapidxml-1.13/rapidxml_utils.hpp>
#include <armor.h>
#include <helper.cpp>

class ArmorData : public QAbstractListModel
{
    Q_OBJECT

public:
    enum ArmorRoles {
        NameRole = Qt::UserRole + 1,
        SetNameRole,
        SetDescRole,
        PassiveBonusRole,
        SetBonusRole,
        UnlockedRole,
        UpgradeableRole,
        LevelRole,
        UpgradeReqsRole
    } ArmorRoles;

    ArmorData(QObject *parent = nullptr);

    // QAbstractListModel required methods.
    QHash<int, QByteArray> roleNames() const;
    int rowCount(const QModelIndex &parent) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    // Armor list methods.
    bool loadArmorDataFromFile(QString armorFilePath);
    void addArmor(Armor armor);
    void clearArmor();
    int armorCount();
    Armor getArmorByIndex(int index);
    bool getArmorByName(QString armorName, Armor *&armorOut);
    int getArmorRowByName(QString armorName);
    QList<Armor> getFullArmorList();
    bool setArmorUnlockStatus(QString armorName, bool isUnlocked);
    bool setArmorLevel(QString armorName, int level);

private:
    QList<Armor> _mDatas = QList<Armor>();
    QObject *_parent;
};

#endif // ARMORDATA_H
