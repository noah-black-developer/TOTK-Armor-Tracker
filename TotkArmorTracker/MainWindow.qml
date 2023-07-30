import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Window

Rectangle {
    id: rectangle

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

        // Page 1 - Armor Progress
        // Tracks what armor pieces are unlocked, current tiers, etc.
        ArmorProgressPage {
            id: mainWindowArmorProgressPage
            objectName: "mainWindowArmorProgressPage"
        }
    }
}
