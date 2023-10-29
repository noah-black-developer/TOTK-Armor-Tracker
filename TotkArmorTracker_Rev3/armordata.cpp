#include "armordata.h"

ArmorData::ArmorData(QObject *parent) : QAbstractListModel(parent)
{
    _parent = parent;
}

QHash<int, QByteArray> ArmorData::roleNames() const
{
    return { { NameRole, "name" },
            { SetNameRole, "setName" },
            { SetDescRole, "description" },
            { PassiveBonusRole, "passive"},
            { SetBonusRole, "setBonus"},
            { LevelRole, "level"}
            };
}

int ArmorData::rowCount(const QModelIndex &parent) const
{
    return _mDatas.size();
}

bool ArmorData::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!hasIndex(index.row(), index.column(), index.parent()) || !value.isValid())
        return false;

    Armor &armorItem = _mDatas[index.row()];
    if (role == NameRole)
    {
        armorItem.name = value.toString();
    }
    else if (role == SetNameRole)
    {
        armorItem.setName = value.toString();
    }
    else if (role == SetDescRole)
    {
        armorItem.setDesc = value.toString();
    }
    else if (role == PassiveBonusRole)
    {
        armorItem.passiveBonus = value.toString();
    }
    else if (role == SetBonusRole)
    {
        armorItem.setBonus = value.toString();
    }
    else if (role == LevelRole)
    {
        armorItem.level = value.toInt();
    }
    else {
        return false;
    }

    emit dataChanged(index, index, { role });

    return true;
}

QVariant ArmorData::data(const QModelIndex &index, int role) const
{
    if (!hasIndex(index.row(), index.column(), index.parent()))
    {
        return {};
    }

    const Armor &armorItem = _mDatas[index.row()];
    if (role == NameRole)
    {
        return armorItem.name;
    }
    if (role == SetNameRole)
    {
        return armorItem.setName;
    }
    if (role == SetDescRole)
    {
        return armorItem.setDesc;
    }
    if (role == PassiveBonusRole)
    {
        return armorItem.passiveBonus;
    }
    if (role == SetBonusRole)
    {
        return armorItem.setBonus;
    }
    if (role == LevelRole)
    {
        return armorItem.level;
    }

    return {};
}
