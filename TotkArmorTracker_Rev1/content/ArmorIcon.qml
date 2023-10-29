import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes

Item {
    id: armorIconMain

    // Item Definitions
    property string armorName: "Default Armor"
    property string armorIconUrl: "images/Default.png"
    property int currentRank: 4
    property bool darkModeEnabled: false
    property int namePointSize: 7
    property bool selectable: true
    property bool selected: false

    // Sometimes having the width defined by childrenRect can cause
    // the control to randomly resize, so the icon is used instead
    // to basically the same effect.
    width: 100
    height: 100

    Rectangle {
        id: armorIconContentsFrame
        anchors.fill: parent
        anchors.margins: 5
        color: "#00ffffff"

        // Armor Image
        Image {
            id: armorImage
            anchors.top: parent.top
            anchors.bottom: armorNameLabel.top
            anchors.horizontalCenter: parent.horizontalCenter

            source: armorIconMain.armorIconUrl
            fillMode: Image.PreserveAspectFit
            antialiasing: true

            // "Shader" Rectangle - Overlays image to give a grayscaled appearance.
            Rectangle {
                id: armorImageShader
                anchors.fill: parent
                visible: !armorIconMain.selectable
                color: "#7e474747"
            }
        }

        // Armor Name.
        Label {
            id: armorNameLabel
            anchors.bottom: currentArmorLevelRow.top
            anchors.horizontalCenter: parent.horizontalCenter

            // Change the text color based on dark mode settings.
            color: (darkModeEnabled) ? "white" : "black"
            text: armorIconMain.armorName

            font.bold: true
            font.pointSize: armorIconMain.namePointSize
        }

        // Current Armor Level.
        // Adjusted based on current state.
        Row {
            id: currentArmorLevelRow
            height: 12
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: 3

            // Creates a num. of stars equal to current armor rank.
            Repeater {
                model: armorIconMain.currentRank

                Image {
                    height: currentArmorLevelRow.height
                    width: height
                    source: (armorIconMain.darkModeEnabled) ? "images/Star Image.png" : "images/Star Image - Dark.png"
                    antialiasing: true
                }
            }
        }
    }

    // Selection Designs.
    Rectangle {
        id: rectangle
        anchors.fill: parent
        visible: armorIconMain.selected

        color: "transparent"
        border.color: "black"
        radius: 10
        border.width: 2
    }

    // Click handler for the icon.
    MouseArea {
        id: iconMouseArea
        anchors.fill: parent
        enabled: armorIconMain.selectable

        onClicked: {
            armorIconMain.selected = !armorIconMain.selected
        }
    }
}
