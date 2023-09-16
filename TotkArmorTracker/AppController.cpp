#include <AppController.h>


// HELPER FUNCTIONS.
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


// APPCONTROLLER METHODS.
AppController::AppController(QObject *qmlRootObject, QObject *parent)
    : QObject{parent}
{
    _qmlRootObject = qmlRootObject;
}

bool AppController::initialize(QString armorConfigsPath)
{
    // Store the config file paths for use later.
    _armorConfigsPath = armorConfigsPath;

    // LOAD IN ARMOR CONFIG FILE.
    // Read in the config file as a string compatable with XML parsing.
    std::vector<char> parseReadyArmorConfigFile = _readXmlToParseReadyObj(armorConfigsPath);

    // If the returned string is empty, return a failure.
    if(parseReadyArmorConfigFile == std::vector<char>('\0'))
    {
        return false;
    }

    // Convert the XML string into a RapidXML-compatable document object.
    // Make a safe-to-modify copy of the save file string to load into RapidXML.
    xml_document<> *armorConfigsFileXmlDocument = new xml_document<>;
    armorConfigsFileXmlDocument->parse<0>(&parseReadyArmorConfigFile[0]);

    // LOAD IN ARMOR CONFIGS TO UI.
    // Settings must be applied across all the different sort arrangements.
    // Store references to all the different sorts available.
    QList<QObject*> armorSortsList;
    armorSortsList.append(_qmlRootObject->findChild<QObject*>("Alphabetical"));
    armorSortsList.append(_qmlRootObject->findChild<QObject*>("By Set"));

    // Initialize settings across all sorts.
    for (int armorIndex = 0; armorIndex < armorSortsList.length(); armorIndex++)
    {
        // Store the current sort being configured.
        QObject *currentSort = armorSortsList[armorIndex];

        // For each armor type, apply values for armor name, image, and whether the armor can be upgraded or not.
        xml_node<char> *armorBaseNode = armorConfigsFileXmlDocument->first_node("ArmorData");
        for(xml_node<char> *armorNode = armorBaseNode->first_node(); armorNode != 0; armorNode = armorNode->next_sibling())
        {
            // STORE ARMOR PROPERTIES.
            QString armorName = armorNode->first_attribute("name")->value();
            QString armorIconUrl = "images/" + armorName + ".png";
            QString armorIsUpgradeableVal = armorNode->first_node("CanBeUpgraded")->value();

            // APPLY PROPERTIES TO UI.
            // Locate the correct QML object by name.
            QObject *armorObj = currentSort->findChild<QObject*>(armorName);

            // If no object could be found, print an error and continue to the next armor type.
            if(armorObj == NULL)
            {
                qDebug("Armor from config file does not have an associated QML object.");
                qDebug("%s", armorNode->first_attribute("name")->value());
                continue;
            }

            // Set QML properties from the configs file.
            armorObj->setProperty("armorName", armorName);
            armorObj->setProperty("armorIconUrl", armorIconUrl);
            armorObj->setProperty("isUpgradeable", armorIsUpgradeableVal);

            // By default, all armor starts as not yet unlocked until user save is loaded.
            armorObj->setProperty("isUnlocked", false);
        }
    }

    // Set the current armor sort to "alphabetical".
    setArmorSort("Alphabetical");

    // Call any methods relating to defaulting/initializing the UI.
    _setArmorDetailsToDefault();

    return true;
}

