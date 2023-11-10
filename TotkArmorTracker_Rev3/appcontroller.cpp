#include "appcontroller.h"

AppController::AppController(QObject *parent) : QObject{parent}
{
    // TEMP: Load in armor data.
    _armorData->loadArmorDataFromFile(QString("/home/noah/Documents/GitHub/TOTK-Armor-Tracker/TotkArmorTracker_Rev3/data/armorData.xml"));
}

ArmorData *AppController::getArmorData() const
{
    return _armorData;
}
