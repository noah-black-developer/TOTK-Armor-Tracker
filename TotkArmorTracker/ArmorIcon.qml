import QtQuick
import QtQuick.Controls

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
    property bool darkModeEnabled: true
    property int namePointSize: 7

    // Selection.
    property bool selectable: true
    property bool selected: false

    width: 90
    height: 100

    Rectangle {
        id: armorIconContentsFrame
        anchors.fill: parent
        color: "transparent"

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
                color: "#474747"
                opacity: 0.8
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
                // Function to catch any errors in armor level and return current star count.
                function getStarCount() {
                    if (armorIconMain.currentRank < 0) {
                        // If rank ever falls below 0, print error logs and clamp to 0.
                        console.log("Armor level for icon " + armorIconMain.armorName + " was below 0. Clamping value to 0.")
                        return 0
                    }
                    else if (armorIconMain.currentRank > 4) {
                        // If rank ever raises above 4, print error logs and clamp to 4.
                        console.log("Armor level for icon " + armorIconMain.armorName + " was above 4. Clamping value to 4.")
                        return 4
                    }
                    else {
                        // If no errors, return armor rank.
                        return armorIconMain.currentRank
                    }
                }

                model: getStarCount()

                Image {
                    required property int index

                    height: currentArmorLevelRow.height
                    width: height
                    fillMode: Image.PreserveAspectFit
                    mipmap: true

                    // Choose a filled or unfilled star, depending on the item's current rank.
                    source: (armorIconMain.darkModeEnabled) ? "images/closed-star-darkmode.svg" : "images/closed-star-lightmode.svg"
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

        // Whenever clicked, accesses methods in the AppController to handle selection/deselection.
        onClicked: {
            if(armorIconMain.selected) {
                AppController.deselectAll();
            }
            else {
                AppController.setSelectedArmor(armorIconMain.armorName);
            }
        }
    }
}
