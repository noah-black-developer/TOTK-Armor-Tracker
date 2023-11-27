import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

ApplicationWindow {
    id: appRoot

    readonly property int minimumArmorLevel: 0
    readonly property int maximumArmorLevel: 4

    width: 800
    height: 600
    visible: true
    title: qsTr("TOTK Armor Tracker")

    SystemPalette {
        id: systemPalette
        colorGroup: SystemPalette.Active
    }

    NewSaveDialog {
        id: createNewSaveDialog
    }

    FileDialog {
        id: loadSaveDialog

        title: "Load Save File"
        // The save folder needs to be given the "file" schema to allow the path to be read in as url.
        currentFolder: "file://" + savesFolderPath
        onAccepted: appController.loadUserData(selectedFile)
    }

    MessageDialog {
        id: userDataSavedDialog

        text: "Save is complete."
        buttons: MessageDialog.Ok
    }

    menuBar: MenuBar {
        id: menuBar

        Menu {
            title: "File"
            Action {
                text: "New"
                onTriggered: createNewSaveDialog.open()
            }
            Action {
                text: "Load"
                onTriggered: {
                    loadSaveDialog.open()
                }
            }
            Action { text: "Load Recent" }
            Action {
                // Disabled by default. Enabled when user loads save.
                enabled: appController.saveIsLoaded
                text: "Save"
                onTriggered: {
                    appController.saveUserData();
                    userDataSavedDialog.open();
                }
            }
            MenuSeparator { }
            Action {
                text: "Quit"
                onTriggered: Qt.quit()
            }
        }
    }

    Rectangle {
        id: gridBorder

        anchors {
            fill: parent
            margins: 10
        }
        color: systemPalette.alternateBase
        clip: true

        Rectangle {
            id: selectedArmorName

            height: 20
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 20
            }
            color: systemPalette.highlight

            Text {
                id: armorNameText

                anchors.centerIn: parent
                text: {
                    if (grid.currentIndex === -1) {
                        "No Armor Selected"
                    }
                    else {
                        grid.currentItem.armorName
                    }
                }
                color: systemPalette.highlightedText
            }
        }

        GridView {
            id: grid

            width: 500
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: selectedArmorName.bottom
                bottom: armorControlsRow.top
                margins: 10
            }
            clip: true

            cellWidth: 80
            cellHeight: 80

            // Disabled by default, enabled when user loads a save.
            interactive: appController.saveIsLoaded

            model: appController.getArmorData()
            delegate: Item {
                id: armorItem

                property bool armorIsUnlocked: isUnlocked
                property bool armorIsUpgradeable: isUpgradeable
                property string armorName: name
                property string armorLevel: level

                width: grid.cellWidth
                height: grid.cellHeight

                ColumnLayout {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }

                    Image {
                        source: "images/" + armorItem.armorName + ".png"
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                        // Armor Level Indicator.
                        Rectangle {
                            anchors {
                                right: parent.right
                                top: parent.top
                                rightMargin: 5
                                topMargin: 5
                            }
                            width: 15
                            height: 15
                            radius: 5
                            color: systemPalette.highlight
                            visible: isUpgradeable

                            Text {
                                anchors.fill: parent
                                text: level
                                font.pointSize: 8
                                horizontalAlignment: Qt.AlignHCenter
                                color: "white"
                            }
                        }

                        // "Locked" overlay.
                        Rectangle{
                            anchors.fill: parent
                            color: "gray"
                            opacity: 0.5
                            visible: !isUnlocked
                        }
                    }
                }

                MouseArea {
                    id: armorMouseArea
                    anchors.fill: parent
                    onClicked: {
                        // If a save is currently loaded, adjust selection accordingly.
                        if (appController.saveIsLoaded) {
                            grid.currentIndex = index
                        }
                    }
                }
            }
            highlight: Rectangle { color: systemPalette.highlight; radius: 5 }
            highlightMoveDuration: 75
            focus: true

            Keys.onTabPressed: {
                // If save is loaded, adjust current selection.
                if (appController.saveIsLoaded) {
                    if (currentIndex === count - 1) {
                        currentIndex = 0
                    }
                    else {
                        currentIndex += 1
                    }
                }
            }
            Keys.onBacktabPressed: {
                // If save is loaded, adjust current selection.
                if (appController.saveIsLoaded) {
                    if (currentIndex === 0) {
                        currentIndex = count - 1
                    }
                    else {
                        currentIndex -= 1
                    }
                }
            }

            // If user has not yet loaded a save, disable view and display following label.
            Rectangle {
                id: viewNotEnabledOverlay

                anchors.fill: parent
                color: "gray"
                opacity: 0.5

                // Visible by default, hidden when user loads a save.
                visible: !appController.saveIsLoaded
            }

            Rectangle {
                id: viewNotEnabledTextBox

                width: 100
                height: 60
                anchors.centerIn: parent
                color: systemPalette.alternateBase
                border.color: systemPalette.highlight
                border.width: 2

                // Visible by default, hidden when user loads a save.
                visible: !appController.saveIsLoaded

                Text {
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    text: "No save file loaded."
                    color: systemPalette.text
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            }
        }

        Text {
            id: loadedSaveNameText

            anchors {
                left: parent.left
                bottom: parent.bottom
                leftMargin: 10
                bottomMargin: 10
            }

            // Initially set to default value - updated when save is loaded.
            text: appController.saveName
            color: systemPalette.text
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
        }


        RowLayout {
            id: armorControlsRow

            height: 20
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                margins: 10
            }

            Button {
                id: unlockArmorButton

                icon.source: (grid.currentItem.armorIsUnlocked) ? "images/lock-solid.svg" : "images/unlock-solid.svg"
                icon.color: systemPalette.highlightedText
                Layout.fillHeight: true
                Layout.preferredWidth: 20
                Layout.alignment: Qt.AlignHCenter

                // Disabled until a save is loaded.
                enabled: appController.saveIsLoaded

                onClicked: {
                    appController.toggleArmorUnlock(grid.currentItem.armorName);
                }
            }

            Button {
                id: decreaseLevelButton
                text: "-"
                Layout.fillHeight: true
                Layout.preferredWidth: 20
                Layout.alignment: Qt.AlignHCenter

                // Only enabled if save is loaded, armor is unlocked,
                // armor is upgradeable, and is not at minimum level.
                enabled:
                    appController.saveIsLoaded &&
                    grid.currentItem.armorIsUnlocked &&
                    grid.currentItem.armorIsUpgradeable &&
                    (grid.currentItem.armorLevel > appRoot.minimumArmorLevel)

                onClicked: {
                    appController.decreaseArmorLevel(grid.currentItem.armorName);
                }
            }

            Button {
                id: increaseLevelButton
                text: "+"
                Layout.fillHeight: true
                Layout.preferredWidth: 20
                Layout.alignment: Qt.AlignHCenter

                // Only enabled if save is loaded, armor is unlocked,
                // armor is upgradeable, and is not at maximum level.
                enabled:
                    appController.saveIsLoaded &&
                    grid.currentItem.armorIsUnlocked &&
                    grid.currentItem.armorIsUpgradeable &&
                    (grid.currentItem.armorLevel < appRoot.maximumArmorLevel)

                onClicked: {
                    appController.increaseArmorLevel(grid.currentItem.armorName);
                }
            }
        }
    }
}
