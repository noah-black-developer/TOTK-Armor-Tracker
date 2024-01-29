import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: newSaveDialog

    readonly property int minimumArmorLevel: 0
    readonly property int maximumArmorLevel: 4

    signal newSaveCreated(string name)

    width: parent.width - 100
    height: parent.height - 100
    anchors.centerIn: parent
    title: "Create New Save"
    standardButtons: Dialog.Ok | Dialog.Cancel

    // By default, confirmation button is disabled until user input.
    Component.onCompleted: {
        standardButton(Dialog.Ok).enabled = nameTextInput.acceptableInput;
    }

    onOpened: {
        // Whenever the window is first opened, return the armor list to default settings
        nameTextInput.clear();
        appController.clearNewSaveArmorData();
        armorSetupView.forceLayout();
        armorSetupView.positionViewAtBeginning();
    }

    onAccepted: {
        var saveResult = appController.createNewSave(nameTextInput.text);
        if (saveResult === true)
        {
            newSaveDialog.newSaveCreated(nameTextInput.text);
        }
    }

    SystemPalette {
        id: systemPalette
        colorGroup: SystemPalette.Active
    }

    // SAVE DATA ENTRY FIELDS.
    RowLayout {
        id: nameRow

        height: 30
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 60
            rightMargin: 60
        }

        Label {
            id: newSaveNameLabel
            text: "Name: "
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            verticalAlignment: Qt.AlignVCenter
        }

        TextField {
            id: nameTextInput

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            // Valid file names allow characters, dashes, underscores, and spaces.
            validator: RegularExpressionValidator { regularExpression: /^[\w\- ]+$/ }
            placeholderText: "Save Name"

            // Update the "OK" button every time the user edits the field.
            onTextChanged: {
                createNewSaveDialog.standardButton(Dialog.Ok).enabled = acceptableInput;
            }
        }
    }

    // ARMOR LIST SORTING.

    // ARMOR LIST.
    Rectangle {
        id: armorSetupViewFrame

        anchors {
            top: nameRow.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }
        // Add some padding to help with rendering the different list elements properly.
        height: parent.height + 40
        color: "transparent"
        border.color: Material.accentColor
        border.width: 2
        radius: 5

        Rectangle {
            id: armorSetupViewBackground

            anchors {
                fill: parent
                margins: 5
            }
            color: Material.backgroundColor
            radius: 3
        }
    }

    GridView {
        id: armorSetupView

        anchors {
            fill: armorSetupViewFrame
            margins: 15
        }
        clip: true
        cellWidth: 200
        cellHeight: 80
        // Set width up to allow for 3 columns.
        width: cellWidth * 3

        model: appController.getNewSaveArmorData();
        delegate: Item {
            id: armorRoot

            property string armorName: name
            property int armorLevel: level
            property bool armorIsUnlocked: isUnlocked
            property bool armorIsUpgradeable: isUpgradeable

            width: armorSetupView.cellWidth
            height: armorSetupView.cellHeight

            Rectangle {
                id: armorRootRect

                anchors {
                    fill: parent
                    margins: 5
                }
                radius: 5
                color: Material.dialogColor

                ColumnLayout {
                    id: armorContentColumn

                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 5
                        bottomMargin: 5
                    }

                    Text {
                        id: armorNameText

                        Layout.fillWidth: true
                        text: armorRoot.armorName
                        color: Material.primaryTextColor
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                        minimumPointSize: 5
                        fontSizeMode: Text.Fit
                    }

                    RowLayout {
                        id: armorDetailsRow

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Image {
                            id: armorImage

                            Layout.preferredHeight: parent.height
                            Layout.preferredWidth: parent.height
                            Layout.alignment: Qt.AlignLeft
                            source: "images/" + name + ".png"
                            fillMode: Image.PreserveAspectFit

                            // If armor is unlocked, gray out picture.
                            Rectangle {
                                anchors.fill: parent
                                color: "gray"
                                opacity: 0.5
                                visible: !armorRoot.armorIsUnlocked
                            }
                        }

                        IconImage {
                            id: armorUnlockedIcon

                            Layout.preferredWidth: 12
                            Layout.preferredHeight: 12
                            Layout.leftMargin: 3
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            source: "images/lock-solid.svg"
                            color: Material.primaryTextColor
                            fillMode: IconImage.PreserveAspectFit
                            visible: !armorRoot.armorIsUnlocked
                        }

                        Repeater {
                            model: armorRoot.armorLevel
                            delegate: IconImage {
                                id: armorLevelIcon

                                Layout.preferredWidth: 12
                                Layout.preferredHeight: 12
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                source: "images/star-solid.svg"
                                color: Material.primaryTextColor
                                fillMode: IconImage.PreserveAspectFit
                                visible: armorRoot.armorIsUnlocked
                            }
                        }

                        // SPACER.
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        // LEVEL MODIFIERS.
                        RowLayout {
                            id: armorLevelColumnLayout

                            Layout.fillHeight: true
                            Layout.topMargin: 2
                            Layout.bottomMargin: 2
                            spacing: 2

                            Rectangle {
                                id: armorLevelDownButton

                                Layout.preferredWidth: 25
                                Layout.fillHeight: true
                                color: (enabled) ? Material.frameColor : Material.backgroundDimColor
                                radius: 2
                                visible: armorRoot.armorIsUpgradeable
                                // Enabled as long as the armor is unlocked (since level can be reduced until it locks).
                                enabled: armorRoot.armorIsUnlocked

                                Text {
                                    id: armorLevelDownText

                                    anchors.fill: parent
                                    text: "-"
                                    font.pointSize: 11
                                    font.bold: true
                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter
                                    color: Material.primaryTextColor

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            // If the armor is being reduced to below 0, lock it instead.
                                            if (armorRoot.armorLevel === minimumArmorLevel) {
                                                appController.toggleArmorUnlock(armorRoot.armorName, true);
                                            }
                                            // Otherwise, decrease the armor level.
                                            else {
                                                appController.decreaseArmorLevel(armorRoot.armorName, true);
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: armorLevelUpButton

                                Layout.preferredWidth: 25
                                Layout.fillHeight: true
                                color: (enabled) ? Material.frameColor : Material.backgroundDimColor
                                radius: 2
                                visible: armorRoot.armorIsUpgradeable
                                // Enabled as long as the armor is below the maximum level.
                                enabled: (armorRoot.armorLevel < maximumArmorLevel)

                                Text {
                                    id: armorLevelUpText

                                    anchors.fill: parent
                                    text: "+"
                                    font.pointSize: 11
                                    font.bold: true
                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter
                                    color: Material.primaryTextColor

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            // If armor is locked, unlock it.
                                            if (!armorRoot.armorIsUnlocked) {
                                                appController.toggleArmorUnlock(armorRoot.armorName, true);
                                            }
                                            // Otherwise, increase the armor level.
                                            else {
                                                appController.increaseArmorLevel(armorRoot.armorName, true);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