bool AppController::pullSave(QUrl saveFilePath)
{
    // Convert QUrl to QString. QML file dialogs return QUrl by default,
    // which must be converted to a local path before use in backend code.
    QString convertedSaveFilePath = saveFilePath.toLocalFile();

    // Read in the save file as a string compatable with XML parsing.
    std::vector<char> parseReadySaveFile = _readXmlToParseReadyObj(convertedSaveFilePath);

    // If the returned string is empty, return a failure.
    if(parseReadySaveFile == std::vector<char>('\0'))
    {
        return false;
    }

    // Convert the XML string into a RapidXML-compatable document object.
    // Make a safe-to-modify copy of the save file string to load into RapidXML.
    xml_document<> saveFileXmlDocument;
    saveFileXmlDocument.parse<0>(&parseReadySaveFile[0]);

    // APPLY SAVE DATA TO APP.
    // Settings must be applied across all the different sort arrangements.
    // Store references to all the different sorts available.
    QList<QObject*> armorSortsList;
    armorSortsList.append(_qmlRootObject->findChild<QObject*>("Alphabetical"));
    armorSortsList.append(_qmlRootObject->findChild<QObject*>("By Set"));

    // Initialize settings across all sorts.
    for (int armorIndex = 0; armorIndex < armorSortsList.length(); armorIndex++)
    {
        // Store the current sort being configured.
        QObject *currentSort = armorSortsList[armorIndex];

        // Iterate through all of the armor types in the user's save data.
        // RapidXML implements the DOM tree using linked lists, so we can just traverse the list
        //  until a non-valid node is reached to know we have gone over all of the armor types.
        xml_node<char> *armorsNode = saveFileXmlDocument.first_node("Save")->first_node("Armors");
        for (xml_node<char> *armorNode = armorsNode->first_node(); armorNode != 0; armorNode = armorNode->next_sibling())
        {
            // STORE ARMOR INFO.
            QString armorName = armorNode->first_attribute("name")->value();
            QString armorIsUnlocked = armorNode->first_attribute("unlocked")->value();
            QString armorLevel = armorNode->first_attribute("level")->value();

            // APPLY ARMOR INFO TO UI.
            // Locate the correct QML object by name inside the current sort
            QObject *armorObj = currentSort->findChild<QObject*>(armorName);

            // If no object could be found, print an error and continue to the next armor type.
            if(armorObj == NULL)
            {
                qDebug("Armor from save file does not have an associated QML object.");
                qDebug("%s", armorNode->first_attribute("name")->value());
                continue;
            }

            // Set QML properties from the configs file.
            armorObj->setProperty("isUnlocked", armorIsUnlocked);
            armorObj->setProperty("currentRank", armorLevel.toInt());
        }
    }

    // Apply the name of the loaded save wherever it is needed in UI.
    // Removing the file's extension has to be done manually by grabbing characters left of it.
    QString loadedSaveName = saveFilePath.fileName();
    int loadedSaveExtStartIndex = loadedSaveName.lastIndexOf(".");
    QString loadedSaveNameNoExt = loadedSaveName.left(loadedSaveExtStartIndex);
    QObject *saveNameTextObj = _qmlRootObject->findChild<QObject*>("saveNameText");
    saveNameTextObj->setProperty("saveName", loadedSaveNameNoExt);

    // Add the loaded save to the list of recent save files.
    _addSaveToRecentList(saveFilePath);

    // Store the active save and return.
    _currentSaveFile = saveFilePath;
    return true;
}

