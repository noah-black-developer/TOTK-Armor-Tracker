// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Window {
    id: mainWindowRoot
    objectName: "mainWindowRoot"

    // UI STATE.
    property bool saveIsLoaded: false
    property bool userHasUnsavedChanges: false

    width: 1000
    height: 700
    visible: true
    title: "TOTK Armor Tracker"

    // DIALOGS.
    // File dialog used to interact with user files. Hidden by default.
    FileDialog {
        id: openSaveFileDialog

        // Opens the "saves" folder within the project.
        onAccepted: {
            AppController.pullSave(selectedFile);
        }
    }

    // Dialog to confirm closing the app.
    MessageDialog {
        id: closeAppConfirmation

        title: "Close App"
        text: "Are you sure you want to quit?"
        buttons: MessageDialog.Yes | MessageDialog.No
        onAccepted: Qt.quit()
    }

    // Dialog to ask if the user wants to save their changes when loading a new save.
    MessageDialog {
        id: saveChangesConfirmation

        // File Path must be set to the incoming save file before opening the dialog.
        property url filePath

        title: "Save Unsaved Changes"
        text: "Would you like to save your changes?"
        buttons: MessageDialog.Yes | MessageDialog.No
        onAccepted: {
            AppController.pushSave();
            AppController.pullSave(filePath);
        }
        onRejected: {
            AppController.pullSave(filePath);
        }
    }

    // Menu Options.
    // Handles opening/saving load files and other misc. tasks.
    MenuBar {
        id: menuBar

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Menu {
            title: "&File"
            Action {
                id: newAction

                text: "&New"
                onTriggered: {
                    // When clicked, run the subwindow for creating a new save file.
                    var component = Qt.createComponent("NewSaveWindow.qml")
                    var window    = component.createObject(mainWindowRoot)
                    window.show()
                }
            }
            Action {
                id: openAction

                text: "&Open"
                onTriggered: {
                    // This works in the final executable, but not in debug builds,
                    // due to how the file paths end up working out.
                    // For testing, make sure that any builds have a local "saves" folder nearby.
                    openSaveFileDialog.currentFolder = appPath + "/saves"
                    openSaveFileDialog.open();
                }
            }
            Menu {
                id: openRecentMenu
                objectName: "openRecentMenu"

                property int recentSaveCount: 0

                function loadRecentSave(filePath) {
                    // If user has a loaded save and unsaved changes, prompt them to save changes first.
                    if (mainWindowRoot.saveIsLoaded && mainWindowRoot.userHasUnsavedChanges) {
                        saveChangesConfirmation.filePath = filePath;
                        saveChangesConfirmation.open();
                    }
                    // Otherwise, skip the confirmation box and load the save directly.
                    else {
                        AppController.pullSave(filePath);
                    }
                }

                title: "Open &Recent"
                enabled: (recentSaveCount > 0)
                // The menu contains pre-defined fields for up to 5 recent saves.
                // By default, all recent saves are hidden from the user.
                MenuItem {
                    id: recentSave1
                    objectName: "recentSave1"

                    property url filePath
                    property string fileName: "default"

                    text: fileName
                    visible: (openRecentMenu.recentSaveCount >= 1)
                    height: visible ? implicitHeight : 0
                    onTriggered: openRecentMenu.loadRecentSave(filePath)
                }
                MenuItem {
                    id: recentSave2
                    objectName: "recentSave2"

                    property url filePath
                    property string fileName: "default"

                    text: fileName
                    visible: (openRecentMenu.recentSaveCount >= 2)
                    height: visible ? implicitHeight : 0
                    onTriggered: openRecentMenu.loadRecentSave(filePath)
                }
                MenuItem {
                    id: recentSave3
                    objectName: "recentSave3"

                    property url filePath
                    property string fileName: "default"

                    text: fileName
                    visible: (openRecentMenu.recentSaveCount >= 3)
                    height: visible ? implicitHeight : 0
                    onTriggered: openRecentMenu.loadRecentSave(filePath)
                }
                MenuItem {
                    id: recentSave4
                    objectName: "recentSave4"

                    property url filePath
                    property string fileName: "default"

                    text: fileName
                    visible: (openRecentMenu.recentSaveCount >= 4)
                    height: visible ? implicitHeight : 0
                    onTriggered: openRecentMenu.loadRecentSave(filePath)
                }
                MenuItem {
                    id: recentSave5
                    objectName: "recentSave5"

                    property url filePath
                    property string fileName: "default"

                    text: fileName
                    visible: (openRecentMenu.recentSaveCount >= 5)
                    height: visible ? implicitHeight : 0
                    onTriggered: openRecentMenu.loadRecentSave(filePath)
                }
            }
            Action {
                id: saveAction
                objectName: "saveAction"

                text: "&Save"
                // By default, this action is disabled.
                enabled: false
                onTriggered: {
                    AppController.pushSave();
                    // Reset flags showing user has unsaved changes.
                    mainWindowRoot.userHasUnsavedChanges = false;
                }
            }
            MenuSeparator {}
            Action {
                id: quitAction

                text: "&Quit"
                onTriggered: closeAppConfirmation.open()
            }
        }
        Menu {
            title: "&Help"
            Action {
                text: "&How To"
            }
            MenuSeparator {}
            Action {
                text: "&Version Info"
            }
        }
    }

    // Main Controls.
    Rectangle {
        id: mainRectangle

        anchors {
            left: parent.left
            right: parent.right
            top: menuBar.bottom
            bottom: parent.bottom
        }

        StackLayout {
            id: stackLayout

            anchors.fill: parent
            // TODO - Add in a control to toggle the active window.
            currentIndex: 0

            // Page 1 - Armor Progress
            // Tracks what armor pieces are unlocked, current tiers, etc.
            ArmorProgressPage {
                id: mainWindowArmorProgressPage

                objectName: "mainWindowArmorProgressPage"
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}

