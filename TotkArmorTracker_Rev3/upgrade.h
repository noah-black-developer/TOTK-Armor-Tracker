#ifndef UPGRADE_H
#define UPGRADE_H

#include <QList>
#include <item.h>

class Upgrade
{
public:
    Upgrade();
    Upgrade(int upgradeDefence, int upgradeCostInRupees);

    // CLASS VARIABLES.
    int defence;
    int costInRupees;

    // Item List Methods.
    void addItem(QString name, int quantity);
    QList<Item> getFullItemList();
    int getItemQuantityByName(QString itemName);
    int getItemCount();
    void clear();


private:
    // List of required items is kept internal and interfaces via methods.
    QList<Item> _requiredItems = QList<Item>();
};

#endif // UPGRADE_H