bool AppController::pushSave() {
    // Verify that there is a currently loaded save.
    // If not, return a failure.
    if (_currentSaveFile == QUrl("")) {
        return false;
    }

    // Convert QUrl to QString. Save file's path is stored as QUrl by default,
    // which must be converted to a local path before use in backend code.
    QString convertedSaveFilePath = _currentSaveFile.toLocalFile();

    // Read in the save file as a string compatable with XML parsing.
    std::vector<char> parseReadySaveFile = _readXmlToParseReadyObj(convertedSaveFilePath);

    // If the returned string is empty, return a failure.
    if(parseReadySaveFile == std::vector<char>('\0'))
    {
        return false;
    }

    // Convert the XML string into a RapidXML-compatable document object.
    // Make a safe-to-modify copy of the save file string to load into RapidXML.
    xml_document<> saveFileXmlDocument;
    saveFileXmlDocument.parse<0>(&parseReadySaveFile[0]);

    // SAVE CURRENT UI SETTINGS TO SAVE FILE.
    // Store a reference to the currently active sort. Used to grab the best available armor icons.
    QObject *currentSortObj = _qmlRootObject->findChild<QObject*>(_currentSort);

    // Start an iterator to cycle through all of the save's armor fields.
    // Each should have an associated armor icon that can be used to reference current armor level.
    xml_node<char> *armorsNode = saveFileXmlDocument.first_node("Save")->first_node("Armors");
    for (xml_node<char> *armorNode = armorsNode->first_node(); armorNode != 0; armorNode = armorNode->next_sibling()) {
        // Store a reference to the armor icon for the current armor node.
        // The ObjectName property of the armor icon should match the actual armor name.
        QString armorName = armorNode->first_attribute("name")->value();
        QObject *armorIconObj = currentSortObj->findChild<QObject*>(armorName);

        // If no armor icon could be found, return a failure with error logging.
        if (armorIconObj == nullptr) {
            qDebug() << "Armor set does not have matching Armor Icon" + armorName;
            return false;
        }

        // Save values for the armor's unlock state.
        bool unlockedValue = armorIconObj->property("isUnlocked").toBool();
        if (unlockedValue) {
            armorNode->first_attribute("unlocked")->value("true");
        } else {
            armorNode->first_attribute("unlocked")->value("false");
        }

        // Save values for the armor's level.
        // Issues were found in testing with getting the returned property
        // as a properly formatted character string, so a switch statement is used instead.
        int armorLevelValue = armorIconObj->property("currentRank").toInt();
        switch (armorLevelValue) {
            case 0:
                armorNode->first_attribute("level")->value("0");
                break;
            case 1:
                armorNode->first_attribute("level")->value("1");
                break;
            case 2:
                armorNode->first_attribute("level")->value("2");
                break;
            case 3:
                armorNode->first_attribute("level")->value("3");
                break;
            default:
                // If an unsupported level was found, set the armor to base level with debug logs.
                armorNode->first_attribute("level")->value("0");
                qDebug("Unsupported armor level found during save. Setting to base level.");
                break;
        }
    }

    // WRITE BACK EDITED XML FILE.
    // After all of the file properties are saved, write back the final results.
    std::ofstream saveFile;
    saveFile.open(_currentSaveFile.toLocalFile().toStdString());
    saveFile << saveFileXmlDocument;
    saveFile.close();

    return true;
}

bool AppController::refreshRecentSaves() {
    // SET RECENT SAVES.
    // Store a reference to the parent menu option for recent saves.
    QObject *recentSavesMenuParent = _qmlRootObject->findChild<QObject*>("openRecentMenu");

    // Check if at least one entry exists in the list of recent saves.
    bool recentSavesExist = _recentSavesList.length() > 0;

    // If so, apply all of the saves in order to the menu options.
    if (recentSavesExist) {
        // Enable the parent menu option to allow user to select recent saves.
        recentSavesMenuParent->setProperty("enabled", true);

        // Start a loop up to the maximum number of possible recent saves.
        for (int index = 0; index < MAX_RECENT_SAVES; index++) {
            // Store a reference for the appropriate menu option in QML.
            QString menuOptionName = QString("recentSave") + QString::number(index + 1);
            QObject *recentSaveOption = recentSavesMenuParent->findChild<QObject*>(menuOptionName);

            // If the current index is beyond the number of listed saves, hide the menu option and continue.
            if (index + 1 > _recentSavesList.length()) {
                recentSaveOption->setProperty("visible", false);
                continue;
            }

            // Otherwise, reveal the menu item and set it's name to the name of the save file.
            QUrl saveFilePath = _recentSavesList[index];
            QString saveFileName = saveFilePath.fileName();
            recentSaveOption->setProperty("visible", true);
            recentSaveOption->setProperty("fileName", saveFileName);
            recentSaveOption->setProperty("filePath", saveFilePath);
        }
    }

    // Otherwise, if no recent saves are currently avaialble, disable the option to select recent saves altogether.
    else {
        recentSavesMenuParent->setProperty("enabled", true);
    }

    return true;
}

