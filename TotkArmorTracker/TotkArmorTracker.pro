QT += quick

SOURCES += \
        AppController.cpp \
        AppFunctions.cpp \
        main.cpp

HEADERS += \
    AppController.h \
    AppFunctions.h \
    rapidxml-1.13/rapidxml.hpp \
    rapidxml-1.13/rapidxml_iterators.hpp \
    rapidxml-1.13/rapidxml_print.hpp \
    rapidxml-1.13/rapidxml_utils.hpp

resources.files = main.qml 
resources.prefix = /$${TARGET}
RESOURCES += resources \
    qml.qrc \
    $$files(images/*.png)

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    App.qml \
    ArmorIcon.qml \
    ArmorProgressPage.qml \
    MainWindow.qml \
    data/armorData.xml \
    images/* \
    rapidxml-1.13/license.txt \
    rapidxml-1.13/manual.html
