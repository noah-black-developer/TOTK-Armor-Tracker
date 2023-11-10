#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include <QQmlEngine>
#include <armordata.h>

class AppController : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit AppController(QObject *parent = nullptr);

    Q_INVOKABLE ArmorData *getArmorData() const;

private:
    ArmorData *_armorData = new ArmorData();

};

#endif // APPCONTROLLER_H
