#ifndef UPGRADE_H
#define UPGRADE_H

#include <QList>
#include <QObject>
#include <QQmlEngine>
#include <item.h>

class Upgrade : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    Upgrade(QObject *parent = nullptr);
    Upgrade(int upgradeDefense, int upgradeCostInRupees, QObject *parent = nullptr);

    // CLASS VARIABLES.
    int defense;
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

Q_DECLARE_METATYPE(Upgrade)

#endif // UPGRADE_H
