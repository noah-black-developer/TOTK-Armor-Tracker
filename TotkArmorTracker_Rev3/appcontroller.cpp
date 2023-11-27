#include "appcontroller.h"

AppController::AppController(QObject *parent) : QObject{parent}
{
    // TEMP: Load in armor data.
    _armorData->loadArmorDataFromFile(QString("/home/noah/Documents/GitHub/TOTK-Armor-Tracker/TotkArmorTracker_Rev3/data/armorData.xml"));
    _newSaveArmorData->loadArmorDataFromFile(QString("/home/noah/Documents/GitHub/TOTK-Armor-Tracker/TotkArmorTracker_Rev3/data/armorData.xml"));
}

AppController::~AppController()
{
    delete _armorData;
    delete _newSaveArmorData;
}

ArmorData *AppController::getArmorData() const
{
    return _armorData;
}

ArmorData *AppController::getNewSaveArmorData() const
{
    return _newSaveArmorData;
}

void AppController::clearNewSaveArmorData()
{
    // RE-INITIALIZE ARMOR DATA.
    // Re-apply any armor properties defined for main list + set default values.
    for (int armorIndex = 0; armorIndex < _armorData->armorCount(); armorIndex++)
    {
        // Set user-adjustable fields to default values.
        Armor armor = _newSaveArmorData->getArmorByIndex(armorIndex);
        _newSaveArmorData->setArmorUnlockStatus(armor.name, false);
        _newSaveArmorData->setArmorLevel(armor.name, 0);
    }

    return;
}

bool AppController::createNewSave(QString name)
{
    // GENERATE PATHS.
    // If the save directory cannot be found, return a failure.
    QDir savesFolder = QDir(QDir::currentPath());
    bool saveDirExists = savesFolder.cd(QString("saves"));
    if (!saveDirExists)
    {
        return false;
    }
    QString outputPath = savesFolder.absoluteFilePath(name + ".xml");

    // CREATE DOCUMENT TREE.
    // Create a new document tree for the save file. Initialize any expected tree levels.
    rapidxml::xml_document<> newSaveDocument;
    rapidxml::xml_node<> *saveRoot = newSaveDocument.allocate_node(rapidxml::node_element, "Save");
    char *saveName = newSaveDocument.allocate_string(name.toStdString().c_str());
    rapidxml::xml_attribute<> *saveNameAttrib = newSaveDocument.allocate_attribute("name", saveName);
    saveRoot->append_attribute(saveNameAttrib);
    newSaveDocument.append_node(saveRoot);

    // INITIALIZE ARMOR DATA.
    // Iterate over all of the armor sets current stored internally.
    for (int armorIndex = 0; armorIndex < _armorData->armorCount(); armorIndex++)
    {
        // Generate a new node for the current armor set.
        // Armor nodes are sourced directly off of the secondary "new save" data set.
        Armor currentArmorSet = _newSaveArmorData->getArmorByIndex(armorIndex);
        rapidxml::xml_node<> *newArmorNode = newSaveDocument.allocate_node(rapidxml::node_element, "Armor");

        // Add attributes for name, armor unlock status, and level.
        // Name.
        char *armorName = newSaveDocument.allocate_string(currentArmorSet.name.toStdString().c_str());
        rapidxml::xml_attribute<> *nameAttrib = newSaveDocument.allocate_attribute("Name", armorName);
        newArmorNode->append_attribute(nameAttrib);
        // Unlock status, default of false (locked).
        char *armorIsUnlocked = newSaveDocument.allocate_string((currentArmorSet.isUnlocked) ? "true" : "false");
        rapidxml::xml_attribute<> *unlockedAttrib = newSaveDocument.allocate_attribute("Unlocked", armorIsUnlocked);
        newArmorNode->append_attribute(unlockedAttrib);
        // Armor level, default of 0.
        char *armorLevel = newSaveDocument.allocate_string(std::to_string(currentArmorSet.level).c_str());
        rapidxml::xml_attribute<> *levelAttrib = newSaveDocument.allocate_attribute("Level", armorLevel);
        newArmorNode->append_attribute(levelAttrib);

        // Append the new armor node.
        saveRoot->append_node(newArmorNode);
    }

    // SAVE NEW FILE.
    // Once all armor data has been appended, save off the new file to given output.
    std::ofstream newSaveFile;
    newSaveFile.open(outputPath.toStdString());
    newSaveFile << newSaveDocument;
    newSaveFile.close();

    // Now that the new save is created, load it in as the active save file.
    loadUserData(QUrl::fromLocalFile(outputPath));

    return true;
}

bool AppController::loadUserData(QUrl filePath)
{
    // GENERATE PATHS.
    // If the given file does not exist, return a failure.
    QString saveFilePath = filePath.toLocalFile();
    if (!fileExists(saveFilePath.toStdString()))
    {
        return false;
    }

    // LOAD DOCUMENT TREE.
    // Parse in the save file as a rapidxml-style object.
    rapidxml::xml_document<> saveDocument;
    rapidxml::file<> saveFile(saveFilePath.toStdString().c_str());
    saveDocument.parse<0>(saveFile.data());

    // UPDATE ARMOR DATA.
    // Iterate over the full list of armor entries and update the presented UI elements.
    rapidxml::xml_node<> *saveNode = saveDocument.first_node("Save");
    for (rapidxml::xml_node<> *currentArmor = saveNode->first_node(); currentArmor != 0; currentArmor = currentArmor->next_sibling())
    {
        // Get the name of the current armor set.
        QString armorName = QString(currentArmor->first_attribute("Name")->value());

        // Set the armor's current level and unlock status.
        bool armorUnlockStatus((QString(currentArmor->first_attribute("Unlocked")->value()) == "true") ? true : false);
        _armorData->setArmorUnlockStatus(armorName, armorUnlockStatus);
        int armorLevel(std::stoi(std::string(currentArmor->first_attribute("Level")->value())));
        _armorData->setArmorLevel(armorName, armorLevel);
    }

    // Update save file info and emit required signals.
    saveIsLoaded = true;
    emit loadedSaveChanged(saveIsLoaded);
    saveName = filePath.fileName();
    emit saveNameChanged(saveName);

    // Once all armor sets have been pushed to save file, store file references and return a success.
    _loadedSavePath = saveFilePath;
    return true;
}

