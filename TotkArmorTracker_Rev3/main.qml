import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

ApplicationWindow {
    id: appRoot

    readonly property int minimumArmorLevel: 0
    readonly property int maximumArmorLevel: 4

    width: 800
    height: 600
    visible: true
    title: qsTr("TOTK Armor Tracker")

    NewSaveDialog {
        id: createNewSaveDialog
    }

    FileDialog {
        id: loadSaveDialog

        title: "Load Save File"
        // The save folder needs to be given the "file" schema to allow the path to be read in as url.
        currentFolder: "file://" + savesFolderPath
        onAccepted: appController.loadSave(selectedFile)
    }

    MessageDialog {
        id: userDataSavedDialog

        text: "Save is complete."
        buttons: MessageDialog.Ok
    }

    menuBar: MenuBar {
        id: menuBar

        Menu {
            title: "File"
            Action {
                text: "New"
                onTriggered: createNewSaveDialog.open()
            }
            Action {
                text: "Load"
                onTriggered: {
                    loadSaveDialog.open()
                }
            }
            Menu {
                id: loadRecentMenu
                title: "Load Recent"

                // If no saves are currently instantiated, menu option is disabled.
                enabled: loadRecentMenuInstantiator.count > 0

                Instantiator {
                    id: loadRecentMenuInstantiator

                    model: appController.recentSaveNames
                    delegate: Action {
                        // Model is populated directly with list of strings, so the full modelData
                        // object can be used to assign the text for this element.
                        text: modelData
                        onTriggered: appController.loadRecentSave(modelData)
                    }

                    // Required functions whenever Instantiator adds/removes Actions.
                    onObjectAdded: (index, object)=> loadRecentMenu.insertAction(index, object)
                    onObjectRemoved: (index, object)=> loadRecentMenu.removeAction(object)
                }
            }
            Action {
                // Disabled by default. Enabled when user loads save.
                enabled: appController.saveIsLoaded
                text: "Save"
                onTriggered: {
                    appController.saveCurrentSave();
                    userDataSavedDialog.open();
                }
            }
            MenuSeparator { }
            Action {
                text: "Quit"
                onTriggered: Qt.quit()
            }
        }
    }

    Rectangle {
        id: centralRect

        anchors {
            fill: parent
            margins: 10
        }
        color: Material.backgroundColor
        clip: true

        Item {
            id: gridWrapper

            width: 480
            anchors {
                left: parent.left
                top: parent.top
                bottom: armorControlsRow.top
                margins: 10
            }

            GridLayout {
                id: gridHeader

                height: 40
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                columns: 3

                TextField {
                    id: gridSortSearchBox

                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width / parent.columns
                    Layout.preferredHeight: parent.height - 12
                    Layout.column: 0
                    enabled: appController.saveIsLoaded
                    placeholderText: "Search"

                    onTextChanged: appController.setSortSearchFilter(text)
                }

                ComboBox {
                    id: gridSortComboBox

                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width / parent.columns
                    Layout.preferredHeight: parent.height
                    Layout.column: 1
                    enabled: appController.saveIsLoaded

                    model: [ "Name", "Level", "Unlocked" ]

                    onCurrentTextChanged: {
                        appController.setSortType(currentText);
                        grid.positionViewAtBeginning();
                        grid.currentIndex = 0;
                    }
                }

                Button {
                    id: gridSortDirectionToggle

                    Layout.preferredHeight: parent.height
                    Layout.column: 2
                    enabled: appController.saveIsLoaded

                    icon.source: "images/arrows-up-down-solid.svg"
                    //icon.color: systemPalette.text
                    icon.color: Material.primaryTextColor
                    text: "Sort"

                    onClicked: {
                        appController.setSortDirection(!appController.currentSortIsAsc());
                        grid.positionViewAtBeginning();
                        grid.currentIndex = 0;
                    }
                }
            }

            GridView {
                id: grid

                width: 500
                anchors {
                    left: parent.left
                    right: parent.right
                    top: gridHeader.bottom
                    bottom: parent.bottom
                    topMargin: 5
                }
                clip: true

                cellWidth: 80
                cellHeight: 80

                // Disabled by default, enabled when user loads a save.
                interactive: appController.saveIsLoaded

                model: appController.getArmorData()
                delegate: Item {
                    id: armorItem

                    property string armorName: name
                    property string armorSetName: setName
                    property string armorSetDesc: description
                    property string armorPassiveBonus: passive
                    property string armorSetBonus: setBonus
                    property bool armorIsUnlocked: isUnlocked
                    property bool armorIsUpgradeable: isUpgradeable
                    property string armorLevel: level

                    width: grid.cellWidth
                    height: grid.cellHeight

                    ColumnLayout {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }

                        Image {
                            source: "images/" + armorItem.armorName + ".png"
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 60
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                            // Armor Level Indicator.
                            Rectangle {
                                anchors {
                                    right: parent.right
                                    top: parent.top
                                    rightMargin: 5
                                    topMargin: 5
                                }
                                width: 15
                                height: 15
                                radius: 5
                                //color: systemPalette.highlight
                                color: Material.accentColor
                                visible: isUpgradeable && isUnlocked

                                Text {
                                    anchors.fill: parent
                                    text: level
                                    font.pointSize: 8
                                    horizontalAlignment: Qt.AlignHCenter
                                    color: Material.Grey
                                }
                            }

                            // "Locked" overlay.
                            Rectangle{
                                anchors.fill: parent
                                color: "gray"
                                opacity: 0.5
                                visible: !isUnlocked
                            }
                        }
                    }

                    MouseArea {
                        id: armorMouseArea
                        anchors.fill: parent
                        onClicked: {
                            // If a save is currently loaded, adjust selection accordingly.
                            if (appController.saveIsLoaded) {
                                grid.currentIndex = index
                            }
                        }
                    }
                }
                //highlight: Rectangle { color: systemPalette.highlight; radius: 5 }
                highlight: Rectangle { color: Material.accentColor; radius: 5 }
                highlightMoveDuration: 75

                // If user has not yet loaded a save, disable view and display following label.
                Rectangle {
                    id: viewNotEnabledOverlay

                    anchors.fill: parent
                    color: "gray"
                    opacity: 0.5

                    // Visible by default, hidden when user loads a save.
                    visible: !appController.saveIsLoaded
                }

                Rectangle {
                    id: viewNotEnabledTextBox

                    width: 100
                    height: 60
                    anchors.centerIn: parent
                    //color: systemPalette.alternateBase
                    color: Material.dialogColor
                    //border.color: systemPalette.highlight
                    border.color: Material.accentColor
                    border.width: 2
                    radius: 5

                    // Visible by default, hidden when user loads a save.
                    visible: !appController.saveIsLoaded

                    Text {
                        anchors {
                            fill: parent
                            margins: 10
                        }
                        text: "No save file loaded."
                        //color: systemPalette.text
                        color: Material.primaryTextColor
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                }
            }
        }

        Item {
            id: detailsWrapper

            anchors {
                left: gridWrapper.right
                right: parent.right
                top: parent.top
                bottom: armorControlsRow.top
                margins: 10
            }

            Rectangle {
                id: detailsBorderRect

                anchors.fill: parent
                color: "transparent"
                border.color: Material.accentColor
                border.width: 1
                radius: 5

                Rectangle {
                    id: detaislsBodyRect

                    anchors {
                        fill: parent
                        margins: 5
                    }
                    color: Material.dialogColor
                    radius: 3

                    ColumnLayout {
                        id: detailsColumnLayout

                        anchors {
                            fill: parent
                            margins: 10
                        }

                        // ARMOR DETAILS.
                        // References current item. If none is selected, short-circuits to default values.
                        RowLayout {
                            id: detailsNameRow

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                            spacing: 2

                            Text {
                                id: detailsNameText

                                Layout.alignment: Qt.AlignLeft
                                text: (grid.currentItem == null) ? "" : grid.currentItem.armorName
                                color: Material.primaryTextColor
                                horizontalAlignment: Qt.AlignLeft
                            }

                            IconImage {
                                id: detailsUnlockedIcon

                                Layout.preferredWidth: 12
                                Layout.preferredHeight: 12
                                Layout.leftMargin: 3
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                source: "images/lock-solid.svg"
                                color: Material.primaryTextColor
                                fillMode: IconImage.PreserveAspectFit
                                visible: (grid.currentItem == null) ? false : !grid.currentItem.armorIsUnlocked
                            }

                            Item { Layout.fillWidth: true }

                            Repeater {
                                model: (grid.currentItem == null) ? 0 : grid.currentItem.armorLevel
                                delegate: IconImage {
                                    id: detailsLevelIcon

                                    Layout.preferredWidth: 12
                                    Layout.preferredHeight: 12
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    source: "images/star-solid.svg"
                                    color: Material.primaryTextColor
                                    fillMode: IconImage.PreserveAspectFit
                                    visible: (grid.currentItem == null) ? false : grid.currentItem.armorIsUnlocked

                                }
                            }
                        }

                        Text {
                            id: detailsDescNameText

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                            text: (grid.currentItem == null) ? "" : '"' + grid.currentItem.armorSetDesc + '"'
                            color: Material.primaryTextColor
                            wrapMode: Text.Wrap
                            font.pointSize: 8
                            font.italic: true
                            horizontalAlignment: Qt.AlignLeft
                        }

                        // Horizontal line.
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            Layout.topMargin: 2
                            Layout.bottomMargin: 2
                            color: Material.accentColor
                            visible: (grid.currentItem != null)
                        }

                        Label {
                            id: detailsPassiveBonusText

                            property int horizontalPadding: 10
                            property int verticalPadding: 3

                            Layout.leftMargin: horizontalPadding
                            Layout.rightMargin: horizontalPadding
                            Layout.topMargin: verticalPadding
                            Layout.bottomMargin: verticalPadding
                            Layout.maximumWidth: parent.width - (2 * horizontalPadding)
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

                            text: (grid.currentItem == null) ? "" : grid.currentItem.armorPassiveBonus
                            font.pointSize: 9
                            elide: Label.ElideMiddle
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter

                            ToolTip.text: text
                            ToolTip.visible: (text === "") ? false : detailsPassiveBonusMouseArea.containsMouse

                            MouseArea {
                                id: detailsPassiveBonusMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            background: Rectangle {
                                id: detailsPassiveBonusBorder

                                anchors.centerIn: parent
                                width: parent.width + (2 * parent.horizontalPadding)
                                height: parent.height + (2 * parent.verticalPadding)
                                color: "transparent"
                                border.color: Material.accentColor
                                border.width: 2
                                radius: 3
                                visible: (grid.currentItem != null)
                            }
                        }

                        Label {
                            id: detailsSetBonusText

                            property int horizontalPadding: 10
                            property int verticalPadding: 3

                            Layout.leftMargin: horizontalPadding
                            Layout.rightMargin: horizontalPadding
                            Layout.topMargin: verticalPadding
                            Layout.bottomMargin: verticalPadding
                            Layout.maximumWidth: parent.width - (2 * horizontalPadding)
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

                            text: (grid.currentItem == null) ? "" : grid.currentItem.armorSetBonus
                            font.pointSize: 9
                            elide: Label.ElideMiddle
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter

                            ToolTip.text: text
                            ToolTip.visible: (text === "") ? false : detailsSetBonusMouseArea.containsMouse

                            MouseArea {
                                id: detailsSetBonusMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            background: Rectangle {
                                id: detailsSetBonusBorder

                                anchors.centerIn: parent
                                width: parent.width + (2 * parent.horizontalPadding)
                                height: parent.height + (2 * parent.verticalPadding)
                                color: "transparent"
                                border.color: Material.accentColor
                                border.width: 2
                                radius: 3
                                visible: (grid.currentItem != null)
                            }
                        }

                        Label {
                            id: detailsDefenseText

                            property int horizontalPadding: 10
                            property int verticalPadding: 3

                            Layout.leftMargin: horizontalPadding
                            Layout.rightMargin: horizontalPadding
                            Layout.topMargin: verticalPadding
                            Layout.bottomMargin: verticalPadding
                            Layout.maximumWidth: parent.width - (2 * horizontalPadding)
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

                            text: "Current Defense: ###"
                            font.pointSize: 9
                            elide: Label.ElideMiddle
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter

                            ToolTip.text: text
                            ToolTip.visible: (text === "") ? false : detailsDefenseMouseArea.containsMouse

                            MouseArea {
                                id: detailsDefenseMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            background: Rectangle {
                                id: detailsDefenseBorder

                                anchors.centerIn: parent
                                width: parent.width + (2 * parent.horizontalPadding)
                                height: parent.height + (2 * parent.verticalPadding)
                                color: "transparent"
                                border.color: Material.accentColor
                                border.width: 2
                                radius: 3
                                visible: (grid.currentItem != null)
                            }
                        }

                        // Horizontal line.
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            Layout.topMargin: 2
                            Layout.bottomMargin: 2
                            color: Material.accentColor
                            visible: (grid.currentItem != null)
                        }

                        // Buffer element to push all other elements to the top of rectangle.
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }

        Text {
            id: loadedSaveNameText

            anchors {
                left: parent.left
                bottom: parent.bottom
                leftMargin: 10
                bottomMargin: 10
            }

            // Initially set to default value - updated when save is loaded.
            text: appController.getSaveName()
            color: Material.primaryTextColor
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
        }


        RowLayout {
            id: armorControlsRow

            height: 40
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                margins: 10
            }

            Button {
                id: unlockArmorButton

                icon.source: {
                    if (grid.currentItem != null)
                    {
                        (grid.currentItem.armorIsUnlocked) ? "images/lock-solid.svg" : "images/unlock-solid.svg"
                    }
                    else {
                        "images/lock-solid.svg"
                    }
                }
                icon.color: Material.primaryTextColor
                text: {
                    if (grid.currentItem != null)
                    {
                        (grid.currentItem.armorIsUnlocked) ? "Lock" : "Unlock"
                    }
                    else {
                        "Unlock"
                    }
                }
                Layout.preferredHeight: parent.height
                Layout.alignment: Qt.AlignHCenter

                // Disabled until a save is loaded.
                enabled: appController.saveIsLoaded

                onClicked: {
                    appController.toggleArmorUnlock(grid.currentItem.armorName);
                }
            }

            Button {
                id: decreaseLevelButton

                icon.source: "images/minus-solid.svg"
                icon.color: Material.primaryTextColor
                text: "Decrease Level"
                Layout.preferredHeight: parent.height
                Layout.alignment: Qt.AlignHCenter

                // Only enabled if save is loaded, armor is unlocked,
                // armor is upgradeable, and is not at minimum level.
                enabled: {
                    if (grid.currentItem != null)
                    {
                        appController.saveIsLoaded &&
                        grid.currentItem.armorIsUnlocked &&
                        grid.currentItem.armorIsUpgradeable &&
                        (grid.currentItem.armorLevel > appRoot.minimumArmorLevel);
                    }
                    else {
                        false;
                    }
                }

                onClicked: {
                    appController.decreaseArmorLevel(grid.currentItem.armorName);
                }
            }

            Button {
                id: increaseLevelButton

                icon.source: "images/plus-solid.svg"
                icon.color: Material.primaryTextColor
                text: "Increase Level"
                Layout.preferredHeight: parent.height
                Layout.alignment: Qt.AlignHCenter

                // Only enabled if save is loaded, armor is unlocked,
                // armor is upgradeable, and is not at maximum level.
                enabled: {
                    if (grid.currentItem != null)
                    {
                        appController.saveIsLoaded &&
                        grid.currentItem.armorIsUnlocked &&
                        grid.currentItem.armorIsUpgradeable &&
                        (grid.currentItem.armorLevel < appRoot.maximumArmorLevel);
                    }
                    else {
                        false;
                    }
                }

                onClicked: {
                    appController.increaseArmorLevel(grid.currentItem.armorName);
                }
            }
        }
    }
}
