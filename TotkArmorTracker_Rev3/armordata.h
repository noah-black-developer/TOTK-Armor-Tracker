#ifndef ARMORDATA_H
#define ARMORDATA_H

#include <QAbstractListModel>
#include <QQmlEngine>
#include <QVariant>
#include <armor.h>

class ArmorData : public QAbstractListModel
{
    Q_OBJECT

public:
    enum ArmorRoles {
        NameRole = Qt::UserRole + 1,
        SetNameRole,
        SetDescRole,
        PassiveBonusRole,
        SetBonusRole,
        LevelRole
    } ArmorRoles;

    ArmorData(QObject *parent = nullptr);

    QHash<int, QByteArray> roleNames() const;
    int rowCount(const QModelIndex &parent) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

private:
    QList<Armor> _mDatas;
    QObject *_parent;
};

#endif // ARMORDATA_H
