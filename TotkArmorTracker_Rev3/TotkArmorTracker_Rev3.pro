QT += quick
QT += core

SOURCES += \
        appcontroller.cpp \
        armor.cpp \
        armordata.cpp \
        helper.cpp \
        item.cpp \
        main.cpp \
        upgrade.cpp \
        userdata.cpp

HEADERS += \
    appcontroller.h \
    armor.h \
    armordata.h \
    item.h \
    upgrade.h \
    userdata.h \
    # Required RapidXML Headers.
    rapidxml-1.13/rapidxml.hpp \
    rapidxml-1.13/rapidxml_iterators.hpp \
    rapidxml-1.13/rapidxml_print.hpp \
    rapidxml-1.13/rapidxml_utils.hpp

resources.files = main.qml \
    $$files(images/*.png, true)
resources.prefix = /$${TARGET}
RESOURCES += resources

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
