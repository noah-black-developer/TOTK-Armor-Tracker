#include "armorsortfilter.h"

ArmorSortFilter::ArmorSortFilter(ArmorData *sourceArmorData)
{
    // Apply given data source.
    setSourceModel(sourceArmorData);
}

ArmorData *ArmorSortFilter::model()
{
    return static_cast<ArmorData*>(sourceModel());
}

void ArmorSortFilter::setSortType(QString sortType)
{
    // Adjsut sort settings by case. Each sort type is given a specific default sort order.
    _currentSortType = sortType;
    if (sortType == "Name")
    {
        setSortRole(ArmorData::NameRole);
        _currentSortIsAsc = true;
    }
    else if (sortType == "Level")
    {
        setSortRole(ArmorData::LevelRole);
        _currentSortIsAsc = false;
    }
    else if (sortType == "Unlocked")
    {
        setSortRole(ArmorData::UnlockedRole);
        _currentSortIsAsc = false;
    }
    else
    {
        // Name is used as a default sort in cases where some unsupproted sort type was given.
        qDebug() << "Unsupported sort type found: " + sortType;
        setSortRole(ArmorData::NameRole);
        _currentSortIsAsc = true;
    }

    // Apply the new sort and return.
    sort(0, (_currentSortIsAsc) ? Qt::AscendingOrder : Qt::DescendingOrder);
    emit sortTypeChanged(_currentSortType);
    emit sortDirectionChanged(_currentSortIsAsc);
    return;
}

void ArmorSortFilter::setSortDirection(bool ascending)
{
    if (ascending)
    {
        sort(0, Qt::AscendingOrder);
    }
    else {
        sort(0, Qt::DescendingOrder);
    }
    _currentSortIsAsc = ascending;
    emit sortDirectionChanged(_currentSortIsAsc);
}

QString ArmorSortFilter::currentSortType() const
{
    return _currentSortType;
}

bool ArmorSortFilter::currentSortIsAsc() const
{
    return _currentSortIsAsc;
}
