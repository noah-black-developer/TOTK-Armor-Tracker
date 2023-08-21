// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Window {
    width: 1000
    height: 700

    visible: true
    title: "TOTK Armor Tracker"

    // FILE DIALOGS.
    // Used to interact with user files. Hidden by default.
    FileDialog {
        id: openSaveFileDialog

        // Opens the "saves" folder within the project.
        onAccepted: {
            AppController.pullSave(selectedFile);
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
                text: "&New"
            }
            Action {
                text: "&Open"
                onTriggered: {
                    // This works in the final executable, but not in debug builds,
                    // due to how the file paths end up working out.
                    // For testing, make sure that any builds have a local "saves" folder nearby.
                    openSaveFileDialog.currentFolder = appPath + "/saves"
                    openSaveFileDialog.open();
                }
            }
            Action {
                text: "Open &Recent"
            }
            Action {
                text: "&Save"
            }
            MenuSeparator {}
            Action {
                text: "&Quit"
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

    MainWindow {
        id: mainWindow
        objectName: "mainWindow"

        anchors {
            left: parent.left
            right: parent.right
            top: menuBar.bottom
            bottom: parent.bottom
        }
    }
}

