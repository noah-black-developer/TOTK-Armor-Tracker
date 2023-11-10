import QtQuick
import QtQuick.Layouts

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    GridView {
        id: tempListView

        anchors.fill: parent
        anchors.margins: 10
        cellWidth: 80
        cellHeight: 80

        model: appController.getArmorData()
        delegate: Rectangle {
            id: armorBorder

            width: tempListView.cellWidth
            height: tempListView.cellHeight

            Image {
                id: armorImage

                property int marginSize: 10

                anchors.centerIn: parent
                width: armorBorder.width - marginSize
                height: armorBorder.height - marginSize
                source: "images/" + name + ".png"
            }
        }
    }
}
