#include "armordata.h"

ArmorData::ArmorData(QObject *parent) : QAbstractListModel(parent)
{
    _parent = parent;
}

// PUBLIC METHODS.
// QAbstractListModel required methods.
QHash<int, QByteArray> ArmorData::roleNames() const
{
    return { { NameRole, "name" },
            { SetNameRole, "setName" },
            { SetDescRole, "description" },
            { PassiveBonusRole, "passive"},
            { SetBonusRole, "setBonus"},
            { UnlockedRole, "isUnlocked"},
            { UpgradeableRole, "isUpgradeable"},
            { LevelRole, "level"},
            { BaseDefenseRole, "baseDefense"},
            { UpgradeReqsRole, "upgradeReqs" }
            };
}

int ArmorData::rowCount(const QModelIndex &parent) const
{
    return _mDatas.size();
}

bool ArmorData::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!hasIndex(index.row(), index.column(), index.parent()) || !value.isValid())
        return false;

    Armor &armorItem = _mDatas[index.row()];
    if (role == NameRole)
    {
        armorItem.name = value.toString();
    }
    else if (role == SetNameRole)
    {
        armorItem.setName = value.toString();
    }
    else if (role == SetDescRole)
    {
        armorItem.setDesc = value.toString();
    }
    else if (role == PassiveBonusRole)
    {
        armorItem.passiveBonus = value.toString();
    }
    else if (role == SetBonusRole)
    {
        armorItem.setBonus = value.toString();
    }
    else if (role == UnlockedRole)
    {
        armorItem.isUnlocked = value.toBool();
    }
    else if (role == UpgradeableRole)
    {
        armorItem.isUpgradeable = value.toBool();
    }
    else if (role == LevelRole)
    {
        armorItem.level = value.toInt();
    }
    else if (role == BaseDefenseRole)
    {
        armorItem.baseDefense = value.toInt();
    }
    else if (role == UpgradeReqsRole)
    {
        // Unsupported setter. Return false if an attempt is made to adjust upgrade list.
        return false;
    }
    else {
        return false;
    }

    emit dataChanged(index, index, { role });

    return true;
}

QVariant ArmorData::data(const QModelIndex &index, int role) const
{
    if (!hasIndex(index.row(), index.column(), index.parent()))
    {
        return {};
    }

    const Armor &armorItem = _mDatas[index.row()];
    if (role == NameRole)
    {
        return armorItem.name;
    }
    if (role == SetNameRole)
    {
        return armorItem.setName;
    }
    if (role == SetDescRole)
    {
        return armorItem.setDesc;
    }
    if (role == PassiveBonusRole)
    {
        return armorItem.passiveBonus;
    }
    if (role == SetBonusRole)
    {
        return armorItem.setBonus;
    }
    if (role == UnlockedRole)
    {
        return armorItem.isUnlocked;
    }
    if (role == UpgradeableRole)
    {
        return armorItem.isUpgradeable;
    }
    if (role == LevelRole)
    {
        return armorItem.level;
    }
    if (role == BaseDefenseRole)
    {
        return armorItem.baseDefense;
    }
    if (role == UpgradeReqsRole)
    {
        return QVariant(armorItem.getFullUpgradeDetailsMap());
    }

    return {};
}

