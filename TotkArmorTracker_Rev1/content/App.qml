// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.2
import QtQuick.Controls
import TotkArmorTracker

Window {
    width: mainScreen.width
    height: mainScreen.height

    visible: true
    title: "TotkArmorTracker"

    MainWindow {
        id: mainScreen

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

