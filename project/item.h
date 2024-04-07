#ifndef ITEM_H
#define ITEM_H

#include <QString>
#include <QObject>
#include <QQmlEngine>

class Item : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString name MEMBER name NOTIFY nameChanged)
    Q_PROPERTY(int quantity MEMBER quantity NOTIFY quantityChanged)

public:
    Item(QString itemName, int itemQuantity, QObject *parent = nullptr);

    // Class variables.
    QString name;
    int quantity;

signals:
    void nameChanged(QString name);
    void quantityChanged(int quantity);
};

Q_DECLARE_METATYPE(Item)

#endif // ITEM_H
