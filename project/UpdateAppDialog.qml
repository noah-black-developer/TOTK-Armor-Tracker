import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: updateAppDialog

    width: 350
    height: 500
    anchors.centerIn: parent
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
        spacing: 0

        // Update Visuals. Includes map of potential inputs/outputs.
        Text {
            id: currentVersionLabel

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            text: "Current Version:"
            horizontalAlignment: Qt.AlignHCenter
            color: Material.primaryTextColor
            font.bold: true
            font.pointSize: 12
        }
        Text {
            id: currentVersionText

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 5
            text: appController.appVersion
            horizontalAlignment: Qt.AlignHCenter
            color: Material.primaryTextColor
            font.pointSize: 12
        }

        // Separator.
        Rectangle {
            id: updateSelectSeparator

            Layout.fillWidth: true
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            Layout.preferredHeight: 2
            color: Material.dividerColor
        }

        // Version update controls, etc.
        Text {
            id: updateControlsLabel

            Layout.fillWidth: true
            Layout.preferredHeight: 20
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            Layout.alignment: Qt.AlignLeft
            text: "Updating the App"
            horizontalAlignment: Qt.AlignLeft
            font.italic: true
            color: Material.secondaryTextColor
            font.pointSize: 10
        }

        Button {
            id: updateVersionButton

            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.alignment: Qt.AlignHCenter
            text: "Update App Version"
        }

        // Save manipulation controls.
        Text {
            id: manipulateSavesLabel

            Layout.fillWidth: true
            Layout.preferredHeight: 20
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            Layout.alignment: Qt.AlignLeft
            text: "Move Existing Save Files"
            horizontalAlignment: Qt.AlignLeft
            font.italic: true
            color: Material.secondaryTextColor
            font.pointSize: 10
        }

        Button {
            id: importSavesButton

            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.bottomMargin: -5
            Layout.alignment: Qt.AlignHCenter
            text: "Import Saves"
        }
        Button {
            id: exportSavesButton

            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.alignment: Qt.AlignHCenter
            text: "Export Saves"
        }

        // Backup/loading controls.
        Text {
            id: backupsLabel

            Layout.fillWidth: true
            Layout.preferredHeight: 20
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            Layout.alignment: Qt.AlignLeft
            text: "Data Backups"
            horizontalAlignment: Qt.AlignLeft
            font.italic: true
            color: Material.secondaryTextColor
            font.pointSize: 10
        }

        Button {
            id: createBackupButton

            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.bottomMargin: -5
            Layout.alignment: Qt.AlignHCenter
            text: "Create Save Backup"

            // CURRENTLY UNSUPPORTED.
            enabled: false
        }
        Button {
            id: importBackupButton

            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.alignment: Qt.AlignHCenter
            text: "Import Save Backup"

            // CURRENTLY UNSUPPORTED.
            enabled: false
        }

        // Spacing object - pushes up all other elements.
        Item {
            Layout.fillHeight: true
        }

        // Default tooltip display location.
        Item {
            id: tooltipDisplayItem

            Layout.fillWidth: true
            Layout.preferredHeight: 20
        }
    }
}
