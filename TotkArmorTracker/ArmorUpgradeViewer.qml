import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: upgradeViewerRoot

    property int upgradeRank: 1
    property int upgradeMaterialCount: 2
    property int rupeeCost: 0
    property string materialOneName: "Default"
    property string materialTwoName: "Default"
    property string materialThreeName: "Default"
    property string materialFourName: "Default"
    property int materialOneQuantity: 0
    property int materialTwoQuantity: 0
    property int materialThreeQuantity: 0
    property int materialFourQuantity: 0
    property int prevArmor: 0
    property int nextArmor: 0

    height: (upgradeMaterialCount * 20) + 50
    implicitHeight: height

    // HEADER ELEMENTS.
    // Main Border Rectangle.
    // Has 4 variations, depending on how many crafting ingredients are presented.
    Canvas {
        id: upgradeViewerBorderRect
        objectName: "upgradeViewerBorderRect"

        property double headerStart: upgradeViewerTierRow.x - 2
        property double headerEnd: upgradeViewerTierRow.x + upgradeViewerTierRow.width + 2
        property double cornerRadius: 4
        property double canvasHeight: upgradeViewerRoot.height

        //height: (upgradeViewerRoot.upgradeMaterialCount === 1) ? canvasHeight : 0
        height: (upgradeViewerRoot.visible) ? canvasHeight : 0
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        //visible: upgradeViewerRoot.upgradeMaterialCount === 1
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "black";
            ctx.lineWidth = 5;
            ctx.beginPath();
            ctx.moveTo(headerEnd, 0);
            ctx.lineTo(upgradeViewerRoot.width, 0);
            ctx.lineTo(upgradeViewerRoot.width, canvasHeight);
            ctx.lineTo(0, canvasHeight);
            ctx.lineTo(0, 0);
            ctx.lineTo(headerStart, 0);
            ctx.stroke();
        }
    }

    // STAR ICONS (RANK).
    // Overlaps the outer border to show what tier of upgrades this is representing.
    Row {
        id: upgradeViewerTierRow

        anchors {
            left: parent.left
            verticalCenter: parent.top
            leftMargin: 12
            verticalCenterOffset: 2
        }
        spacing: 1

        Repeater {
            id: upgradeViewerTierIcons

            model: 4

            Image {
                required property int index

                width: 12
                height: width

                fillMode: Image.PreserveAspectFit

                // Choose a filled or unfilled star, depending on the item's current rank.
                source: (index <= upgradeViewerRoot.upgradeRank - 1) ? "images/star-solid.svg" : "images/star-regular.svg"
            }
        }
    }

    // HEADER ROW.
    Rectangle {
        id: headerRowRect

        height: 20
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 10
            rightMargin: 10
            topMargin: 10
        }
        color: "transparent"

        // Armor Increases.
        // TODO: Refactor this to include armor images, rather than just text.
        Text {
            id: armorIncreaseText

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                leftMargin: 5
            }
            text: upgradeViewerRoot.prevArmor + " Armor > " + upgradeViewerRoot.nextArmor + " Armor"
        }

        // Rupee Cost.
        Text {
            id: rupeeCostText

            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                rightMargin: 5
            }
            text: upgradeViewerRoot.rupeeCost + " Rupees"
            horizontalAlignment: Qt.AlignRight
        }
    }

    // ITEM DETAILS.
    Rectangle {
        id: upgradeDetailsRect

        anchors {
            left: parent.left
            right: parent.right
            top: headerRowRect.bottom
            bottom: parent.bottom
            leftMargin: 10
            rightMargin: 10
            bottomMargin: 10
        }
        color: "transparent"

        // UPGRADE MATERIALS.
        // At max, a given upgrade tier will have 4 distinct ingredients.
        // 4 ingredients are initialized at any given time, with similar names, to alow easy iteration.

        // Item 1.
        Rectangle {
            id: upgradeItem1

            height: (upgradeViewerRoot.upgradeMaterialCount >= 1) ? 20 : 0
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            visible: upgradeViewerRoot.upgradeMaterialCount >= 1

            // Item Picture.
            Image {
                id: upgradeItem1Image

                height: parent.height
                width: parent.height
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 5
                }
                fillMode: Image.PreserveAspectCrop
                source: "images/" + upgradeViewerRoot.materialOneName + ".png"
            }

            // Item Name.
            Text {
                id: upgradeItem1NameText

                width: 150
                anchors {
                    left: upgradeItem1Image.right
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 10
                }
                text: upgradeViewerRoot.materialOneName
                verticalAlignment: Qt.AlignVCenter
                fontSizeMode: Text.HorizontalFit
                minimumPointSize: 7
            }

            // Item Quantity.
            Text {
                id: upgradeItem1QuantityText

                width: 15
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: 20
                }
                text: "x" + upgradeViewerRoot.materialOneQuantity
                horizontalAlignment: Qt.AlignLeft
            }
        }

        // Item 2.
        Rectangle {
            id: upgradeItem2

            height: (upgradeViewerRoot.upgradeMaterialCount >= 2) ? 20 : 0
            anchors {
                left: parent.left
                right: parent.right
                top: upgradeItem1.bottom
                topMargin: (upgradeViewerRoot.upgradeMaterialCount >= 2) ? 2 : 0
            }
            visible: upgradeViewerRoot.upgradeMaterialCount >= 2

            // Item Picture.
            Image {
                id: upgradeItem2Image

                height: parent.height
                width: parent.height
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 5
                }
                fillMode: Image.PreserveAspectCrop
                source: "images/" + upgradeViewerRoot.materialTwoName + ".png"
            }

            // Item Name.
            Text {
                id: upgradeItem2NameText

                width: 150
                anchors {
                    left: upgradeItem2Image.right
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 10
                }
                text: upgradeViewerRoot.materialTwoName
                verticalAlignment: Qt.AlignVCenter
                fontSizeMode: Text.HorizontalFit
                minimumPointSize: 7
            }

            // Item Quantity.
            Text {
                id: upgradeItem2QuantityText

                width: 15
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: 20
                }
                text: "x" + upgradeViewerRoot.materialTwoQuantity
                horizontalAlignment: Qt.AlignLeft
            }
        }


        // Item 3.
        Rectangle {
            id: upgradeItem3

            height: (upgradeViewerRoot.upgradeMaterialCount >= 3) ? 20 : 0
            anchors {
                left: parent.left
                right: parent.right
                top: upgradeItem2.bottom
                topMargin: (upgradeViewerRoot.upgradeMaterialCount >= 3) ? 2 : 0
            }
            visible: upgradeViewerRoot.upgradeMaterialCount >= 3

            // Item Picture.
            Image {
                id: upgradeItem3Image

                height: parent.height
                width: parent.height
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 5
                }
                fillMode: Image.PreserveAspectCrop
                source: "images/" + upgradeViewerRoot.materialThreeName + ".png"
            }

            // Item Name.
            Text {
                id: upgradeItem3NameText

                width: 150
                anchors {
                    left: upgradeItem3Image.right
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 10
                }
                text: upgradeViewerRoot.materialThreeName
                verticalAlignment: Qt.AlignVCenter
                fontSizeMode: Text.HorizontalFit
                minimumPointSize: 7
            }

            // Item Quantity.
            Text {
                id: upgradeItem3QuantityText

                width: 15
                anchors {
                    right: parent.right
                    top: parent.top
                    rightMargin: 20
                }
                text: "x" + upgradeViewerRoot.materialThreeQuantity
                horizontalAlignment: Qt.AlignLeft
            }
        }
    }
}
