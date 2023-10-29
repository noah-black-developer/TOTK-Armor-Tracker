#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include <QQmlEngine>

class appcontroller : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit appcontroller(QObject *parent = nullptr);

signals:

};

#endif // APPCONTROLLER_H
