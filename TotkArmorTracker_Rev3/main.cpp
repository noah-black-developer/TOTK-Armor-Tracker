#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <appcontroller.h>

int main(int argc, char *argv[])
{
    // START APPLICATION.
    // Create a new GUI application object. Pass in command line args.
    QGuiApplication app(argc, argv);

    // Create the app engine and run. Loading in main .qml file as the starting point for execution.s
    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/TotkArmorTracker_Rev3/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

    // Create and register the app controller singleton.
    AppController *appController = new AppController();
    engine.rootContext()->setContextProperty("appController", appController);

    // Run application.
    engine.load(url);
    int appReturn = app.exec();

    // After app quits, delete any remaining objects and return.
    return appReturn;
}
