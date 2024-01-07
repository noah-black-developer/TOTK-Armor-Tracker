#include "upgrade.h"

Upgrade::Upgrade(QObject *parent) : QObject(parent)
{

}

Upgrade::Upgrade(int upgradeDefense, int upgradeCostInRupees, QObject *parent) : QObject(parent)
{
    defense = upgradeDefense;
    costInRupees = upgradeCostInRupees;
}

// ITEM LIST METHODS.
// Used to manipulate and read out the required items in this upgrade tier.
void Upgrade::addItem(QString name, int quantity)
{
    // Build a new Item object and add it to the internal list.
    Item newItem = Item(name, quantity);
    _requiredItems.append(newItem);
    return;
}

QList<Item> Upgrade::getFullItemList()
{
    // List is returned as a QList of Item objects.
    return _requiredItems;
}

int Upgrade::getItemQuantityByName(QString itemName)
{
    // Iterate over all added items. Start with the quantity set as an invalid value -1.
    for (int itemIndex = 0; itemIndex < _requiredItems.count(); itemIndex++)
    {
        // If a matching item is found, return its quantity.
        Item currentItem = _requiredItems[itemIndex];
        if (currentItem.name == itemName) {
            return currentItem.quantity;
        }
    }

    // If a matching item could not be found, return -1 to indicate a failure.
    return -1;
}

int Upgrade::getItemCount()
{
    return _requiredItems.count();
}

void Upgrade::clear()
{
    _requiredItems.clear();
    return;
}
