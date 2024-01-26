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

    Q_PROPERTY(int defense MEMBER defense NOTIFY defenseChanged)
    Q_PROPERTY(int costInRupees MEMBER costInRupees NOTIFY costInRupeesChanged)

public:
    Upgrade(QObject *parent = nullptr);
    Upgrade(int upgradeDefense, int upgradeCostInRupees, QObject *parent = nullptr);

    // CLASS VARIABLES.
    int defense;
    int costInRupees;

    // Item List Methods.
    Q_INVOKABLE QList<Item*> getFullItemList();
    void addItem(QString name, int quantity);
    int getItemQuantityByName(QString itemName);
    int getItemCount();
    void clear();

private:
    // List of required items is kept internal and interfaces via methods.
    QList<Item*> _requiredItems = QList<Item*>();

signals:
    void defenseChanged(int defense);
    void costInRupeesChanged(int costInRupees);
};

Q_DECLARE_METATYPE(Upgrade)

#endif // UPGRADE_H
