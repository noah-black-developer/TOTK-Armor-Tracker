import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: newSaveDialog

    signal newSaveCreated(string name)

    width: 400
    height: 300
    anchors.centerIn: parent
    title: "Create New Save"
    standardButtons: Dialog.Ok | Dialog.Cancel

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
            validator: RegularExpressionValidator { regularExpression: /^[\w\-. ]+$/ }

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
        }
        clip: true
        spacing: 5
        model: appController.getArmorData();
        delegate: Rectangle {
            id: armorRoot

            property bool armorIsUnlocked: isUnlocked
            property string armorName: name
            property string armorLevel: level

            height: 50
            width: armorSetupView.width
            color: systemPalette.alternateBase

            RowLayout {
                anchors {
                    fill: parent
                    margins: 5
                }

                Image {
                    id: armorImage

                    Layout.preferredWidth: parent.height
                    Layout.preferredHeight: parent.height
                    Layout.alignment: Qt.AlignLeft
                    source: "images/" + armorRoot.armorName + ".png"
                }
            }
        }
    }

    // By default, confirmation button is disabled until user input.
    Component.onCompleted: {
        standardButton(Dialog.Ok).enabled = nameTextInput.acceptableInput;
    }

    onAccepted: {
        var saveResult = appController.createNewSave(nameTextInput.text);
        if (saveResult === true)
        {
            newSaveDialog.newSaveCreated(nameTextInput.text);
        }
    }
}
