import QtQuick
import QtQuick.Layouts

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("TOTK Armor Tracker")

    Rectangle {
        id: gridBorder

        anchors {
            fill: parent
            margins: 10
        }
        color: "lightgray"
        clip: true

        GridView {
            id: grid

            width: 500
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                bottom: parent.bottom
            }

            cellWidth: 100
            cellHeight: 100

            model: appController.getArmorData()
            delegate: Item {
                id: armorItem

                property string armorName: name

                width: grid.cellWidth
                height: grid.cellHeight

                ColumnLayout {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }

                    Image {
                        source: "images/" + name + ".png"
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    }
                    Text {
                        id: armorLabel

                        text: name
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        font.pointSize: 8
                        minimumPointSize: 4
                        horizontalAlignment: Qt.AlignHCenter
                        fontSizeMode: Text.Fit
                    }
                }

                MouseArea {
                    id: armorMouseArea
                    anchors.fill: parent
                    onClicked: grid.currentIndex = index
                }
            }
            highlight: Rectangle { color: "darkgreen"; radius: 5 }
            highlightMoveDuration: 75
            focus: true

            Keys.onTabPressed: {
                if (currentIndex === count - 1) {
                    currentIndex = 0
                }
                else {
                    currentIndex += 1
                }
            }
            Keys.onBacktabPressed: {
                if (currentIndex === 0) {
                    currentIndex = count - 1
                }
                else {
                    currentIndex -= 1
                }
            }
            Keys.onEnterPressed: {
                console.log(currentItem.armorName)
            }
        }
    }
}


