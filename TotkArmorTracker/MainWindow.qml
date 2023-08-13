import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: rectangle

    StackLayout {
        id: stackLayout

        anchors.fill: parent
        // TODO - Add in a control to toggle the active window.
        currentIndex: 0

        // Page 1 - Armor Progress
        // Tracks what armor pieces are unlocked, current tiers, etc.
        ArmorProgressPage {
            id: mainWindowArmorProgressPage

            objectName: "mainWindowArmorProgressPage"
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
