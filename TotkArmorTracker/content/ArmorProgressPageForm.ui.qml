

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: rectangle1
    height: 900
    width: 1600

    Rectangle {
        id: leftControlsRectangle
        width: 280
        color: "#dedede"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        // Armor Icon (Buttons).
        // Show the user what armors they have unlocked and
        // what tier those armor pieces are currently at.
        ScrollView {
            id: armorIconsScrollView
            anchors.fill: parent

            // Manually set the child element's size to the icon column.
            contentHeight: armorIconsColumn.height
            contentWidth: armorIconsColumn.width

            // Sorting Column.
            Column {
                id: armorIconsColumn

                // Barbarian Set.
                Label {
                    id: barbarianSetLabel
                    text: "Barbarian Set"
                    font.bold: true
                }
                Row {
                    id: barbarianSetIconRow
                    spacing: 10

                    ArmorIcon {
                        id: barbarianHelmIcon
                        armorIconUrl: "images/Barbarian Helm.png"
                        armorName: "Barbarian Helm"
                    }
                    ArmorIcon {
                        id: barbarianArmorIcon
                        armorIconUrl: "images/Barbarian Armor.png"
                        armorName: "Barbarian Armor"
                    }
                    ArmorIcon {
                        id: barbarianLegWrapsIcon
                        armorIconUrl: "images/Barbarian Leg Wraps.png"
                        armorName: "Barbarian Leg Wraps"
                    }
                }

                // Hero Set.
                Label {
                    id: heroSetLabel
                    text: "Hero Set"
                    font.bold: true
                }
                Row {
                    id: heroSetIconRow
                    spacing: 10

                    ArmorIcon {
                        id: capOfTheHeroIcon
                        armorIconUrl: "images/Cap of the Hero.png"
                        armorName: "Cap of the Hero"
                    }
                    ArmorIcon {
                        id: tunicOfTheHeroIcon
                        armorIconUrl: "images/Tunic of the Hero.png"
                        armorName: "Tunic of the Hero"
                    }
                    ArmorIcon {
                        id: trousersOfTheHeroIcon
                        armorIconUrl: "images/Trousers of the Hero.png"
                        armorName: "Trousers of the Hero"
                    }
                }
            }
        }
    }

    Rectangle {
        id: rightControlsRectangle
        width: 400
        color: "#dedede"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
}
