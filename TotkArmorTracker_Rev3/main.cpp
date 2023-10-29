#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <armordata.h>

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

    // Pass any required singletons into the QML engine.
    ArmorData *tempArmorData = new ArmorData();
    engine.rootContext()->setContextProperty("testData", tempArmorData);

    // Run app. Any return codes given by the application are returned from this function.
    engine.load(url);
    return app.exec();
}
