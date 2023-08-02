#include <AppController.h>
#include <AppFunctions.cpp>

AppController::AppController(QObject *qmlRootObject, QObject *parent)
    : QObject{parent}
{
    _qmlRootObject = qmlRootObject;
}

bool AppController::appInitialize(QString armorConfigsPath)
{
    return initialize(armorConfigsPath, _qmlRootObject);
}

bool AppController::appPullSave(QUrl saveFilePath)
{
    // Convert QUrl to QString. QML file dialogs return QUrl by default,
    // which must be converted to a local path before use in backend code.
    QString convertedSaveFilePath = saveFilePath.toLocalFile();

    return pullSave(convertedSaveFilePath, _qmlRootObject);
}
