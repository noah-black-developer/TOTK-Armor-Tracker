#include "armordata.h"

// INLINE HELPER FUNCTIONS.
// Function to check for the existance of a file in the local file system.
// https://stackoverflow.com/questions/12774207/fastest-way-to-check-if-a-file-exists-using-standard-c-c11-14-17-c
inline bool fileExists (const std::string& name) {
    if (FILE *file = fopen(name.c_str(), "r")) {
        fclose(file);
        return true;
    } else {
        return false;
    }
}


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
            { LevelRole, "level"}
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
    else if (role == LevelRole)
    {
        armorItem.level = value.toInt();
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
    if (role == LevelRole)
    {
        return armorItem.level;
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
    xml_document<> armorDataXmlDocument;
    armorDataXmlDocument.parse<0>(&parseReadyArmorData[0]);

    // LOAD DATA INTO INTERNAL LISTS.
    // Iterate through all of the armor types in the user's save data.
    // RapidXML implements the DOM tree using linked lists, so we can just traverse the list
    //  until a non-valid node is reached to know we have gone over all of the armor types.
    xml_node<char> *armorsNode = armorDataXmlDocument.first_node("ArmorData");
    for (xml_node<char> *armorNode = armorsNode->first_node("Armor"); armorNode != 0; armorNode = armorNode->next_sibling())
    {
        // Pull and store high-level properties for the armor piece.
        Armor armor = Armor();
        armor.name = armorNode->first_attribute("name")->value();
        armor.setName = armorNode->first_node("SetName")->value();
        armor.setDesc = armorNode->first_node("Description")->value();
        armor.passiveBonus = armorNode->first_node("PassiveBonus")->value();
        armor.setBonus = armorNode->first_node("SetBonus")->value();

        // Level of the armor is initialized to 0.
        armor.level = 0;

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
