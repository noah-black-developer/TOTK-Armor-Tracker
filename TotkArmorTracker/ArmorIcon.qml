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
    property bool isUpgradeable: false
    property bool isUnlocked: false

    // Formatting.
    property bool darkModeEnabled: false
    property int namePointSize: 7

    // Selection.
    property bool selectable: true
    property bool selected: false

    width: 90
    height: 100

    Rectangle {
        id: armorIconContentsFrame
        anchors.fill: parent
        color: "#00ffffff"

        // Armor Image
        Image {
            id: armorImage

            width: 60
            height: 60
            // Image is centered in the control to allow stars + text to flow above/below more easily.
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            source: armorIconMain.armorIconUrl
            fillMode: Image.PreserveAspectFit
            antialiasing: true

            // If selected, add a border to the image.
            Rectangle {
                id: armorImageBorder

                anchors {
                    fill: parent
                    // Use negative margins to encircle the parent object.
                    margins: -7
                }
                visible: armorIconMain.selected
                border.color: "gray"
                border.width: 4
                color: "transparent"
            }

            // "Shader" Rectangle - Overlays image to give a grayscaled appearance.
            // Appears if the armor is not yet unlocked.
            Rectangle {
                id: armorImageShader

                anchors.fill: parent
                visible: !armorIconMain.isUnlocked
                color: "#7e474747"
            }
        }

        // Current Armor Level.
        // Adjusted based on current state.
        Row {
            id: currentArmorLevelRow

            height: 12
            anchors {
                bottom: armorImage.top
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 2
            }
            spacing: 2

            // Hide stars if the item inside is not upgradeable.
            visible: armorIconMain.isUpgradeable

            // Creates a num. of stars equal to current armor rank.
            // Only applicable if the armor can be upgraded.
            Repeater {
                model: 4

                Image {
                    required property int index

                    height: currentArmorLevelRow.height
                    width: height
                    fillMode: Image.PreserveAspectFit

                    // Choose a filled or unfilled star, depending on the item's current rank.
                    source: (index <= armorIconMain.currentRank - 1) ? "images/star-solid.svg" : "images/star-regular.svg"
                }
            }
        }

        // Armor Name.
        Label {
            id: armorNameLabel

            anchors {
                left: parent.left
                right: parent.right
                top: armorImage.bottom
                topMargin: 2
            }

            // Change the text color based on whether the armor is unlocked.
            color: (armorIconMain.isUnlocked) ? "black" : "gray"
            text: armorIconMain.armorName
            horizontalAlignment: Text.AlignHCenter

            font.bold: true
            font.pointSize: armorIconMain.namePointSize
            // If the text would extend past the full width of the control, wrap by word.
            wrapMode: Text.WordWrap
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