bool AppController::saveUserData()
{
    // INITIALIZE LOADED SAVE.
    // If no save is currently loaded, fail with logs.
    if (_loadedSavePath == "")
    {
        qDebug() << "Attempted to save data when no save file was loaded.";
        return false;
    }

    // LOAD DOCUMENT TREE.
    // Parse in the save file as a rapidxml-style object.
    rapidxml::xml_document<> saveDocument;
    rapidxml::file<> saveFile(_loadedSavePath.toStdString().c_str());
    saveDocument.parse<0>(saveFile.data());

    // UPDATE ARMOR DATA.
    // Iterate over the full list of armor entries and update the save file.
    rapidxml::xml_node<> *saveNode = saveDocument.first_node("Save");
    for (rapidxml::xml_node<> *currentArmor = saveNode->first_node(); currentArmor != 0; currentArmor = currentArmor->next_sibling())
    {
        // Search for a matching armor object for the current node.
        QString armorName = QString(currentArmor->first_attribute("Name")->value());
        Armor *armor;
        bool armorWasFound = _armorData->getArmorByName(armorName, armor);
        if (!armorWasFound)
        {
            // If the current armor in save file does not match the internal list, print errors and continue.
            qDebug() << "Could not save data for armor set " + armorName + " to local save file:" + _loadedSavePath;
            continue;
        }

        // Push all available properties to the armor node.
        currentArmor->first_attribute("Unlocked")->value((armor->isUnlocked) ? "true" : "false");
        char *level = saveDocument.allocate_string(std::to_string(armor->level).c_str());
        currentArmor->first_attribute("Level")->value(level);
    }

    // Push changes to the original file and return.
    std::ofstream saveFileOut;
    saveFileOut.open(_loadedSavePath.toStdString());
    saveFileOut << saveDocument;
    saveFileOut.close();
    return true;
}

bool AppController::increaseArmorLevel(QString armorName, bool useNewSaveData)
{
    // Determine which data set to use.
    ArmorData *dataSet;
    if (useNewSaveData)
    {
        dataSet = _newSaveArmorData;
    }
    else {
        dataSet = _armorData;
    }

    // FIND ARMOR OBJECT.
    // Grab a reference to the full armor piece.
    Armor *armor;
    bool getArmorWasSuccessful = dataSet->getArmorByName(armorName, armor);
    if (!getArmorWasSuccessful)
    {
        // If an armor piece was not found using provided name, fail and return.
        qDebug() << "Unable to find matching armor set for name: " + armorName;
        return false;
    }

    // ADJUST LEVEL.
    // If armor is non-upgradeable, return early with logs.
    if (!armor->isUpgradeable)
    {
        qDebug() << "Attmepted to increase level of non-upgradeable armor " + armorName;
        return false;
    }

    // If the current armor set is already at its max value, return a failure with logs.
    if (armor->level == 4)
    {
        qDebug() << "Failed to increase level of " + armorName + ", already at max value.";
        return false;
    }

    // Bump armor level and return a success.
    dataSet->setArmorLevel(armorName, armor->level + 1);
    return true;
}

bool AppController::decreaseArmorLevel(QString armorName, bool useNewSaveData)
{
    // Determine which data set to use.
    ArmorData *dataSet;
    if (useNewSaveData)
    {
        dataSet = _newSaveArmorData;
    }
    else {
        dataSet = _armorData;
    }

    // FIND ARMOR OBJECT.
    // Grab a reference to the full armor piece.
    Armor *armor;
    bool getArmorWasSuccessful = dataSet->getArmorByName(armorName, armor);
    if (!getArmorWasSuccessful)
    {
        // If an armor piece was not found using provided name, fail and return.
        qDebug() << "Unable to find matching armor set for name: " + armorName;
        return false;
    }

    // ADJUST LEVEL.
    // If armor is non-upgradeable, return early with logs.
    if (!armor->isUpgradeable)
    {
        qDebug() << "Attmepted to decrease level of non-upgradeable armor " + armorName;
        return false;
    }

    // If the current armor set is already at its mnimum value, return a failure with logs.
    if (armor->level == 0)
    {
        qDebug() << "Failed to decrease level of " + armorName + ", already at min value.";
        return false;
    }

    // Decrease armor level and return a success.
    dataSet->setArmorLevel(armorName, armor->level - 1);
    return true;
}

bool AppController::toggleArmorUnlock(QString armorName, bool useNewSaveData)
{
    // Determine which data set to use.
    ArmorData *dataSet;
    if (useNewSaveData)
    {
        dataSet = _newSaveArmorData;
    }
    else {
        dataSet = _armorData;
    }

    // FIND ARMOR OBJECT.
    // Grab a reference to the full armor piece.
    Armor *armor;
    bool getArmorWasSuccessful = dataSet->getArmorByName(armorName, armor);
    if (!getArmorWasSuccessful)
    {
        // If an armor piece was not found using provided name, fail and return.
        qDebug() << "Unable to find matching armor set for name: " + armorName;
        return false;
    }

    // TOGGLE UNLOCK STATE.
    // Set the unlock to its inverse and return.
    dataSet->setArmorUnlockStatus(armorName, !armor->isUnlocked);
    return true;
}
