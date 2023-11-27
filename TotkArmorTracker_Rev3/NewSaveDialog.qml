import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: newSaveDialog

    readonly property int minimumArmorLevel: 0
    readonly property int maximumArmorLevel: 4

    signal newSaveCreated(string name)

    width: 600
    height: 400
    anchors.centerIn: parent
    title: "Create New Save"
    standardButtons: Dialog.Ok | Dialog.Cancel

    // By default, confirmation button is disabled until user input.
    Component.onCompleted: {
        standardButton(Dialog.Ok).enabled = nameTextInput.acceptableInput;
    }

    onOpened: {
        // Whenever the window is first opened, return the armor list to default settings
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

            // Update the "OK" button every time the user edits the field.
            onTextChanged: {
                createNewSaveDialog.standardButton(Dialog.Ok).enabled = acceptableInput;
            }
        }
    }

    ListView {
        id: armorSetupView

        anchors {
            left: parent.left
            right: parent.right
            top: nameRow.bottom
            bottom: parent.bottom
            topMargin: 10
            leftMargin: 20
            rightMargin: 20
        }
        clip: true
        spacing: 5
        model: appController.getNewSaveArmorData();
        delegate: Rectangle {
            id: armorRoot

            property string armorName: name
            property bool armorIsUpgradeable: isUpgradeable
            property bool armorIsUnlocked: isUnlocked
            property int armorLevel: level

            height: 50
            width: armorSetupView.width
            color: systemPalette.alternateBase

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 10
                    rightMargin: 10
                    topMargin: 5
                    bottomMargin: 5
                }

                Image {
                    id: armorImage

                    Layout.preferredWidth: parent.height
                    Layout.preferredHeight: parent.height
                    Layout.alignment: Qt.AlignLeft
                    source: "images/" + armorRoot.armorName + ".png"

                    // If armor is unlocked, gray out picture.
                    Rectangle {
                        anchors.fill: parent
                        color: "gray"
                        opacity: 0.5
                        visible: !armorRoot.armorIsUnlocked
                    }
                }

                Text {
                    id: armorNameText

                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                    text: armorRoot.armorName
                    color: systemPalette.text
                }

                Button {
                    id: armorUnlockButton

                    icon.source: (armorRoot.armorIsUnlocked) ? "images/lock-solid.svg" : "images/unlock-solid.svg"
                    icon.color: systemPalette.highlightedText
                    Layout.preferredWidth: 25
                    Layout.preferredHeight: 25
                    Layout.alignment: Qt.AlignRight

                    onClicked: appController.toggleArmorUnlock(armorRoot.armorName, true)
                }

                // SPACER.
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Button {
                    id: armorLevelDownButton

                    text: "-"
                    Layout.preferredWidth: 25
                    Layout.preferredHeight: 25
                    Layout.alignment: Qt.AlignRight
                    // Enabled as long as armor is unlocked.
                    visible: armorRoot.armorIsUnlocked && armorRoot.armorIsUpgradeable

                    onClicked: armorLevelSlider.value -= 1
                }

                Slider {
                    id: armorLevelSlider

                    from: newSaveDialog.minimumArmorLevel
                    to: newSaveDialog.maximumArmorLevel
                    stepSize: 1
                    snapMode: Slider.SnapAlways
                    value: armorRoot.armorLevel
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: parent.height
                    Layout.alignment: Qt.AlignRight
                    // Enabled as long as armor is unlocked.
                    visible: armorRoot.armorIsUnlocked && armorRoot.armorIsUpgradeable

                    onValueChanged: {
                        if (armorRoot.armorLevel < value)
                        {
                            appController.increaseArmorLevel(armorRoot.armorName, true);
                        }
                        else {
                            appController.decreaseArmorLevel(armorRoot.armorName, true);
                        }
                    }
                }

                Button {
                    id: armorLevelUpButton

                    text: "+"
                    Layout.preferredWidth: 25
                    Layout.preferredHeight: 25
                    Layout.alignment: Qt.AlignRight
                    // Enabled as long as armor is unlocked.
                    visible: armorRoot.armorIsUnlocked && armorRoot.armorIsUpgradeable

                    onClicked: armorLevelSlider.value += 1
                }

                Text {
                    id: armorLevelText

                    text: "Level " + parseInt(armorRoot.armorLevel)
                    color: systemPalette.text
                    Layout.alignment: Qt.AlignRight
                    visible: armorRoot.armorIsUnlocked && armorRoot.armorIsUpgradeable
                }
            }
        }
    }
}
