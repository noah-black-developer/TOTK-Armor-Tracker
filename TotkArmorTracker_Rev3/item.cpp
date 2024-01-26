#include "item.h"

Item::Item(QString itemName, int itemQuantity, QObject *parent) : QObject(parent)
{
    name = itemName;
    quantity = itemQuantity;
}
