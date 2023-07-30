#include <appControl.cpp>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/App.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    // Pull the root object of the QML view.
    QList<QObject*> appRootObjects = engine.rootObjects();
    QObject *qmlRootObject = appRootObjects.first();

    // Initialize the UI using local configuration files.
    initialize(QString::fromStdString(R"(C:\Users\noahb\OneDrive\Documents\GitHub\TOTK-Armor-Tracker\TotkArmorTracker\data\armorData.xml)"), qmlRootObject);

    // TEMP: Load in a default save upon startup.
    // Eventually will be replaced with more specialized startup steps.
    //pullSave(QString::fromStdString(R"(C:\Users\noahb\OneDrive\Documents\GitHub\TOTK-Armor-Tracker\TotkArmorTracker\saves\test_save.xml)"), qmlRootObject);

    return app.exec();
}
