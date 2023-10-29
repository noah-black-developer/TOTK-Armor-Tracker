

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: rectangle1
    height: 900
    width: 1600

    Rectangle {
        id: leftControlsRectangle
        width: 300
        color: "#dedede"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        // Armor Icon (Buttons).
        // Show the user what armors they have unlocked and
        // what tier those armor pieces are currently at.
        GridView {
            id: armorIconsView
            anchors.fill: parent

            // Allow the list to extend past the current window.
            clip: true

            cellHeight: 100
            cellWidth: 100

            // List defaults to entries, but will be adjusted at runtime
            // using imported armor data sets.
            model: 50
            delegate: ArmorIcon {}
        }
    }

    Rectangle {
        id: rightControlsRectangle
        width: 400
        color: "#dedede"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
}
