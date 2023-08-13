#include <AppController.h>

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
    // For each armor type, apply values for armor name, image,
    // and whether the armor can be upgraded or not.
    xml_node<char> *armorBaseNode = armorConfigsFileXmlDocument->first_node("ArmorData");
    for(xml_node<char> *armorNode = armorBaseNode->first_node(); armorNode != 0; armorNode = armorNode->next_sibling())
    {
        // STORE ARMOR PROPERTIES.
        QString armorName = armorNode->first_attribute("name")->value();
        QString armorIconUrl = "images/" + armorName + ".png";
        QString armorIsUpgradeableVal = armorNode->first_node("CanBeUpgraded")->value();

        // APPLY PROPERTIES TO UI.
        // Locate the correct QML object by name.
        QObject *armorObj = _qmlRootObject->findChild<QObject*>(armorName);

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
        // Locate the correct QML object by name.
        QObject *armorObj = _qmlRootObject->findChild<QObject*>(armorName);

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

// Private method to get the associated ArmorIcon object for a given armor name.
// Inputs:
//  armorName - Name of the armor to select, as a QString.
// Outputs:
//  Returns a pointer to the ArmorIcon object, if successful. Otherwise, returns a nullptr.
QObject* AppController::_getArmorIconByName(QString armorName) {
    // Search for the object. If not found, findChild auto-returns a nullptr.
    return _qmlRootObject->findChild<QObject*>(armorName);
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

    // LOAD IN ANY REQUIRED UI STATE.
    // Pull in the armor's unlock status and what level it is at.
    QObject *armorObj = _getArmorIconByName(armorName);
    bool armorIsUnlocked = armorObj->property("isUnlocked").toBool();
    int armorLevel = armorObj->property("currentRank").toInt();

    // APPLY GENERAL ARMOR DATA.
    // Set the name of the armor.
    _qmlRootObject->findChild<QObject*>("selectedArmorNameLabel")->setProperty("text", armorName);

    // Set the set name of the armor.
    QString armorSetName = armorNode->first_node("SetName")->value();
    _qmlRootObject->findChild<QObject*>("selectedArmorSetNameLabel")->setProperty("text", armorSetName);

    // Set the desciption of the armor.
    QString armorDescription = armorNode->first_node("Description")->value();
    _qmlRootObject->findChild<QObject*>("selectedArmorQuoteLabel")->setProperty("text", "\"" + armorDescription + "\"");

    // Set whether the armor is currently unlocked or not.
    _qmlRootObject->findChild<QObject*>("selectedArmorUnlockedLabel")->setProperty("isUnlocked", armorIsUnlocked);

    // Set armor defense level.
    // Displayed value is determined based on the armor's current level.

    // Set armor passive bonus.
    QString armorPassiveBonus = armorNode->first_node("PassiveBonus")->value();
    _qmlRootObject->findChild<QObject*>("selectedArmorPassiveLabel")->setProperty("passiveBonus", armorPassiveBonus);

    // Set armor set bonus.
    QString armorSetBonus = armorNode->first_node("SetBonus")->value();
    _qmlRootObject->findChild<QObject*>("selectedArmorSetBonusLabel")->setProperty("setBonus", armorSetBonus);

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

        // Zero out most of the text fields from the user.
        _qmlRootObject->findChild<QObject*>("selectedArmorNameLabel")->setProperty("text", "");
        _qmlRootObject->findChild<QObject*>("selectedArmorSetNameLabel")->setProperty("text", "");
        _qmlRootObject->findChild<QObject*>("selectedArmorUnlockedLabel")->setProperty("text", "");
        _qmlRootObject->findChild<QObject*>("selectedArmorDefenseLabel")->setProperty("text", "");
        _qmlRootObject->findChild<QObject*>("selectedArmorPassiveLabel")->setProperty("text", "");
        _qmlRootObject->findChild<QObject*>("selectedArmorSetBonusLabel")->setProperty("text", "");

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
