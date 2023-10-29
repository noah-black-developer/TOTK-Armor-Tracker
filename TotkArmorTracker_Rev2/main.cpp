#include <AppController.cpp>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

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

    // Register the controller class with the QML engine.
    AppController *appController = new AppController(qmlRootObject);
    engine.rootContext()->setContextProperty("AppController", appController);

    // Initialize the UI using local configuration files.
    engine.rootContext()->setContextProperty("appPath", QGuiApplication::applicationDirPath());
    appController->initialize(QString::fromStdString(R"(/home/noah/Documents/GitHub/TOTK-Armor-Tracker/TotkArmorTracker/data/armorData.xml)"));

    // Execute UI.
    int result = app.exec();

    // Return results once finished.
    delete appController;
    return result;
}
