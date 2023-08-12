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
        currentFolder: "./saves"
        onAccepted: {
            AppController.appPullSave(selectedFile);
        }
    }

    MainWindow {
        id: mainWindow
        objectName: "mainWindow"

        // Menu Options.
        // Handles opening/saving load files and other misc. tasks.
        MenuBar {
            id: menuBar
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 0

            Menu {
                title: "&File"
                Action {
                    text: "&New"
                }
                Action {
                    text: "&Open"
                    onTriggered: openSaveFileDialog.open()
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
    }
}