bool AppController::setSelectedArmor(QString armorName) {
    // DESELECTED ANY CURRENT ARMOR SELECTIONS.
    // If the class object _selectedArmor is not null, some armor is currently selected.
    // Make sure it is deselected before selecting the new one.
    if (_selectedArmor != nullptr) {
        // Get and deselect the current selection.
        QObject *currentSelectionObj = _getArmorIconByName(_selectedArmor->property("armorName").toString());
        currentSelectionObj->setProperty("selected", false);
    }

    // Locate the associated ArmorIcon for the given armor name. If null, return a failure.
    QObject *newSelectionObj = _getArmorIconByName(armorName);
    if (newSelectionObj == nullptr) {
        return false;
    }

    // Set new armor as the selected armor.
    newSelectionObj->setProperty("selected", true);
    _selectedArmor = newSelectionObj;

    // Apply details about the new selection to any appropriate UI elements.
    _setArmorDetailsByName(armorName);
    return true;
}

void AppController::deselectAll() {
    // Deselect the current selection using local reference.
    QObject *currentSelectionObj = _getArmorIconByName(_selectedArmor->property("armorName").toString());
    currentSelectionObj->setProperty("selected", false);

    // Clear the local reference to selected objects.
    _selectedArmor = nullptr;

    // Set any fields that display armor info to default values.
    _setArmorDetailsToDefault();
    return;
}

bool AppController::setArmorSort(QString sortName) {
    // SET SORT PROPERTIES.
    // Set any properties relating to changing the displayed sort.
    QObject *armorIconsParent = _qmlRootObject->findChild<QObject*>("armorIconsScrollView");
    armorIconsParent->setProperty("activeSort", sortName);

    // Store the new sort name.
    _currentSort = sortName;

    // ADJUST SELECTED ICON.
    // If a piece of armor it selected, it will need to be transfered to the new sort arrangement.
    if (_selectedArmor != nullptr) {
        // Unselect the old selected armor and store its properties to be re-selected.
        _selectedArmor->setProperty("selected", "false");
        QString prevSelectedArmorName = _selectedArmor->property("armorName").toString();

        // With the new sort, re-select the armor and store it as selected in c++.
        QObject *currSelectedArmorObj = _getArmorIconByName(prevSelectedArmorName);
        currSelectedArmorObj->setProperty("selected", true);
        _selectedArmor = currSelectedArmorObj;
    }

    return true;
}

void AppController::setArmorUnlockedState(QString armorName, bool unlock) {
    // GET REFERENCE TO ARMOR.
    QObject *armorObj = _getArmorIconByName(armorName);

    // UPDATE UI.
    // Set the new unlock state.
    armorObj->setProperty("isUnlocked", unlock);

    // Once property changes are made, reload the UI where needed.
    bool armorIsSelected = armorObj->property("selected").toBool();
    if (armorIsSelected) {
        _setArmorDetailsByName(armorName);
    }
    return;
}

void AppController::setArmorLevel(QString armorName, int newLevel) {
    // GET REFERENCE TO ARMOR.
    QObject *armorObj = _getArmorIconByName(armorName);

    // UPDATE UI.
    // Set the new armor level
    armorObj->setProperty("currentRank", newLevel);

    // Once property changes are made, reload the UI where needed.
    bool armorIsSelected = armorObj->property("selected").toBool();
    if (armorIsSelected) {
        _setArmorDetailsByName(armorName);
    }
    return;
}


// PRIVATE METHODS.
// Private method to get the associated ArmorIcon object for a given armor name.
// Inputs:
//  armorName - Name of the armor to select, as a QString.
// Outputs:
//  Returns a pointer to the ArmorIcon object, if successful. Otherwise, returns a nullptr.
QObject* AppController::_getArmorIconByName(QString armorName) {
    // Narrow search to the currently active sort.
    QObject *activeSortObj = _qmlRootObject->findChild<QObject*>(_currentSort);

    // Search for the object. If not found, findChild auto-returns a nullptr.
    return activeSortObj->findChild<QObject*>(armorName);
}

