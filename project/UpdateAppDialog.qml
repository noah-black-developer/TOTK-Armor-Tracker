import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: updateAppDialog

    width: 400
    height: 600
    anchors.centerIn: parent
    title: "Update Application"
    standardButtons: Dialog.Close

    // Dialog for selecting new update files.
    FileDialog {
        id: selectUpdateFileDialog

        title: "Select Update File"
        nameFilters: ["Update File (TotkArmorTracker_*.zip)"]
    }

    // Contents column.
    ColumnLayout {
        id: mainColumn

        anchors {
            fill: parent
            margins: 10
        }

        // Update selection.
        RowLayout {
            id: updateSelectRow

            Layout.fillWidth: true
            Layout.preferredHeight: 20

            TextField {
                id: updateSelectTextEdit

                Layout.fillWidth: true
                placeholderText: "Update Package"
            }

            Button {
                id: updateSelectNewButton

                text: "Select"
                onClicked: selectUpdateFileDialog.open()
            }
        }

        // Separator.
        Rectangle {
            id: updateSelectSeparator

            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: Material.dividerColor
        }

        // Update Visuals. Includes map of potential inputs/outputs.
        Text {
            text: "<b>Current Version:</b> " + appController.appVersion
            color: Material.primaryTextColor
            Layout.fillWidth: true
        }
        Text {
            text: "<b>New Version:</b> ..."
            color: Material.primaryTextColor
            Layout.fillWidth: true
        }

        // Control Buttons.


        // Spacing object - pushes up all other elements.
        Item {
            Layout.fillHeight: true
        }
    }
}
