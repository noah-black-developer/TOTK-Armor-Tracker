#ifndef ITEM_H
#define ITEM_H

#include <QString>

class Item
{
public:
    Item(QString itemName, int itemQuantity);

    // Class variables.
    QString name;
    int quantity;
};

#endif // ITEM_H
