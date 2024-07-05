#include <filesystem>
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
    const QUrl url(u"qrc:/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

    // Create and register the app controller singleton.
    AppController *appController = new AppController();
    engine.rootContext()->setContextProperty("appController", appController);

    // Store any required constants as context properties.
    QDir savesDir = QDir(".");
    bool savesFolderFound = savesDir.cd("saves");
    if (!savesFolderFound) {
        // If the saves file does not yet exists, create it before continuing.
        qDebug() << "Saves folder could not be located. Creating new folder...";
        std::filesystem::create_directory(savesDir.absoluteFilePath("saves").toStdString());

        // Verify saves folder was successfully created.
        bool newSavesFolderFound = savesDir.cd("saves");
        if (!newSavesFolderFound)
        {
            // If, for any reason, the saves folder could not be created, log errors and quit.
            qDebug() << "Failed to create saves folder.";
            return 1;
        }
        else
        {
            qDebug() << "Saves folder initialized.";
        }
    }
    engine.rootContext()->setContextProperty("savesFolderPath", savesDir.absolutePath());

    // CHECK FOR COMMAND LINE ARGS.
    // Iterate over all provided command line args, starting from the first arg.
    for (int argIndex = 1; argIndex < argc; argIndex++)
    {
        // If user provided flags to print version information, write out the required info and exit.
        // AppController and other singletons are initialized so that this info is available.
        if (std::string(argv[argIndex]) == "--version")
        {
            printf("TOTK Armor Tracker %s\n", appController->appVersion.toStdString().c_str());
            return 0;
        }
    }

    // Run application.
    engine.load(url);
    int appReturn = app.exec();

    // After app quits, delete any remaining objects and return.
    return appReturn;
}