// Private method to configure the displayed armor details to a given armor set.
// Starts with general armor info, then accesses save-specific details as needed.
// Inputs:
//  armorName - Name of the armor to select, as a QString.
bool AppController::_setArmorDetailsByName(QString armorName) {
    // APPLY ARMOR IMAGE.
    // Separate from config files, set the background image as visible with the correct armor set.
    QObject *armorImageObj = _qmlRootObject->findChild<QObject*>("selectedArmorImage");
    armorImageObj->setProperty("visible", true);
    armorImageObj->setProperty("source", "images/" + armorName + ".png");

    // LOAD IN ARMOR CONFIG FILE.
    // Read in the config file as a string compatable with XML parsing.
    std::vector<char> parseReadyArmorConfigFile = _readXmlToParseReadyObj(_armorConfigsPath);

    // If the returned string is empty, return a failure.
    if(parseReadyArmorConfigFile == std::vector<char>('\0'))
    {
        return false;
    }

    // Convert the XML string into a RapidXML-compatable document object.
    // Make a safe-to-modify copy of the save file string to load into RapidXML.
    xml_document<> *armorConfigsFileXmlDocument = new xml_document<>;
    armorConfigsFileXmlDocument->parse<0>(&parseReadyArmorConfigFile[0]);

    // SEARCH FOR ARMOR IN DATA DOCUMENT.
    // Use the stored armor xml_document to get the associated armor node,
    // which contains all of the required info about the given set.
    xml_node<char> *armorNode = nullptr;
    xml_node<char> *armorBaseNode = armorConfigsFileXmlDocument->first_node("ArmorData");
    for(xml_node<char> *currentArmorNode = armorBaseNode->first_node(); currentArmorNode != 0; currentArmorNode = currentArmorNode->next_sibling())
    {
        // If the node has the "name" attribute set to the one passed in, break with it.
        if (currentArmorNode->first_attribute("name")->value() == armorName) {
            armorNode = currentArmorNode;
            break;
        }
    }

    // If the correct armor could not be located, return a failure.
    if (armorNode == 0) {
        return false;
    }

    // APPLY GENERAL ARMOR DATA.
    // Set the name of the armor.
    _qmlRootObject->findChild<QObject*>("selectedArmorNameLabel")->setProperty("text", armorName);
    _qmlRootObject->findChild<QObject*>("selectedArmorNameLabel")->setProperty("visible", true);

    // Set the set name of the armor.
    // If the armor isn't a part of a set (i.e. set name is N/A), hide this label from view.
    QString armorSetName = armorNode->first_node("SetName")->value();
    if (armorSetName != "N/A") {
        _qmlRootObject->findChild<QObject*>("selectedArmorSetNameLabel")->setProperty("text", armorSetName);
        _qmlRootObject->findChild<QObject*>("selectedArmorSetNameLabel")->setProperty("visible", true);
    }
    else {
        _qmlRootObject->findChild<QObject*>("selectedArmorSetNameLabel")->setProperty("visible", false);
    }

    // Set the desciption of the armor.
    QString armorDescription = armorNode->first_node("Description")->value();
    _qmlRootObject->findChild<QObject*>("selectedArmorQuoteLabel")->setProperty("text", "\"" + armorDescription + "\"");
    _qmlRootObject->findChild<QObject*>("selectedArmorQuoteLabel")->setProperty("visible", true);

    // Set whether the armor is currently unlocked or not.
    QObject *armorObj = _getArmorIconByName(armorName);
    bool armorIsUnlocked = armorObj->property("isUnlocked").toBool();
    _qmlRootObject->findChild<QObject*>("selectedArmorUnlockedIcon")->setProperty("isUnlocked", armorIsUnlocked);
    _qmlRootObject->findChild<QObject*>("selectedArmorUnlockedIcon")->setProperty("visible", true);

    // Store and apply armor's current rank, as well as whether it can be upgraded.
    int armorLevel = armorObj->property("currentRank").toInt();
    QString armorIsUpgradeableStr = armorNode->first_node("CanBeUpgraded")->value();
    bool armorIsUpgradeable = (armorIsUpgradeableStr == "true") ? true : false;
    _qmlRootObject->findChild<QObject*>("armorLevelRow")->setProperty("armorLevel", armorLevel);

    // Reference current armor defense.
    // Displayed value is determined based on the armor's current level.
    int armorDefense = -1;
    if (armorLevel == 0 || !armorIsUpgradeable) {
        // When not upgraded OR unupgradeable, the armor level is stored in the "BaseDefense" property at base level.
        // Uses atoi() to parse the char* object into a readable int.
        armorDefense = atoi(armorNode->first_node("BaseDefense")->value());
    }
    else {
        // Otherwise, search for armor level inside the "Tiers" subcategory, using the armor level as a search key.
        // Uses atoi() to parse any char* objects from the xml into readable ints.
        for(xml_node<char> *currentTierNode = armorNode->first_node("Tiers")->first_node("Tier"); currentTierNode != 0; currentTierNode = currentTierNode->next_sibling()) {
            if (atoi(currentTierNode->first_attribute("level")->value()) == armorLevel) {
                armorDefense = atoi(currentTierNode->first_node("Defense")->value());
            }
        }
    }

    // Set armor defense.
    // Only revealed if the armor is unlocked. Otherwise, make sure it is hidden from view.
    if (armorIsUnlocked) {
        _qmlRootObject->findChild<QObject*>("selectedArmorDefenseLabel")->setProperty("defense", armorDefense);
        _qmlRootObject->findChild<QObject*>("selectedArmorDefenseLabel")->setProperty("visible", true);
    }
    else {
        _qmlRootObject->findChild<QObject*>("selectedArmorDefenseLabel")->setProperty("visible", false);
    }

    // Set armor passive bonus.
    QString armorPassiveBonus = armorNode->first_node("PassiveBonus")->value();
    _qmlRootObject->findChild<QObject*>("selectedArmorPassiveLabel")->setProperty("passiveBonus", armorPassiveBonus);
    _qmlRootObject->findChild<QObject*>("selectedArmorPassiveLabel")->setProperty("visible", true);

    // Set armor set bonus.
    QString armorSetBonus = armorNode->first_node("SetBonus")->value();
    _qmlRootObject->findChild<QObject*>("selectedArmorSetBonusLabel")->setProperty("setBonus", armorSetBonus);
    _qmlRootObject->findChild<QObject*>("selectedArmorSetBonusLabel")->setProperty("visible", true);

    // SETUP ARMOR UPGRADES.
    // Configure the visible controls based on if the armor is upgradeable or not.
    // Additionally, if the armor is not yet unlocked, prevent upgrades from being displayed yet.
    if (armorIsUpgradeable && armorIsUnlocked) {
        // If it can be upgraded, start by revealing the armor upgrade fields and separator.
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierOne")->setProperty("visible", true);
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierTwo")->setProperty("visible", true);
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierThree")->setProperty("visible", true);
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierFour")->setProperty("visible", true);

        // Create + store initial references for the armor's strength stats.
        // Two separate trackers will be used to track both pre-upgrade
        // and post-upgrade statistics.
        QString preUpgradeArmor = armorNode->first_node("BaseDefense")->value();
        QString postUpgradeArmor;

        // Begin an iterator from the first "Tier" header for the armor in data storage.
        // For each tier, gather data and apply it to the matching display in the UI.
        int currentTier = 1;
        for(xml_node<char> *currentTierNode = armorNode->first_node("Tiers")->first_node("Tier"); currentTierNode != 0; currentTierNode = currentTierNode->next_sibling())
        {
            // Create a reference to the current tier's QML object.
            QObject *tierObject;
            if (currentTier == 1) {
                tierObject = _qmlRootObject->findChild<QObject*>("armorUpgradeTierOne");
            }
            else if (currentTier == 2) {
                tierObject = _qmlRootObject->findChild<QObject*>("armorUpgradeTierTwo");
            }
            else if (currentTier == 3) {
                tierObject = _qmlRootObject->findChild<QObject*>("armorUpgradeTierThree");
            }
            else {
                tierObject = _qmlRootObject->findChild<QObject*>("armorUpgradeTierFour");
            }

            // Apply the pre/post upgrade armor strengths, then prep for the next iteration.
            postUpgradeArmor = currentTierNode->first_node("Defense")->value();
            tierObject->setProperty("prevArmor", preUpgradeArmor);
            tierObject->setProperty("nextArmor", postUpgradeArmor);
            preUpgradeArmor = postUpgradeArmor;

            // Set the rupee cost for the current upgrade.
            QString rupeeCostValue = currentTierNode->first_node("Cost")->value();
            tierObject->setProperty("rupeeCost", rupeeCostValue);

            // For each required item, add it onto the upgrade visualized and count the total # of items added.
            int itemCount = 0;
            for (xml_node<char> *currentItemNode = currentTierNode->first_node("Item"); currentItemNode != 0; currentItemNode = currentItemNode->next_sibling())
            {
                // Increment counter and move to next node.
                itemCount++;

                // Set name and quantity by case.
                QString nameValue;
                QString quantityValue;
                switch(itemCount)
                {
                    case 1:
                        nameValue = currentItemNode->first_attribute("name")->value();
                        tierObject->setProperty("materialOneName", nameValue);
                        quantityValue = currentItemNode->first_attribute("quantity")->value();
                        tierObject->setProperty("materialOneQuantity", quantityValue);
                        break;
                    case 2:
                        nameValue = currentItemNode->first_attribute("name")->value();
                        tierObject->setProperty("materialTwoName", nameValue);
                        quantityValue = currentItemNode->first_attribute("quantity")->value();
                        tierObject->setProperty("materialTwoQuantity", quantityValue);
                        break;
                    case 3:
                        nameValue = currentItemNode->first_attribute("name")->value();
                        tierObject->setProperty("materialThreeName", nameValue);
                        quantityValue = currentItemNode->first_attribute("quantity")->value();
                        tierObject->setProperty("materialThreeQuantity", quantityValue);
                        break;
                    case 4:
                        nameValue = currentItemNode->first_attribute("name")->value();
                        tierObject->setProperty("materialFourName", nameValue);
                        quantityValue = currentItemNode->first_attribute("quantity")->value();
                        tierObject->setProperty("materialFourQuantity", quantityValue);
                        break;
                }
            }

            // Once all items have been added, set the item count to the respective amount.
            tierObject->setProperty("upgradeMaterialCount", itemCount);
            currentTier++;
        }

        // As long as the armor is not at max level, reveal just the "upgrade" button.
        bool armorIsMaxLevel = (armorLevel == 4);
        _qmlRootObject->findChild<QObject*>("unlockArmorButton")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("upgradeArmorButton")->setProperty("visible", !armorIsMaxLevel);
    }

    else {
        // Otherwise, if the armor cannot be upgraded, hide all of the upgrade fields from view.
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierOne")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierTwo")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierThree")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierFour")->setProperty("visible", false);
        // Set the state of the "unlock" button depending on the armor's current unlock state.
        _qmlRootObject->findChild<QObject*>("unlockArmorButton")->setProperty("visible", !armorIsUnlocked);
        _qmlRootObject->findChild<QObject*>("upgradeArmorButton")->setProperty("visible", false);
    }

    return true;
}

