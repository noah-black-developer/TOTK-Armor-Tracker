#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include <QQmlEngine>
#include <QDebug>
#include <QList>
#include <stdio.h>
#include <stdlib.h>
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
    Q_INVOKABLE bool setArmorSort(QString sortName);

    // ARMOR DETAIL METHODS.
    Q_INVOKABLE void setArmorUnlockedState(QString armorName, bool unlock);
    Q_INVOKABLE void setArmorLevel(QString armorName, int newLevel);

private:
    QString _armorConfigsPath = "";
    QObject *_qmlRootObject = nullptr;
    QObject *_selectedArmor = nullptr;
    QString _currentSort = "";

    QObject *_getArmorIconByName(QString armorName);
    bool _setArmorDetailsByName(QString armorName);
    bool _setArmorDetailsToDefault();
    std::vector<char> _readXmlToParseReadyObj(QString xmlFilePath);

};

#endif // APPCONTROLLER_H
