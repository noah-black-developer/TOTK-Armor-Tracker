import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: settingsDialogRoot

    signal themeChanged(string themeName)
    signal autoSaveChanged(bool autoSaveOn)

    width: 400
    height: 600
    anchors.centerIn: parent
    title: "App Settings"
    standardButtons: Dialog.Close

    // Methods to set default values for various fields.
    function setDefaultTheme(themeName) {
        if (themeName === "Light") {
            lightThemeButton.checked = true;
        }
        else if (themeName === "Dark") {
            darkThemeButton.checked = true;
        }
        else {
            // For any non-valid themes, set System as default.
            systemThemeButton.checked = true;
        }
    }
    function setDefaultAutoSave(autoSaveOn) {
        if (autoSaveOn === true) {
            autoSaveOnButton.checked = true;
        } else {
            autoSaveOffButton.checked = true;
        }
    }

    // MAIN SETTINGS.
    ColumnLayout {
        id: mainColumn

        anchors {
            fill: parent
        }

        // Theme Settings.
        ButtonGroup {
            id: themeSettingsButtonGroup
            buttons: themeSettingsRow.children
            exclusive: true

            // Emit matching signals when the selected theme is changed.
            onCheckedButtonChanged: settingsDialogRoot.themeChanged(checkedButton.text)
        }

        ButtonGroup {
            id: autoSaveButtonGroup
            buttons: autoSaveRow.children
            exclusive: true

            // Emit matching signals when autosave is enabled/disabled.
            onCheckedButtonChanged: settingsDialogRoot.autoSaveChanged(checkedButton === autoSaveOnButton)
        }

        RowLayout {
            id: themeSettingsRow

            Text {
                id: themeSettingsLabel

                text: "Theme:"
                color: Material.primaryTextColor
                Layout.alignment: Qt.AlignLeft
            }

            Button {
                id: systemThemeButton

                text: "System"
                checkable: true
                checked: true
                Layout.fillWidth: true
                Layout.preferredWidth: 100
            }
            Button {
                id: lightThemeButton

                text: "Light"
                checkable: true
                Layout.fillWidth: true
                Layout.preferredWidth: 100
            }
            Button {
                id: darkThemeButton

                text: "Dark"
                checkable: true
                Layout.fillWidth: true
                Layout.preferredWidth: 100
            }
        }

        RowLayout {
            id: autoSaveRow

            Text {
                id: autoSaveLabel

                text: "Auto-save:"
                color: Material.primaryTextColor
                Layout.alignment: Qt.AlignLeft
            }

            Button {
                id: autoSaveOnButton

                text: "On"
                checkable: true
                checked: true
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignLeft
            }
            Button {
                id: autoSaveOffButton

                text: "Off"
                checkable: true
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignLeft
            }
        }

        // Spacing.
        Item {
            Layout.fillHeight: true
        }
    }
}
