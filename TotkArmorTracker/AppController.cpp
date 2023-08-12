#include <AppController.h>

AppController::AppController(QObject *qmlRootObject, QObject *parent)
    : QObject{parent}
{
    _qmlRootObject = qmlRootObject;
}

bool AppController::initialize(QString armorConfigsPath)
{
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

    // Store the armor configs file for later use to prevent unneccesary file reads.
    _armorConfigsXmlDocument = armorConfigsFileXmlDocument;

    // LOAD IN ARMOR CONFIGS TO UI.
    // For each armor type, apply values for armor name, image,
    // and whether the armor can be upgraded or not.
    xml_node<char> *armorBaseNode = armorConfigsFileXmlDocument->first_node("ArmorData");
    for(xml_node<char> *armorNode = armorBaseNode->first_node(); armorNode != NULL; armorNode = armorNode->next_sibling())
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
    for (xml_node<char> *armorNode = armorsNode->first_node(); armorNode != NULL; armorNode = armorNode->next_sibling())
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
    return true;
}

void AppController::deselectAll() {
    // Deselect the current selection using local reference.
    QObject *currentSelectionObj = _getArmorIconByName(_selectedArmor->property("armorName").toString());
    currentSelectionObj->setProperty("selected", false);

    // Clear the local reference to selected objects and return.
    _selectedArmor = nullptr;
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
