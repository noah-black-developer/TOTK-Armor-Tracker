#ifndef ARMOR_H
#define ARMOR_H

#include <QMap>
#include <QString>
#include <upgrade.h>

class Armor
{
public:
    Armor();
    Armor(
        QString armorName,
        QString armorSetName,
        QString armorSetDesc,
        QString armorPassiveBonus,
        QString armorSetBonus,
        bool isUnlocked,
        bool isUpgradeable,
        int armorLevel
    );

    // CLASS VARIABLES.
    // Armor Properties.
    QString name = "";
    QString setName = "";
    QString setDesc = "";
    QString passiveBonus = "";
    QString setBonus = "";
    bool isUnlocked = false;
    bool isUpgradeable = false;
    int level = 0;

    // CLASS METHODS.
    void addUpgradeTierByLevel(QString level, Upgrade *upgradeDetails);
    bool getUpgradeDetailsByLevel(QString level, Upgrade *&upgradeOut);
    QMap<QString, QVariant> getFullUpgradeDetailsMap() const;

private:
    // Armor Upgrade Details.
    // Upgrade tiers are indexed by level, and stored in QObject pointers.
    QMap<QString, QVariant> _upgradeDetails = QMap<QString, QVariant>();

};

#endif // ARMOR_H
