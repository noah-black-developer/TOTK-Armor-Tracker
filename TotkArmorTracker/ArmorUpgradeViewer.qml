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

    height: upgradeItem1.height + upgradeItem2.height + upgradeItem3.height + upgradeItem4.height + 30

    // HEADER ELEMENTS.
    // Main Border Rectangle.
    Canvas {
        id: upgradeViewerBorderRect

        property double headerStart: upgradeViewerTierRow.x - 2
        property double headerEnd: upgradeViewerTierRow.x + upgradeViewerTierRow.width + 2
        property double cornerRadius: 5
        property double strokeWidthInPixels: 4

        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "black";
            ctx.lineWidth = strokeWidthInPixels;
            ctx.beginPath();
            ctx.moveTo(headerEnd, 0);
            ctx.lineTo(upgradeViewerBorderRect.width, 0);
            ctx.lineTo(upgradeViewerBorderRect.width, upgradeViewerBorderRect.height);
            ctx.lineTo(0, upgradeViewerBorderRect.height);
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

    // DETAILS.
    Rectangle {
        id: upgradeDetailsRect

        property int upgradeHeight: 20

        anchors {
            fill: parent
            margins: 10
        }
        color: "transparent"

        // UPGRADE MATERIALS.
        // At max, a given upgrade tier will have 4 distinct ingredients.
        // 4 ingredients are initialized at any given time, with similar names, to alow easy iteration.

        // Item 1.
        Rectangle {
            id: upgradeItem1

            height: (upgradeViewerRoot.upgradeMaterialCount >= 1) ? upgradeDetailsRect.upgradeHeight : 0
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            color: "lightgray"
            visible: upgradeViewerRoot.upgradeMaterialCount >= 1

            RowLayout {
                id: upgradeItem1Row

                anchors {
                    fill: parent
                    leftMargin: 20
                    rightMargin: 20
                }

                // Item Picture.
                Image {
                    id: upgradeItem1Image
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.height
                    fillMode: Image.PreserveAspectCrop
                    source: "images/" + upgradeViewerRoot.materialOneName + ".png"
                }

                // Item Name.
                Text {
                    id: upgradeItem1NameText
                    Layout.leftMargin: 2
                    text: upgradeViewerRoot.materialOneName
                }

                // Spacing Rect.
                Rectangle {
                    id: upgradeItem1Spacer
                    Layout.fillWidth: true
                }

                // Item Quantity.
                Text {
                    id: upgradeItem1QuantityText
                    text: "x" + upgradeViewerRoot.materialOneQuantity
                }
            }
        }

        // Item 2.
        Rectangle {
            id: upgradeItem2

            height: (upgradeViewerRoot.upgradeMaterialCount >= 2) ? upgradeDetailsRect.upgradeHeight : 0
            anchors {
                left: parent.left
                right: parent.right
                top: upgradeItem1.bottom
                topMargin: 2
            }
            color: "lightgray"
            visible: upgradeViewerRoot.upgradeMaterialCount >= 2

            RowLayout {
                id: upgradeItem2Row

                anchors {
                    fill: parent
                    leftMargin: 20
                    rightMargin: 20
                }

                // Item Picture.
                Image {
                    id: upgradeItem2Image
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.height
                    fillMode: Image.PreserveAspectCrop
                    source: "images/" + upgradeViewerRoot.materialTwoName + ".png"
                }

                // Item Name.
                Text {
                    id: upgradeItem2NameText
                    Layout.leftMargin: 2
                    text: upgradeViewerRoot.materialTwoName
                }

                // Spacing Rect.
                Rectangle {
                    id: upgradeItem2Spacer
                    Layout.fillWidth: true
                }

                // Item Quantity.
                Text {
                    id: upgradeItem2QuantityText
                    text: "x" + upgradeViewerRoot.materialTwoQuantity
                }
            }
        }


        // Item 3.
        Rectangle {
            id: upgradeItem3

            height: (upgradeViewerRoot.upgradeMaterialCount >= 3) ? upgradeDetailsRect.upgradeHeight : 0
            anchors {
                left: parent.left
                right: parent.right
                top: upgradeItem2.bottom
                topMargin: 2
            }
            color: "lightgray"
            visible: upgradeViewerRoot.upgradeMaterialCount >= 3

            RowLayout {
                id: upgradeItem3Row

                anchors {
                    fill: parent
                    leftMargin: 20
                    rightMargin: 20
                }

                // Item Picture.
                Image {
                    id: upgradeItem3Image
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.height
                    fillMode: Image.PreserveAspectCrop
                    source: "images/" + upgradeViewerRoot.materialThreeName + ".png"
                }

                // Item Name.
                Text {
                    id: upgradeItem3NameText
                    Layout.leftMargin: 2
                    text: upgradeViewerRoot.materialThreeName
                }

                // Spacing Rect.
                Rectangle {
                    id: upgradeItem3Spacer
                    Layout.fillWidth: true
                }

                // Item Quantity.
                Text {
                    id: upgradeItem3QuantityText
                    text: "x" + upgradeViewerRoot.materialThreeQuantity
                }
            }
        }


        // Item 4.
        Rectangle {
            id: upgradeItem4

            height: (upgradeViewerRoot.upgradeMaterialCount >= 4) ? upgradeDetailsRect.upgradeHeight : 0
            anchors {
                left: parent.left
                right: parent.right
                top: upgradeItem3.bottom
                topMargin: 2
            }
            color: "lightgray"
            visible: upgradeViewerRoot.upgradeMaterialCount >= 4

            RowLayout {
                id: upgradeItem4Row

                anchors {
                    fill: parent
                    leftMargin: 20
                    rightMargin: 20
                }

                // Item Picture.
                Image {
                    id: upgradeItem4Image
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.height
                    fillMode: Image.PreserveAspectCrop
                    source: "images/" + upgradeViewerRoot.materialFourName + ".png"
                }

                // Item Name.
                Text {
                    id: upgradeItem4NameText
                    Layout.leftMargin: 2
                    text: upgradeViewerRoot.materialFourName
                }

                // Spacing Rect.
                Rectangle {
                    id: upgradeItem4Spacer
                    Layout.fillWidth: true
                }

                // Item Quantity.
                Text {
                    id: upgradeItem4QuantityText
                    text: "x" + upgradeViewerRoot.materialFourQuantity
                }
            }
        }
    }
}
