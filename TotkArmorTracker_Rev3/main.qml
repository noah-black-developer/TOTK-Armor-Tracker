import QtQuick
import QtQuick.Layouts

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    ListView {
        id: tempListView

        anchors.fill: parent
        anchors.margins: 10
        spacing: 5
        model: testData
        delegate: Rectangle {
            anchors {
                left: parent.left
                right: parent.right
            }
            implicitHeight: 50
            color: "gray"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: name
                    Layout.preferredWidth: 60
                }
                Text {
                    text: setName
                    Layout.preferredWidth: 60
                }
                Text {
                    text: description
                    Layout.preferredWidth: 60
                }
                Text {
                    text: passive
                    Layout.preferredWidth: 60
                }
                Text {
                    text: setBonus
                    Layout.preferredWidth: 60
                }
                Text {
                    text: level
                    Layout.preferredWidth: 60
                }
            }
        }
    }
}
