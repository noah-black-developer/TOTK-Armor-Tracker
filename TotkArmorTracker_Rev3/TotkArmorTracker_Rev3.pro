QT += quick
QT += core

SOURCES += \
    appcontroller.cpp \
    armor.cpp \
    armordata.cpp \
    armorsortfilter.cpp \
    helper.cpp \
    item.cpp \
    main.cpp \
    upgrade.cpp \
    userdata.cpp

HEADERS += \
    appcontroller.h \
    armor.h \
    armordata.h \
    armorsortfilter.h \
    item.h \
    upgrade.h \
    userdata.h \
    # Required RapidXML Headers.
    rapidxml-1.13/rapidxml.hpp \
    rapidxml-1.13/rapidxml_iterators.hpp \
    rapidxml-1.13/rapidxml_print.hpp \
    rapidxml-1.13/rapidxml_utils.hpp

RESOURCES += qml.qrc \
    $$files(images/*.png, true) \
    $$files(images/*.svg, true)

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Create any required folders.
QMAKE_EXTRA_TARGETS += saves
saves.target = $$OUT_PWD/saves
saves.commands = $(MKDIR) $$OUT_PWD/saves

# Copy config file to build dir.
CONFIG += file_copies
COPIES += config
config.files = appData.xml
config.path = $$OUT_PWD

DISTFILES += \
    AppIcon.qml \
    NewSaveDialog.qml