// Function to set the all fields that display armor details to default values.
// Used both to initialize the fields and to zero them out whenever no armor is currently selected.
// Outputs:
//  True if all fields were successfully set to default values. Otherwise, false.
bool AppController::_setArmorDetailsToDefault() {
    // Wrap all steps that access QML in a try/catch block.
    // If anything raises an exception, catch it and return a failure with logs.
    try {
        // MODIFY UI.
        // Hide the central armor image from view.
        // With no armor selected, this shouldn't be displayed to the user.
        _qmlRootObject->findChild<QObject*>("selectedArmorImage")->setProperty("visible", false);

        // Hide most of the text fields from the user.
        _qmlRootObject->findChild<QObject*>("selectedArmorNameLabel")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("selectedArmorSetNameLabel")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("selectedArmorUnlockedIcon")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("selectedArmorDefenseLabel")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("selectedArmorPassiveLabel")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("selectedArmorSetBonusLabel")->setProperty("visible", false);

        // Hid all object upgrade fields and the associated separator.
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierOne")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierTwo")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierThree")->setProperty("visible", false);
        _qmlRootObject->findChild<QObject*>("armorUpgradeTierFour")->setProperty("visible", false);

        // Use the "quote" fields to let the user know that no armor is currently selected.
        QString noSelectionText = "No current selection. Click on a piece of armor in the left column to view it's current progress.";
        _qmlRootObject->findChild<QObject*>("selectedArmorQuoteLabel")->setProperty("text", noSelectionText);
    }
    catch (...) {
        qDebug("Failure while attempting set armor details to defaults.");
        return false;
    }

    // If all QML calls succeeded, return a success.
    return true;
}

