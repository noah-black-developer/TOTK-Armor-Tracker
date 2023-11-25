#include "armor.h"

Armor::Armor() { }

Armor::Armor(
    QString armorName,
    QString armorSetName,
    QString armorSetDesc,
    QString armorPassiveBonus,
    QString armorSetBonus,
    bool isUnlocked,
    bool isUpgradeable,
    int armorLevel)
{
    name = armorName;
    setName = armorSetName;
    setDesc = armorSetDesc;
    passiveBonus = armorPassiveBonus;
    setBonus = armorSetBonus;
    isUnlocked = isUnlocked;
    isUpgradeable = isUpgradeable;
    level = armorLevel;
}

void Armor::setUpgradeLevel(int level, Upgrade upgradeDetails)
{
    // Add a new map entry, with level/upgrade as the key/value pair.
    _upgradeDetails[level] = upgradeDetails;
    return;
}

bool Armor::getUpgradeDetailsByLevel(int level, Upgrade &upgradeOut)
{
    // Verify given level exists in the upgrade list. If not, return a failure.
    if (!_upgradeDetails.contains(level))
    {
        return false;
    }

    // Return the value stored at the key.
    upgradeOut = _upgradeDetails[level];
    return true;
}
