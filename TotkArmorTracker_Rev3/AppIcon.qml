import QtQuick
import QtQuick.Controls

// Reimplementation of AbstractButton to use for displaying icons with the icon.xxx interface.
Item {
    id: appIcon
    implicitWidth: 32
    implicitHeight: 32
    property alias icon: btn.icon
    Button {
        id: btn
        anchors.centerIn: parent
        background: Item { }
        icon.width: parent.width
        icon.height: parent.height
    }
}
