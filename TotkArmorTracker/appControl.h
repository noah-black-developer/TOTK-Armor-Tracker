#ifndef APPCONTROL_H
#define APPCONTROL_H

#include <QString>
#include <QObject>
#include <QQmlEngine>
#include <string>
#include <vector>

// Header file defining high-level functions for the armor tracker.
// Implement lower-level functions to expose methods to related QML files.
// Author: Noah Black
// Date: July 15th, 2023

// App startup functions.
bool initialize(QString armorConfigsPath, QObject *qmlRootObject);

// Loading/modifying save files.
bool pullSave(QString saveFilePath, QObject *qmlRootObject);
bool pushSave();
bool createNewSave();

// HELPER FUNCTIONS.
std::vector<char> readXmlToParseReadyObj(QString xmlFilePath);

#endif // APPCONTROL_H
