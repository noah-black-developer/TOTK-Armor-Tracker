import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: updateAppDialog

    width: 400
    height: 500
    anchors.centerIn: parent
    standardButtons: Dialog.Close

    // HELPER FUNCTIONS.
    // Function to take in a QML url-type object for a local file, and return just the local file path.
    function urlToLocalPath(urlInput) {
        var path = urlInput.toString();
        path = path.replace(/^(file:\/{3})/,"");
        return decodeURIComponent(path);
    }

    // DIALOG WINDOWS.
    // Dialog for selecting external update packages.
    FileDialog {
        id: selectUpdatePackageDialog

        title: "Select Update File"
        nameFilters: ["Update File (TotkArmorTracker_*.zip)"]
    }

    // Dialogs for selecting external applications.
    FileDialog {
        id: selectExternalAppForExportDialog

        property bool validAppIsSelected: false

        title: "Select App To Export Save Files To"
        nameFilters: ["App (TotkArmorTracker.exe)", "App (TotkArmorTracker)"]
        onSelectedFileChanged: {
            // Validate selections as they are made for use externally.
            validAppIsSelected = appController.isGivenExternalAppValid(updateAppDialog.urlToLocalPath(selectedFile));
        }
    }
    FileDialog {
        id: selectExternalAppForImportDialog

        property bool validAppIsSelected: false

        title: "Select App To Import Save Files From"
        nameFilters: ["App (TotkArmorTracker.exe)", "App (TotkArmorTracker)"]
        onSelectedFileChanged: {
            // Validate selections as they are made for use externally.
            validAppIsSelected = appController.isGivenExternalAppValid(updateAppDialog.urlToLocalPath(selectedFile));
        }
    }

    // Self-contained dialog for exporting save files from an external application.
    Dialog {
        id: exportSaveFilesDialog

        width: updateAppDialog.width - 50
        standardButtons: Dialog.Close
    }

    // Self-contained dialog for exporting save files to an external application.
    Dialog {
        id: importSaveFilesDialog

        property var currentAppSaveNameList: []

        function checkForFileConflicts() {
            // VALIDATE INPUTS.
            // Verify the selected application + saves before continuing.
            // If any discrepancies are found, log errors and exit early.
            if (!availableSavesListView.savesAreSelected) {
                console.error("No saves were selected from external app, no save files could be imported.");
                return false;
            }

            // CHECK FOR OVERWRITES.
            // Compare the local and external save file lists. If any duplicates are found, raise flags.
            var filesWillOverwrite = false;
            for (var localSaveIndex = 0; localSaveIndex < currentAppSaveNameList.length; localSaveIndex++) {
                for (var externalSaveIndex = 0; externalSaveIndex < availableSavesListView.selectedSaveNames.length; externalSaveIndex++) {
                    var localSaveName = currentAppSaveNameList[localSaveIndex];
                    var externalSaveName = availableSavesListView.selectedSaveNames[externalSaveIndex];
                    if (localSaveName === externalSaveName) {
                        filesWillOverwrite = true;
                        break;
                    }
                }
            }

            // If overwriting is required, prompt the user to confirm this. Declining will stop transfers before they happen.
            // Otherwise, directly call followup methods to run the actual save file transfers.
            if (filesWillOverwrite) {
                confirmImportOverwriteDialog.open();
            } else {
                importSaves();
            }

            return;
        }

        function importSaves(forceOverwrite) {
            // VALIDATE INPUTS.
            // Verify the selected application + saves before continuing.
            // If any discrepancies are found, log errors and exit early.
            if (!availableSavesListView.savesAreSelected) {
                console.error("No saves were selected from external app, no save files could be imported.");
                return false;
            }

            // Iterate over all selected files, calling backend methods to transfer files for each one.
            for (var saveIndex = 0; saveIndex < availableSavesListView.selectedSaveNames.length; saveIndex++) {
                // Call transfer methods w/ input flags and capture return code.
                var externalAppPath = importSavesSelectAppText.text;
                var currentSaveName = availableSavesListView.selectedSaveNames[saveIndex];
                var importResult = appController.importSaveFileFromApp(externalAppPath, currentSaveName, forceOverwrite);

                // Check results for any required handling before moving to the next file.
                var continueToNextSave = true;
                switch (importResult) {
                case 0:
                    // If successful, add debug logs and continue.
                    console.debug("Successfully imported save file %1".arg(currentSaveName));
                    break;

                case 1:
                    // Code 1 indicates overwrite errors. Can be ignored if forceOverwrite is lowered; otherwise,
                    // an error message is displayed to the user to indicate an unexpected failure has occurred.
                    if (forceOverwrite) {
                        console.debug("Failed to overwrite save file %1. Cancelling save file import.".arg(currentSaveName));
                        importErrorDialog.informativeText = "Failed to overwrite files, a fatal error has occurred. Restart app and retry. \
                            If issues continue, please create a new Github issue with error details.";
                        importErrorDialog.open();
                        continueToNextSave = false;
                    } else {
                        console.debug("Skipped import for save file %1 due to overwrite protections.".arg(currentSaveName));
                    }
                    break;

                case 2:
                    // If the given save file no longer exists, log the error at debug level and skip to next.
                    console.debug("Save file under name %1 no longer exists, import was skipped.".arg(currentSaveName));
                    break;

                case 3:
                    // If a non-valid application was provided to backend methods, exist early with error logs for the user.
                    console.debug("External application path %1 is no longer valid. Cancelling save file import.".arg(externalAppPath));
                    importErrorDialog.informativeText = "External application path is no longer valid - save files could not be imported. \
                        Select another application and retry."
                    importErrorDialog.open();
                    continueToNextSave = false;
                    break;

                case 4:
                    // If file permission issues occur preventing files from being written/deleted/etc, raise errors for the user and quit out.
                    console.debug("Save file import ran into file permission issues on save %1, import has been cancelled.".arg(currentSaveName));
                    importErrorDialog.informativeText = "File import failed due to file permission issues. Please ensure all save files can be modified and retry.";
                    importErrorDialog.open();
                    continueToNextSave = false;
                    break;

                default:
                    // In ANY other cases, raise errors for unsupported return codes and quit out.
                    console.debug("Import methods return an unsupported return code %1".arg(importResult));
                    importErrorDialog.informativeText = "Unsupported return code (%1) was returned while importing save file %2. \
                        If issues persist, create a new Github issue and include the contents of this dialog window.";
                    importErrorDialog.open();
                    continueToNextSave = false;
                }

                // Exit out from the loop if flags are set. Otherwise, continue to next save.
                if (!continueToNextSave) {
                    return;
                }
            }

            // If successfully completed, display a confirmation window and close out of the import dialog.
            importCompleteDialog.open();
            importSaveFilesDialog.close();
            return;
        }

        width: updateAppDialog.width - 50
        standardButtons: Dialog.Close

        // When first initialized, set required variables based on current app state.
        onOpened: {
            currentAppSaveNameList = appController.getLocalSaveFileList();
        }

        // POP-UP WINDOWS.
        MessageDialog {
            id: confirmImportOverwriteDialog

            title: "Confirm Overwrites"
            text: "One or more selected saves already exist locally. Would you like to overwrite them?"
            buttons: MessageDialog.Yes | MessageDialog.No | MessageDialog.Cancel

            onButtonClicked: function (button, role) {
                // Handle the different buttons by case.
                switch (button) {
                case MessageDialog.Yes:
                    importSaveFilesDialog.importSaves(true);
                    break;
                case MessageDialog.No:
                    importSaveFilesDialog.importSaves(false);
                    break;
                default:
                    // Any other button beyond Yes/No will just close out the dialog window.
                    break;
                }
            }
        }

        MessageDialog {
            id: importCompleteDialog

            title: "Import Complete."
            text: "File import was successfully completed!"
        }

        MessageDialog {
            id: importErrorDialog

            // Defaults to a general-purpose error message, can be adjusted at time of opening depending on use cases.
            title: "Error Message"
            text: "Fatal errors have occurred."
        }

        // CONTENTS.
        ColumnLayout {
            id: importSaveFilesMainColumn

            anchors.fill: parent

            // APP SELECTION FIELDS.
            RowLayout {
                id: selectAppRow

                Layout.fillWidth: true
                Layout.preferredHeight: 40

                TextField {
                    id: importSavesSelectAppText

                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    readOnly: true
                    activeFocusOnPress: false
                    activeFocusOnTab: false
                    color: Material.primaryTextColor
                    // Set contents of the box to mirror any selected external apps, except in cases where no selection is made.
                    text: (selectExternalAppForExportDialog.validAppIsSelected) ? updateAppDialog.urlToLocalPath(selectExternalAppForExportDialog.selectedFile) : ""
                }

                Button {
                    id: importSavesSelectSavesButton

                    Layout.preferredHeight: 40
                    text: "Select"
                    onClicked: selectExternalAppForExportDialog.open()
                }
            }

            // AVAILABLE SAVES LIST + MODEL.
            Rectangle {
                id: availableSavesListRectangle

                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: Material.dividerColor
                radius: 5

                ListView {
                    id: availableSavesListView

                    function updateSelectedSaveNames() {
                        // Iterate over all list elements to determine selection statuses.
                        var selectedSaveList = [];
                        for (var saveIndex = 0; saveIndex < count; saveIndex++) {
                            // If a selected element is found, break and set to true
                            var currentSave = itemAtIndex(saveIndex);
                            if (currentSave.isSelected) {
                                selectedSaveList.push(currentSave.saveName);
                            }
                        }
                        selectedSaveNames = selectedSaveList;
                        savesAreSelected = (selectedSaveList.length > 0);
                    }

                    property var selectedSaveNames: []
                    property bool savesAreSelected: false

                    anchors {
                        fill: parent
                        margins: 10
                    }
                    spacing: 2

                    // List of available saves syncs with selected applications.
                    model: appController.getSaveFileListFromApp(importSavesSelectAppText.text)
                    delegate: Text {
                        required property string modelData
                        property string saveName: modelData
                        property bool isSelected: false

                        padding: 5
                        text: saveName.replace(".save", "")
                        color: Material.primaryTextColor
                        font.pointSize: 10
                        font.bold: isSelected
                        horizontalAlignment: Qt.AlignLeft
                        elide: Text.ElideLeft

                        // Update required elements everytime a selection is changed.
                        onIsSelectedChanged: availableSavesListView.updateSelectedSaveNames()

                        // When clicked, toggle selection state.
                        Rectangle {
                            anchors.fill: parent
                            z: -1
                            radius: 5
                            color: Material.dividerColor
                            visible: parent.isSelected
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: isSelected = !isSelected
                        }
                    }
                }
            }

            // FUNCTION BUTTONS.
            Button {
                id: startImportButton

                Layout.alignment: Qt.AlignHCenter
                text: "Start Import"
                // Only enabled when valid saves have been selected.
                enabled: availableSavesListView.savesAreSelected
                // When clicked, start import process by checking for overwrite conflicts.
                onClicked: importSaveFilesDialog.checkForFileConflicts()
            }

            // SPACER - Pushes up all other elements to the top of the dialog.
            Item {
                Layout.fillHeight: true
            }
        }
    }

    // MAIN DIALOG CONTENTS.
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

            // CURRENTLY UNSUPPORTED.
            enabled: false
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

            // When clicked, initialize and open dialogs for user inputs.
            onClicked: importSaveFilesDialog.open()
        }
        Button {
            id: exportSavesButton

            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.alignment: Qt.AlignHCenter
            text: "Export Saves"

            // When clicked, initialize and open dialogs for user inputs.
            onClicked: exportSaveFilesDialog.open()
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
