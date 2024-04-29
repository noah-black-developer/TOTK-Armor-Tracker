#include "appcontroller.h"

AppController::AppController(QObject *parent) : QObject{parent}
{
    // Initialize data models and sort/filter wrappers.
    ArmorSortFilter *mainArmorDataSort = new ArmorSortFilter(new ArmorData());
    _armorData = mainArmorDataSort;
    ArmorSortFilter *newSaveArmorDataSort = new ArmorSortFilter(new ArmorData());
    _newSaveArmorData = newSaveArmorDataSort;

    // Attempt to load in local app configs.
    loadAppConfig("appData.xml");  
}

AppController::~AppController()
{
    delete _armorData;
    delete _newSaveArmorData;
}

ArmorSortFilter *AppController::getArmorData() const
{
    return _armorData;
}

ArmorSortFilter *AppController::getNewSaveArmorData() const
{
    return _newSaveArmorData;
}

void AppController::clearNewSaveArmorData()
{
    // RE-INITIALIZE ARMOR DATA.
    // Re-apply any armor properties defined for main list + set default values.
    for (int armorIndex = 0; armorIndex < _armorData->model()->armorCount(); armorIndex++)
    {
        // Set user-adjustable fields to default values.
        Armor armor = _newSaveArmorData->model()->getArmorByIndex(armorIndex);
        _newSaveArmorData->model()->setArmorUnlockStatus(armor.name, false);
        _newSaveArmorData->model()->setArmorLevel(armor.name, 0);
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
    QString outputPath = savesFolder.absoluteFilePath(name + saveFileExtension);

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
    for (int armorIndex = 0; armorIndex < _armorData->model()->armorCount(); armorIndex++)
    {
        // Generate a new node for the current armor set.
        // Armor nodes are sourced directly off of the secondary "new save" data set.
        Armor currentArmorSet = _newSaveArmorData->model()->getArmorByIndex(armorIndex);
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
    loadSave(QUrl::fromLocalFile(outputPath));

    return true;
}

bool AppController::loadSave(QUrl filePath)
{
    // LOAD SAVE FILE.
    // If the given save file doesn't exist, return a failure.
    if (!fileExists(filePath.toLocalFile().toStdString()))
    {
        return false;
    }

    // Verify that the selected file includes the expected file extension.
    // All save files are stored in .xml formatting, but with varying extension changes.
    bool fileExtMatches = (filePath.toString().contains(QRegularExpression(saveFileExtension)));
    if (!fileExtMatches) {
        return false;
    }

    // Parse in the save file as a rapidxml-style object.
    rapidxml::xml_document<> saveDocument = rapidxml::xml_document<>();
    rapidxml::file<> file(filePath.toLocalFile().toStdString().c_str());
    saveDocument.parse<0>(file.data());

    // UPDATE ARMOR DATA.
    // Iterate over the full list of armor entries and update the presented UI elements.
    rapidxml::xml_node<> *saveNode = saveDocument.first_node("Save");
    for (rapidxml::xml_node<> *currentArmor = saveNode->first_node(); currentArmor != 0; currentArmor = currentArmor->next_sibling())
    {
        // Get the name of the current armor set.
        QString armorName = QString(currentArmor->first_attribute("Name")->value());

        // Set the armor's current level and unlock status.
        bool armorUnlockStatus((QString(currentArmor->first_attribute("Unlocked")->value()) == "true") ? true : false);
        _armorData->model()->setArmorUnlockStatus(armorName, armorUnlockStatus);
        int armorLevel(std::stoi(std::string(currentArmor->first_attribute("Level")->value())));
        _armorData->model()->setArmorLevel(armorName, armorLevel);
    }

    // Attempt to store the loaded save as a 'recent save' in app configs.
    addLocalSaveToAppConfig(filePath.fileName());
    setMostRecentlyAccessedSave(filePath.fileName());

    // Clear any flags from the previous save, if any.
    unsavedChanges = false;
    emit unsavedChangesStateChanged();

    // Once all armor sets have been pushed to save file, store file references and return a success.
    _loadedSavePath = filePath.toLocalFile();
    emit loadedSaveChanged(true);
    saveName = filePath.fileName();
    emit saveNameChanged(saveName);
    return true;
}

bool AppController::loadRecentSave(QString saveName)
{
    // GENERATE PATHS.
    // If the given file does not exist in saves folder, or saves folder does not exist, return a failure.
    QDir saveFileDir = QDir("saves");
    if (!saveFileDir.exists())
    {
        return false;
    }
    QString saveFilePath = saveFileDir.filePath(saveName);
    if (!fileExists(saveFilePath.toStdString()))
    {
        // Any removed files are similarly removed from the application configs file.
        removeLocalSaveFromAppConfig(saveName);
        return false;
    }

    // LOAD SAVE FILE.
    // Parse in the save file as a rapidxml-style object.
    rapidxml::xml_document<> saveDocument = rapidxml::xml_document<>();
    rapidxml::file<> file(saveFilePath.toStdString().c_str());
    saveDocument.parse<0>(file.data());

    // UPDATE ARMOR DATA.
    // Iterate over the full list of armor entries and update the presented UI elements.
    rapidxml::xml_node<> *saveNode = saveDocument.first_node("Save");
    for (rapidxml::xml_node<> *currentArmor = saveNode->first_node(); currentArmor != 0; currentArmor = currentArmor->next_sibling())
    {
        // Get the name of the current armor set.
        QString armorName = QString(currentArmor->first_attribute("Name")->value());

        // Set the armor's current level and unlock status.
        bool armorUnlockStatus((QString(currentArmor->first_attribute("Unlocked")->value()) == "true") ? true : false);
        _armorData->model()->setArmorUnlockStatus(armorName, armorUnlockStatus);
        int armorLevel(std::stoi(std::string(currentArmor->first_attribute("Level")->value())));
        _armorData->model()->setArmorLevel(armorName, armorLevel);
    }

    // Pump save up to the most recently accessed recent save.
    setMostRecentlyAccessedSave(saveName);

    // Clear any flags from the previous save, if any.
    unsavedChanges = false;
    emit unsavedChangesStateChanged();

    // Once all armor sets have been pushed to save file, store file references and return a success.
    _loadedSavePath = saveFilePath;
    emit loadedSaveChanged(true);
    this->saveName = QUrl(saveFilePath).fileName();
    emit saveNameChanged(saveName);
    return true;

}

bool AppController::saveCurrentSave()
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
        bool armorWasFound = _armorData->model()->getArmorByName(armorName, armor);
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

    // Push changes to the original file.
    std::ofstream saveFileOut;
    saveFileOut.open(_loadedSavePath.toStdString());
    saveFileOut << saveDocument;
    saveFileOut.close();

    // Clear save flags and return.
    unsavedChanges = false;
    emit unsavedChangesStateChanged();
    return true;
}

bool AppController::saveExists(QString saveName)
{
    // Locate the saves folder and assemble the potential path for the given save.
    QDir saveFileDir = QDir("saves");
    if (!saveFileDir.exists())
    {
        // If the saves folder could not be found, return false.
        return false;
    }
    QString saveFilePath = saveFileDir.filePath(saveName);

    // Return result of checking file existance.
    return fileExists(saveFilePath.toStdString());
}

bool AppController::saveIsLoaded()
{
    // If a save file path has been stored, save is loaded.
    return _loadedSavePath != "";
}

QString AppController::getSaveName()
{
    if (saveIsLoaded())
    {
        // Use QFileInfo to split file name from full path.
        QFileInfo saveFileInfo(_loadedSavePath);
        return saveFileInfo.fileName();
    }
    else {
        // If no save is loaded, return an empty string.
        return QString();
    }
}

QList<QString> AppController::getRecentSaveNames()
{
    return recentSaveNames;
}

bool AppController::loadAppConfig(QString filePath)
{
    // If the app config file cannot be found, return a failure.
    if (!fileExists(filePath.toStdString()))
    {
        return false;
    }

    // Parse in the config file as a rapidxml-style object.
    rapidxml::xml_document<> localConfigDoc = rapidxml::xml_document<>();
    rapidxml::file<> file(filePath.toStdString().c_str());
    localConfigDoc.parse<0>(file.data());

    // SEARCH APP CONFIG FOR RECENT SAVES.
    // Pull out all listed Recent Saves from respective locations. If required sections are missing, return a failure.
    rapidxml::xml_node<> *rootConfigNode = localConfigDoc.first_node("Data");
    if (rootConfigNode == 0) { return false; }
    rapidxml::xml_node<> *recentSavesNode = rootConfigNode->first_node("RecentSaves");
    if (recentSavesNode == 0) { return false; }

    // Clear any previously stored save names and begin parsing the config file for new save file names.
    recentSaveNames.clear();
    QList<rapidxml::xml_node<>*> nodesToRemove = QList<rapidxml::xml_node<>*> ();
    for (rapidxml::xml_node<> *currentNode = recentSavesNode->first_node("Save"); currentNode != 0; currentNode = currentNode->next_sibling())
    {
        // If the current node is already listed in the recent save list, mark it to be removed and continue.
        if (recentSaveNames.contains(currentNode->value()))
        {
            nodesToRemove.append(currentNode);
            continue;
        }

        // Check if the save file still exists in the local save folder. If not, mark it to be removed and continue.
        QDir saveFileDir = QDir("saves");
        QString saveFilePath = saveFileDir.filePath(currentNode->value());
        if (!fileExists(saveFilePath.toStdString())) {
            nodesToRemove.append(currentNode);
            continue;
        }

        // For each save found, append the name given to the internal list of recent saves.
        recentSaveNames.append(QString::fromStdString(currentNode->value()));
        emit recentSaveNamesChanged();
    }

    // Remove any flagged duplicates.
    for (int nodeIndex = 0; nodeIndex < nodesToRemove.length(); nodeIndex++)
    {
        recentSavesNode->remove_node(nodesToRemove[nodeIndex]);
    }

    // SEARCH APP CONFIG FOR DEFAULT THEMING.
    // Look for root node for application settings in config. If required sections are missing, return a failure.
    rapidxml::xml_node<> *appSettingsNode = rootConfigNode->first_node("Application");
    if (appSettingsNode == 0) { return false; }

    // Parse out required theming info and store interally within the class.
    rapidxml::xml_node<> *defaultThemeNode = appSettingsNode->first_node("Theme");
    setAppTheme(QString::fromStdString(defaultThemeNode->value()), false);

    // SEARCH APP CONFIG FOR FEATURE SETTINGS.
    // Parse out whether auto-saving is currently enabled and store.
    rapidxml::xml_node<> *autoSaveEnabledNode = appSettingsNode->first_node("AutoSaveEnabled");
    QString autoSaveEnabledValAsStr = QString::fromStdString(autoSaveEnabledNode->value());
    bool autoSaveEnabledValAsBool = (autoSaveEnabledValAsStr == "1") ? true : false;
    setAutoSaveSetting(autoSaveEnabledValAsBool, false);

    // Save off any changes that were made to list saves, such as removing duplicates.
    std::ofstream configFileOut;
    configFileOut.open(filePath.toStdString());
    configFileOut << localConfigDoc;
    configFileOut.close();

    // Store file path for later and return.
    _loadedAppConfigPath = filePath;
    return true;
}

bool AppController::addLocalSaveToAppConfig(QString saveName)
{
    // If no app config is laoded, return a failure.
    if (_loadedAppConfigPath == "")
    {
        return false;
    }

    // ADD NEW SAVE.
    // Parse in the config file as a rapidxml-style object.
    rapidxml::xml_document<> localConfigDoc = rapidxml::xml_document<>();
    rapidxml::file<> file(_loadedAppConfigPath.toStdString().c_str());
    localConfigDoc.parse<0>(file.data());

    // Allocate and add a new node for the provided save file.
    char *saveNameChar = localConfigDoc.allocate_string(saveName.toStdString().c_str());
    rapidxml::xml_node<> *rootConfigNode = localConfigDoc.first_node("Data");
    rapidxml::xml_node<> *recentSavesNode = rootConfigNode->first_node("RecentSaves");
    rapidxml::xml_node<> *newSaveFileNode = localConfigDoc.allocate_node(rapidxml::node_element, "Save", saveNameChar);
    // Node is added as top element to show it as most recently accessed file.
    recentSavesNode->prepend_node(newSaveFileNode);

    // Save out the modified file at original location.
    std::ofstream configFileOut;
    configFileOut.open(_loadedAppConfigPath.toStdString());
    configFileOut << localConfigDoc;
    configFileOut.close();

    // Re-load the app configs as needed to refresh save lists.
    loadAppConfig(_loadedAppConfigPath);
    return true;
}

bool AppController::removeLocalSaveFromAppConfig(QString saveName)
{
    // If no app config is laoded, return a failure.
    if (_loadedAppConfigPath == "")
    {
        return false;
    }

    // REMOVE SAVE BY NAME.
    // Parse in the config file as a rapidxml-style object.
    rapidxml::xml_document<> localConfigDoc = rapidxml::xml_document<>();
    rapidxml::file<> file(_loadedAppConfigPath.toStdString().c_str());
    localConfigDoc.parse<0>(file.data());

    // Look through the listed recent saves for a matching listing.
    rapidxml::xml_node<> *rootConfigNode = localConfigDoc.first_node("Data");
    rapidxml::xml_node<> *recentSavesRoot = rootConfigNode->first_node("RecentSaves");
    for (rapidxml::xml_node<> *currentNode = recentSavesRoot->first_node("Save"); currentNode != 0; currentNode = currentNode->next_sibling())
    {
        // If a match is found, remove it from the parent document and save out changes.
        if (QString(currentNode->value()) == saveName)
        {
            // Remove node from document.
            recentSavesRoot->remove_node(currentNode);

            // Save and return a success.
            std::ofstream configFileOut;
            configFileOut.open(_loadedAppConfigPath.toStdString());
            configFileOut << localConfigDoc;
            configFileOut.close();

            // Re-load the app configs as needed to refresh save lists.
            loadAppConfig(_loadedAppConfigPath);
            return true;
        }
    }

    // Otherwise, no match was found. Return a failure.
    return false;
}

bool AppController::setMostRecentlyAccessedSave(QString saveName)
{
    // If no app config is laoded, return a failure.
    if (_loadedAppConfigPath == "")
    {
        return false;
    }

    // ADJUST NODE ORDERING.
    // Parse in the config file as a rapidxml-style object.
    rapidxml::xml_document<> localConfigDoc = rapidxml::xml_document<>();
    rapidxml::file<> file(_loadedAppConfigPath.toStdString().c_str());
    localConfigDoc.parse<0>(file.data());

    // Iterate over recent save list until a matching node is found.
    rapidxml::xml_node<> *rootConfigNode = localConfigDoc.first_node("Data");
    rapidxml::xml_node<> *recentSavesNode = rootConfigNode->first_node("RecentSaves");
    rapidxml::xml_node<> *matchingNode = 0;
    for (rapidxml::xml_node<> *currentNode = recentSavesNode->first_node("Save"); currentNode != 0; currentNode = currentNode->next_sibling())
    {
        QString currentValue(currentNode->value());
        if (currentValue == saveName)
        {
            // Once a match is found, remove it from the original document and store.
            matchingNode = currentNode;
            recentSavesNode->remove_node(currentNode);
            break;
        }
    }

    // If a matching node could not be found, return a failure.
    if (matchingNode == 0)
    {
        return false;
    }

    // Prepend the given save file as the most recently accessed save.
    recentSavesNode->prepend_node(matchingNode);

    // SAVE CHANGES.
    // Save out the modified file at original location.
    std::ofstream configFileOut;
    configFileOut.open(_loadedAppConfigPath.toStdString());
    configFileOut << localConfigDoc;
    configFileOut.close();

    // Re-load the app configs as needed to refresh save lists.
    loadAppConfig(_loadedAppConfigPath);
    return true;
}

bool AppController::setAppConfigField(QString fieldName, QString newValue)
{
    // If no app config is laoded, return a failure.
    if (_loadedAppConfigPath == "")
    {
        return false;
    }

    // LOCATE REQUIRED FIELDS.
    // Parse in the config file as a rapidxml-style object.
    rapidxml::xml_document<> localConfigDoc = rapidxml::xml_document<>();
    rapidxml::file<> file(_loadedAppConfigPath.toStdString().c_str());
    localConfigDoc.parse<0>(file.data());

    // Navigate to the "Application" tag level.
    rapidxml::xml_node<> *rootConfigNode = localConfigDoc.first_node("Data");
    rapidxml::xml_node<> *applicationNode = rootConfigNode->first_node("Application");

    // Check if a matching node can be found at the app level. If not, return a failure.
    if (!applicationNode->first_node(fieldName.toStdString().c_str()))
    {
        qDebug() << "No matching config field found for name: " + fieldName;
        return false;
    }

    // MODIFY CONFIG.
    // Remove the original node under the matching name.
    rapidxml::xml_node<> *oldNode = applicationNode->first_node(fieldName.toStdString().c_str());
    applicationNode->remove_node(oldNode);

    // Re-create the config field and apply to the config with new values.
    char *fieldNameAlloc = localConfigDoc.allocate_string(fieldName.toStdString().c_str());
    char *newValueAlloc = localConfigDoc.allocate_string(newValue.toStdString().c_str());
    rapidxml::xml_node<> *newNode = localConfigDoc.allocate_node(rapidxml::node_element, fieldNameAlloc, newValueAlloc);
    applicationNode->append_node(newNode);

    // Save out the modified file at original location.
    std::ofstream configFileOut;
    configFileOut.open(_loadedAppConfigPath.toStdString());
    configFileOut << localConfigDoc;
    configFileOut.close();

    // If all steps were successful up to this point, refresh the application config and return a success.
    loadAppConfig(_loadedAppConfigPath);
    return true;
}

QString AppController::currentSortType() const
{
    return _armorData->currentSortType();
}

void AppController::setSortType(QString sortType)
{
    _armorData->setSortType(sortType);
}

void AppController::setSortDirection(bool ascending)
{
    _armorData->setSortDirection(ascending);
}

void AppController::setSortSearchFilter(QString newSortString)
{
    _armorData->setFilterRegularExpression(QRegularExpression(newSortString, QRegularExpression::CaseInsensitiveOption));
    _armorData->setFilterRole(ArmorData::NameRole);
}

QString AppController::newSaveCurrentSortType() const
{
    return _newSaveArmorData->currentSortType();
}

void AppController::newSaveSetSortType(QString sortType)
{
    _newSaveArmorData->setSortType(sortType);
}

void AppController::newSaveSetSortDirection(bool ascending)
{
    _newSaveArmorData->setSortDirection(ascending);
}

void AppController::newSaveSetSortSearchFilter(QString newSortString)
{
    _newSaveArmorData->setFilterRegularExpression(QRegularExpression(newSortString, QRegularExpression::CaseInsensitiveOption));
    _newSaveArmorData->setFilterRole(ArmorData::NameRole);
}

bool AppController::increaseArmorLevel(QString armorName, bool useNewSaveData)
{
    // Determine which data set to use.
    ArmorData *dataSet;
    if (useNewSaveData)
    {
        dataSet = _newSaveArmorData->model();
    }
    else {
        dataSet = _armorData->model();
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

    // Bump armor level and return a success. Flag that saveable changes have been made.
    dataSet->setArmorLevel(armorName, armor->level + 1);
    if (!useNewSaveData) {
        // Mark that changes have been made.
        unsavedChanges = true;
        emit unsavedChangesStateChanged();

        if (autoSaveEnabled) {
            // If auto-saving is enabled, save changes immediately.
            saveCurrentSave();
        }
    }
    return true;
}

bool AppController::decreaseArmorLevel(QString armorName, bool useNewSaveData)
{
    // Determine which data set to use.
    ArmorData *dataSet;
    if (useNewSaveData)
    {
        dataSet = _newSaveArmorData->model();
    }
    else {
        dataSet = _armorData->model();
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

    // Decrease armor level and return a success. If needed, flag that saveable changes have been made.
    dataSet->setArmorLevel(armorName, armor->level - 1);
    if (!useNewSaveData) {
        // Mark that changes have been made.
        unsavedChanges = true;
        emit unsavedChangesStateChanged();

        if (autoSaveEnabled) {
            // If auto-saving is enabled, save changes immediately.
            saveCurrentSave();
        }
    }
    return true;
}

bool AppController::toggleArmorUnlock(QString armorName, bool useNewSaveData)
{
    // Determine which data set to use.
    ArmorData *dataSet;
    if (useNewSaveData)
    {
        dataSet = _newSaveArmorData->model();
    }
    else {
        dataSet = _armorData->model();
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
    // Set the unlock to its inverse and return. If needed, flag that saveable changes have been made.
    dataSet->setArmorUnlockStatus(armorName, !armor->isUnlocked);
    if (!useNewSaveData) {
        // Mark that changes have been made.
        unsavedChanges = true;
        emit unsavedChangesStateChanged();

        if (autoSaveEnabled) {
            // If auto-saving is enabled, save changes immediately.
            saveCurrentSave();
        }
    }
    return true;
}

bool AppController::setAppTheme(QString themeName, bool setDefaults)
{
    // Modify internal variables for new value.
    theme = themeName;
    emit themeChanged(themeName);

    // If flags are set, push changes to app configs. Otherwise, return a fixed success.
    if (setDefaults) {
        return setAppConfigField("Theme", themeName);
    } else {
        return true;
    }
}

bool AppController::setAutoSaveSetting(bool autoSave, bool setDefaults)
{
    // Modify internal variables for the new value.
    autoSaveEnabled = autoSave;
    emit autoSaveStateChanged(autoSaveEnabled);

    // If flags are set, push changes to app configs. Otherwise, return a fixed success.
    if (setDefaults) {
        QString newAutoSaveValueAsStr = (autoSaveEnabled) ? "1" : "0";
        return setAppConfigField("AutoSaveEnabled", newAutoSaveValueAsStr);
    } else {
        return true;
    }
}
