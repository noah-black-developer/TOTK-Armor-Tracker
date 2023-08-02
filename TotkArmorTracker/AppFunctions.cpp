// Implementation file, defining high-level functions for the armor tracker.
// Uses lower-level functions to expose methods into related QML files.
//  ex. manipulating user saves, reading user inputs, etc...

#include <QDebug>
#include <QList>
#include <QObject>
#include <AppFunctions.h>
#include <stdio.h>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <rapidxml-1.13/rapidxml.hpp>

using namespace rapidxml;

// Function to initialize the UI armor settings at startup.
// Sources data from config XML files of a pre-set formatting.
// Inputs:
//  armorConfigsPath - Armor data configs. String absolute path to an XML config file.
// Output:
//  True if the UI was successfully initialized. Otherwise, if issues occur, false.
bool initialize(QString armorConfigsPath, QObject *qmlRootObject)
{
    // LOAD IN ARMOR CONFIG FILE.
    // Read in the config file as a string compatable with XML parsing.
    std::vector<char> parseReadyArmorConfigFile = readXmlToParseReadyObj(armorConfigsPath);

    // If the returned string is empty, return a failure.
    if(parseReadyArmorConfigFile == std::vector<char>('\0'))
    {
        return false;
    }

    // Convert the XML string into a RapidXML-compatable document object.
    // Make a safe-to-modify copy of the save file string to load into RapidXML.
    xml_document<> armorConfigsFileXmlDocument;
    armorConfigsFileXmlDocument.parse<0>(&parseReadyArmorConfigFile[0]);

    // LOAD IN ARMOR CONFIGS TO UI.
    // For each armor type, apply values for armor name, image,
    // and whether the armor can be upgraded or not.
    xml_node<char> *armorBaseNode = armorConfigsFileXmlDocument.first_node("ArmorData");
    for(xml_node<char> *armorNode = armorBaseNode->first_node(); armorNode != NULL; armorNode = armorNode->next_sibling())
    {
        // STORE ARMOR PROPERTIES.
        QString armorName = armorNode->first_attribute("name")->value();
        QString armorIconUrl = "images/" + armorName + ".png";
        QString armorIsUpgradeableVal = armorNode->first_node("CanBeUpgraded")->value();

        // APPLY PROPERTIES TO UI.
        // Locate the correct QML object by name.
        QObject *armorObj = qmlRootObject->findChild<QObject*>(armorName);

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

        // By default, all armor starts as locked until user save is loaded.
        armorObj->setProperty("selectable", false);
    }

    return true;
}

// Function to load a user's save and set it as the current save in the UI.
// Inputs:
//  saveFilePath - String representation of absolute path to save file.
// Outputs:
//  True if the save file was successfully loaded. Otherwise, false.
bool pullSave(QString saveFilePath, QObject *qmlRootObject)
{
    // Read in the save file as a string compatable with XML parsing.
    std::vector<char> parseReadySaveFile = readXmlToParseReadyObj(saveFilePath);

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
        QObject *armorObj = qmlRootObject->findChild<QObject*>(armorName);

        // If no object could be found, print an error and continue to the next armor type.
        if(armorObj == NULL)
        {
            qDebug("Armor from save file does not have an associated QML object.");
            qDebug("%s", armorNode->first_attribute("name")->value());
            continue;
        }

        // Set QML properties from the configs file.
        armorObj->setProperty("selectable", armorIsUnlocked);
        armorObj->setProperty("currentRank", armorLevel.toInt());
    }

    return true;
}


// HELPER FUNCTIONS.
// Load in an XML file at given path and convert it to a parse-ready char vector.
// Inputs:
//  xmlFilePath - Path to the XML file as a QString.
// Outputs:
//  char vector object, formatted for parsing using RapidXML.
//  If XML file could not be read, returns an empty char vector.
std::vector<char> readXmlToParseReadyObj(QString xmlFilePath)
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

