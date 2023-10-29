#include "armordata.h"

ArmorData::ArmorData(QObject *parent) : QAbstractListModel(parent)
{
    _parent = parent;
}

QHash<int, QByteArray> ArmorData::roleNames() {
    return { { NameRole, "name" },
            { SetNameRole, "setName" },
            { SetDescRole, "description" },
            { PassiveBonusRole, "passive"},
            { SetBonusRole, "setBonus"},
            { LevelRole, "level"}
            };
}

int ArmorData::rowCount(const QModelIndex &parent = QModelIndex())
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

QVariant ArmorData::data(const QModelIndex &index, int role)
{
    if (!hasIndex(index.row(), index.column(), index.parent()))
    {
        return {};
    }

    if (role == Qt::DisplayRole)
    {
        if (index.column() == 0) {
            return mDatas[index.row()].name;
        }
        if (index.column() == 1) {
            return mDatas[index.row()].setName;
        }
        if (index.column() == 2) {
            return mDatas[index.row()].setDesc;
        }
        if (index.column() == 3) {
            return mDatas[index.row()].passiveBonus;
        }
        if (index.column() == 4) {
            return mDatas[index.row()].setBonus;
        }
        if (index.column() == 5) {
            return mDatas[index.row()].level;
        }
    }

    return {};
}
