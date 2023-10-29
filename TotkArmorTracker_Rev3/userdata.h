#ifndef USERDATA_H
#define USERDATA_H

#include <QObject>
#include <QQmlEngine>

class UserData : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit UserData(QObject *parent = nullptr);

signals:

};

#endif // USERDATA_H
