#include "armorsortfilter.h"

ArmorSortFilter::ArmorSortFilter(ArmorData *sourceArmorData)
{
    // Apply given data source.
    setSourceModel(sourceArmorData);
}

bool ArmorSortFilter::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    // Grab a reference to the armor sets at the given indices.
    // Uses custom implementation of model() to get the underlying model as its base object type.
    int leftArmorIndex = source_left.row();
    Armor leftArmor = static_cast<ArmorData*>(sourceModel())->getArmorByIndex(leftArmorIndex);
    int rightArmorIndex = source_right.row();
    Armor rightArmor = static_cast<ArmorData*>(sourceModel())->getArmorByIndex(rightArmorIndex);

    // Otherwise, handle sorting by case.
    if (_currentSortType == "Name")
    {
        // For alphabetical sorting, use standard methods from QString to sort, maintaining sort direction.
        int compareVal = QString::compare(leftArmor.name, rightArmor.name, Qt::CaseInsensitive);
        return compareVal < 0;
    }
    else if (_currentSortType == "Level")
    {
        // Sort depending on the unlock states of both armor sets.
        if (!leftArmor.isUnlocked && !rightArmor.isUnlocked)
        {
            // In cases where BOTH armor sets are still locked, default to alphabetical sort.
            // For alphabetical sorting, use standard methods from QString to sort and ignore sort direction.
            int compareVal = QString::compare(leftArmor.name, rightArmor.name, Qt::CaseInsensitive);
            return (_currentSortIsAsc) ? compareVal < 0 : compareVal > 0;
        }
        else if (leftArmor.isUnlocked && !rightArmor.isUnlocked)
        {
            // Check the unlock states of both armor sets. If one or the other are locked, but not both,
            // sort so that the unlocked set will always appear later in the list, regardless of sort direction.
            return _currentSortIsAsc;
        }
        else if (!leftArmor.isUnlocked && rightArmor.isUnlocked)
        {
            // Check the unlock states of both armor sets. If one or the other are locked, but not both,
            // sort so that the unlocked set will always appear later in the list, regardless of sort direction.
            return !_currentSortIsAsc;
        }
        else
        {
            // If both armor sets are the SAME level, fall back to alphabetical sorting.
            if (leftArmor.level == rightArmor.level)
            {
                // For alphabetical sorting, use standard methods from QString to sort and ignore sort direction.
                int compareVal = QString::compare(leftArmor.name, rightArmor.name, Qt::CaseInsensitive);
                return (_currentSortIsAsc) ? compareVal < 0 : compareVal > 0;
            }

            // Otherwise, return based on level comparisons.
            return leftArmor.level < rightArmor.level;
        }

    }
    else if (_currentSortType == "Unlocked")
    {
        // Sort depending on the unlock states of both armor sets.
        if ((leftArmor.isUnlocked && rightArmor.isUnlocked) || (!leftArmor.isUnlocked && !rightArmor.isUnlocked))
        {
            // If both sets are in the same unlock state, default to alphabetical sorting.
            // For alphabetical sorting, use standard methods from QString to sort and ignore sort direction.
            int compareVal = QString::compare(leftArmor.name, rightArmor.name, Qt::CaseInsensitive);
            return (_currentSortIsAsc) ? compareVal < 0 : compareVal > 0;
        }
        else {
            // Otherwise, return depending on which set is unlocked between the two.
            return leftArmor.isUnlocked;
        }
    }
    else
    {
        // If an unsupported sort is found, print errors and default to alphabetical sorting.
        qDebug() << "ERROR - Unsupported sort found: " + _currentSortType;
        return false;
    }
}

ArmorData *ArmorSortFilter::model()
{
    return static_cast<ArmorData*>(sourceModel());
}

void ArmorSortFilter::setSortType(QString sortType)
{
    // Store the new sort type internally and resort.
    _currentSortType = sortType;
    sort(0, (_currentSortIsAsc) ? Qt::AscendingOrder : Qt::DescendingOrder);
    invalidate();
    return;
}

void ArmorSortFilter::setSortDirection(bool ascending)
{
    // Store the new sort direction and resort.
    _currentSortIsAsc = ascending;
    sort(0, (_currentSortIsAsc) ? Qt::AscendingOrder : Qt::DescendingOrder);
    invalidate();
    return;
}

QString ArmorSortFilter::currentSortType() const
{
    return _currentSortType;
}

bool ArmorSortFilter::currentSortIsAsc() const
{
    return _currentSortIsAsc;
}
