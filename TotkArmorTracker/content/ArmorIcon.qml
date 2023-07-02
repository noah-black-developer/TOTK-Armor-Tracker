import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes

Item {
    id: armorIconMain

    // Item Definitions
    property string armorName: "Default Armor"
    property string armorIconUrl: "images/Default.png"
    property int currentRank: 0
    property bool darkModeEnabled: false
    property int namePointSize: 7

    // Sometimes having the width defined by childrenRect can cause
    // the control to randomly resize, so the icon is used instead
    // to basically the same effect.
    width: 80
    height: childrenRect.height

    // Armor Image
    Image {
        id: armorImage
        width: parent.width

        source: parent.armorIconUrl
        fillMode: Image.PreserveAspectFit
        antialiasing: true
    }

    // Armor Name.
    Label {
        id: armorNameLabel
        // Scale the label as a proportion of the main icon.
        height: armorImage.height / 6
        width: armorImage.width
        horizontalAlignment: Text.AlignHCenter
        anchors.top: armorImage.bottom
        anchors.horizontalCenter: armorImage.horizontalCenter
        text: parent.armorName

        // Change the text color based on dark mode settings.
        color: (armorIconMain.darkModeEnabled) ? "white" : "black"

        font.bold: true
        font.pointSize: armorIconMain.namePointSize
    }

    // Current Armor Level.
    // Adjusted based on current state.
    Row {
        id: currentArmorLevelRow
        // Scale the stars based on a proportion of the main icon.
        height: armorImage.height / 6
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: armorNameLabel.bottom

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