// Armor list methods.
bool ArmorData::loadArmorDataFromFile(QString armorFilePath)
{
    // PARSE ARMOR FILE.
    // Verify the given file exists. If not, return a failure.
    if (!fileExists(armorFilePath.toStdString())) {
        return false;
    }

    // Read in armor data as a parse-ready structure.
    std::vector<char> parseReadyArmorData;
    bool armorDataWasRead = readXmlToParseReadyObj(armorFilePath, parseReadyArmorData);
    if (armorDataWasRead == false)
    {
        // If the file failed to be read in correctly, return a failure.
        return false;
    }

    // Convert the XML string into a RapidXML-compatable document object.
    // Make a safe-to-modify copy of the save file string to load into RapidXML.
    rapidxml::xml_document<> armorDataXmlDocument;
    armorDataXmlDocument.parse<0>(&parseReadyArmorData[0]);

    // LOAD DATA INTO INTERNAL LISTS.
    // Iterate through all of the armor types in the user's save data.
    // RapidXML implements the DOM tree using linked lists, so we can just traverse the list
    //  until a non-valid node is reached to know we have gone over all of the armor types.
    rapidxml::xml_node<char> *armorsNode = armorDataXmlDocument.first_node("ArmorData");
    for (rapidxml::xml_node<char> *armorNode = armorsNode->first_node("Armor"); armorNode != 0; armorNode = armorNode->next_sibling())
    {
        // Pull and store high-level properties for the armor piece.
        Armor armor = Armor();
        armor.name = armorNode->first_attribute("name")->value();
        armor.setName = armorNode->first_node("SetName")->value();
        armor.setDesc = armorNode->first_node("Description")->value();
        armor.passiveBonus = armorNode->first_node("PassiveBonus")->value();
        armor.setBonus = armorNode->first_node("SetBonus")->value();
        QString upgradeStatus = armorNode->first_node("CanBeUpgraded")->value();
        armor.isUpgradeable = (upgradeStatus == QString("true")) ? true : false;
        QString baseDefense = armorNode->first_node("BaseDefense")->value();
        armor.baseDefense = baseDefense.toInt();

        // Initialize all user-specific fields to default values.
        armor.isUnlocked = false;
        armor.level = 0;

        // Loop over all upgrade tiers to intiialze each level's requirements, if available.
        if (armor.isUpgradeable){
            for (rapidxml::xml_node<char> *upgradeNode = armorNode->first_node("Tiers")->first_node("Tier"); upgradeNode != 0; upgradeNode = upgradeNode->next_sibling())
            {
                // Create a new Upgrade object.
                Upgrade *newUpgrade = new Upgrade();

                // Store the current level's defense rupee cost as class properties.
                QString tierDefense = upgradeNode->first_node("Defense")->value();
                newUpgrade->defense = tierDefense.toInt();
                QString tierCostInRupees = upgradeNode->first_node("Cost")->value();
                newUpgrade->costInRupees = tierCostInRupees.toInt();

                // Iterate over all listed in the class and append a new Item requirement for each.
                for (rapidxml::xml_node<char> *itemNode = upgradeNode->first_node("Item"); itemNode != 0; itemNode = itemNode->next_sibling("Item"))
                {
                    // Parse out the item name and quantity.
                    QString itemName = itemNode->first_attribute("name")->value();
                    QString itemQuantityStr = itemNode->first_attribute("quantity")->value();
                    int itemQuantity = itemQuantityStr.toInt();

                    // Add the item to the current upgrade.
                    newUpgrade->addItem(itemName, itemQuantity);
                }

                // Append the upgrade by tier.
                QString levelStr = upgradeNode->first_attribute("level")->value();
                armor.addUpgradeTierByLevel(levelStr, newUpgrade);
            }
        }

        // Add the armor into the internal list.
        addArmor(armor);
    }

    return true;
}

void ArmorData::addArmor(Armor armor)
{
    _mDatas.append(armor);
    return;
}

void ArmorData::clearArmor()
{
    _mDatas.clear();
    return;
}

int ArmorData::armorCount()
{
    return _mDatas.length();
}

Armor ArmorData::getArmorByIndex(int index)
{
    return _mDatas[index];
}

bool ArmorData::getArmorByName(QString armorName, Armor *&armorOut)
{
    // Search the list for the correct armor set.
    for (int row = 0; row < armorCount(); row++)
    {
        if (_mDatas[row].name == armorName)
        {
            armorOut = std::addressof(_mDatas[row]);
            return true;
        }
    }
    return false;
}

int ArmorData::getArmorRowByName(QString armorName)
{
    // Search the list for the correct armor set.
    for (int row = 0; row < armorCount(); row++)
    {
        QModelIndex rowIndex = createIndex(row, 0);
        if (data(rowIndex, NameRole).toString() == armorName)
        {
            return row;
        }
    }
    return -1;
}

QList<Armor> ArmorData::getFullArmorList()
{
    return _mDatas;
}

bool ArmorData::setArmorUnlockStatus(QString armorName, bool isUnlocked)
{
    // Search the list for the correct armor set. If not found, return a failure.
    int armorRow = getArmorRowByName(armorName);
    if (armorRow == -1)
    {
        return false;
    }

    // Set armor unlock status and return.
    QModelIndex armorIndex = createIndex(armorRow, 0);
    setData(armorIndex, QVariant(isUnlocked), UnlockedRole);
    return true;
}

bool ArmorData::setArmorLevel(QString armorName, int level)
{
    // Search the list for the correct armor set. If not found, return a failure.
    int armorRow = getArmorRowByName(armorName);
    if (armorRow == -1)
    {
        return false;
    }

    // Set armor level and return.
    QModelIndex armorIndex = createIndex(armorRow, 0);
    setData(armorIndex, QVariant(level), LevelRole);
    return true;
}