// Load in an XML file at given path and convert it to a parse-ready char vector.
// Inputs:
//  xmlFilePath - Path to the XML file as a QString.
// Outputs:
//  char vector object, formatted for parsing using RapidXML.
//  If XML file could not be read, returns an empty char vector.
std::vector<char> AppController::_readXmlToParseReadyObj(QString xmlFilePath)
{
    // LOAD IN XML FILE.
    // First, verify that the XML file exists.
    std::ifstream xmlFileStream;
    xmlFileStream.open(xmlFilePath.toStdString());

    std::string xmlFileString = "";
    if(xmlFileStream)
    {
        std::string xmlFileLine;

        // If so, load the XML document in as a string.
        while(std::getline(xmlFileStream, xmlFileLine))
        {
            xmlFileString += xmlFileLine;
        }

        // Close the file once finished.
        xmlFileStream.close();
    }
    else
    {
        // If the file could not be read, return an empty char vector with error logs.
        qDebug("Given XML document could not be read correctly");
        qDebug("%s", xmlFilePath.toStdString().c_str());
        return std::vector<char>('\0');
    }

    // Convert the XML string into a RapidXML-compatable document object.
    // Make a safe-to-modify copy of the save file string to load into RapidXML.
    std::vector<char> saveFileStreamCopy(xmlFileString.begin(), xmlFileString.end());
    saveFileStreamCopy.push_back('\0');
    return saveFileStreamCopy;
}

