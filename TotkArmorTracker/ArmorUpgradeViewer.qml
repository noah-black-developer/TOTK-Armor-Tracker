import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: upgradeViewerRoot

    property int upgradeRank: 1

    height: 80

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
}
