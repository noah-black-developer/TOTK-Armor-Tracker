#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include <QQmlEngine>
#include <QDebug>
#include <QList>
#include <AppFunctions.h>
#include <stdio.h>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <rapidxml-1.13/rapidxml.hpp>

using namespace rapidxml;

class AppController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit AppController(QObject *qmlRootObject, QObject *parent = nullptr);

    // GENERAL METHODS.
    Q_INVOKABLE bool initialize(QString armorConfigsPath);
    Q_INVOKABLE bool pullSave(QUrl saveFilePath);

    // APP ICON BAR METHODS.
    Q_INVOKABLE bool setSelectedArmor(QString armorName);
    Q_INVOKABLE void deselectAll();

private:
    QObject *_qmlRootObject;
    QObject *_selectedArmor;
    xml_document<> *_armorConfigsXmlDocument;

    QObject *_getArmorIconByName(QString armorName);
    std::vector<char> _readXmlToParseReadyObj(QString xmlFilePath);

};

#endif // APPCONTROLLER_H
