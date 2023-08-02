import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

Item {
    id: armorIconMain

    // PROPERTIES.
    // Display Settings.
    property string armorName: "Default Armor"
    property string armorIconUrl: "images/Default.png"
    property int currentRank: 0
    property bool isUpgradeable: true

    // Formatting.
    property bool darkModeEnabled: false
    property string nameColor: (darkModeEnabled) ? "white" : "black"
    property int namePointSize: 7

    // Selection.
    property bool selectable: true
    property bool selected: false

    // Sometimes having the width defined by childrenRect can cause
    // the control to randomly resize, so the icon is used instead
    // to basically the same effect.
    width: 100
    height: 100

    // Selection Designs.
    // Sits BEHIND other icons to prevent covering up other parts of the control.
    Rectangle {
        id: rectangle
        anchors.fill: parent
        visible: armorIconMain.selected

        color: "gray"
        radius: 10
    }

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

            // Change the text color based on dark mode settings and whether the armor is unlocked.
            color: (armorIconMain.selectable) ? armorIconMain.nameColor : "gray"
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
            // Only applicable if the armor can be upgraded.
            Repeater {
                model: (isUpgradeable) ? armorIconMain.currentRank : 0

                Image {
                    height: currentArmorLevelRow.height
                    width: height
                    source: (armorIconMain.darkModeEnabled) ? "images/Star Image.png" : "images/Star Image - Dark.png"
                    antialiasing: true
                }
            }
        }
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
