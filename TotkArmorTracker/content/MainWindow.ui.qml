

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.2
import QtQuick.Controls 6.2
import TotkArmorTracker
import QtQuick.Layouts
import QtCharts
import QtQuick.Effects
import QtQuick.Studio.Components
import QtQuick.Studio.Effects
import QtQuick.Studio.LogicHelper
import QtQuick.Studio.MultiText
import QtQuick.Studio.Application
import QtQuick.Timeline
import QtQuick.Window

Rectangle {
    id: rectangle
    width: Constants.width
    height: Constants.height

    color: Constants.backgroundColor

    TabBar {
        id: tabBar
        anchors.top: menuBar.bottom

        TabButton {
            id: tabButton
            text: qsTr("Armor Progress")
        }

        TabButton {
            id: tabButton1
            text: qsTr("Tracker")
        }

        TabButton {
            id: tabButton2
            text: qsTr("Inventory")
        }
    }
    StackLayout {
        id: stackLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: tabBar.bottom
        anchors.bottom: parent.bottom
        currentIndex: tabBar.currentIndex
    }
}
