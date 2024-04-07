import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: settingsDialogRoot

    signal themeChanged(string themeName)

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

        RowLayout {
            id: themeSettingsRow

            Layout.alignment: Qt.AlignTop

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
            }

            Button {
                id: lightThemeButton

                text: "Light"
                checkable: true
                Layout.fillWidth: true
            }

            Button {
                id: darkThemeButton

                text: "Dark"
                checkable: true
                Layout.fillWidth: true
            }
        }
    }
}