// Add a save file to the list of recently loaded save files.
// Applies the change to the internal list of saves, then syncs that change with the external data storage.
bool AppController::_addSaveToRecentList(QUrl saveFilePath) {
    // ADD SAVE TO INTERNAL LIST.
    // If this method was called before the list of saves was initialized internally, return a failure.
//    if (!_recentSavesAreInitialized) {
//        return false;
//    }

    for (int saveIndex = 0; saveIndex < _recentSavesList.length(); saveIndex++) {
        // If a matching file is found, remove it from the list and break.
        if (saveFilePath == _recentSavesList[saveIndex]) {
            _recentSavesList.removeAt(saveIndex);
            break;
        }
    }

    // Insert the new entry at the front of the list.
    _recentSavesList.insert(0, saveFilePath);

    // Iterate over the entire list to remove any invalid or unneccesary entries.
    int recentSavesCount = 1;
    for (int saveIndex = 0; saveIndex < _recentSavesList.length(); saveIndex++) {
        // REMOVAL CASES.
        // If the current save file no longer exists in the file system, remove it.
        bool fileNoLongerExists = !fileExists(_recentSavesList[saveIndex].toLocalFile().toStdString());
        // If the current save count extends beyond the maximum # of recent entries, remove it.
        bool fileIsOutdated = recentSavesCount > MAX_RECENT_SAVES;

        // Compare all cases. If at least one is flagged, remove the save from the list.
        if (fileNoLongerExists || fileIsOutdated) {
            _recentSavesList.removeAt(saveIndex);
            // Update the reference length for the full recent saves list.
            recentSavesCount -= 1;
        }

        // Increment the # of recent saves that still remain. If one was removes, returns count to correct value.
        recentSavesCount += 1;
    }

    // Refresh the save list shown to the user and return.
    refreshRecentSaves();
    return true;
}
