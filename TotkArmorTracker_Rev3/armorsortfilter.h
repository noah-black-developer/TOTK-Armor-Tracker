#ifndef ARMORSORTFILTER_H
#define ARMORSORTFILTER_H

#include <QObject>
#include <QSortFilterProxyModel>
#include <armordata.h>

class ArmorSortFilter : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QString sortType READ currentSortType NOTIFY sortTypeChanged)
    Q_PROPERTY(bool sortAsc READ currentSortIsAsc NOTIFY sortDirectionChanged)

public:
    ArmorSortFilter(ArmorData *sourceArmorData);

    // Custom method to get source model as ArmorModel pointer.
    ArmorData *model();

    Q_INVOKABLE void setSortType(QString sortName);
    Q_INVOKABLE void setSortDirection(bool ascending);

    QString currentSortType() const;
    bool currentSortIsAsc() const;

private:
    QString _currentSortType;
    bool _currentSortIsAsc;

signals:
    void sortTypeChanged(QString sortType);
    void sortDirectionChanged(bool sortIsAsc);
};

#endif // ARMORSORTFILTER_H
