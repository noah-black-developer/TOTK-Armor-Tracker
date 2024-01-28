import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

ApplicationWindow {
    id: appRoot

    readonly property int minimumArmorLevel: 0
    readonly property int maximumArmorLevel: 4

    width: 800
    height: 800
    visible: true
    title: qsTr("TOTK Armor Tracker")

    // Disable horizontal resizing.
    minimumWidth: width
    maximumWidth: width

    // KEYBOARD SHORTCUTS.
    // Ctrl + S is used to save the user's current changes.
    Shortcut {
        id: saveShortcut

        sequence: "Ctrl+S"
        context: Qt.ApplicationShortcut
        onActivated: {
            if (appController.saveIsLoaded) {
                appController.saveCurrentSave();
            }
        }
    }
    // Ctrl + U can be used to lock/unlock the current armor set.
    Shortcut {
        id: lockUnlockShortcut

        sequence: "Ctrl+U"
        context: Qt.ApplicationShortcut
        onActivated: {
            if (appController.saveIsLoaded) {
                appController.toggleArmorUnlock(grid.currentItem.armorName);
            }
        }
    }
    // Ctrl + Up or Ctrl + Down are used to increase/decrease the level of the current armor, if unlocked.
    // If the armor is *not* unlocked, shortcut will auto-unlock the armor before increasing level.
    // Similarly, if attempting to decrease the level below 0, shortcuts will lock the armor automatically.
    Shortcut {
        id: increaseLevelShortcut

        sequence: "Ctrl+Up"
        context: Qt.ApplicationShortcut
        onActivated: {
            if (grid.currentItem && appController.saveIsLoaded) {
                // If locked, unlock the armor set first unlock the armor set.
                if (grid.currentItem.armorIsUnlocked === false) {
                    appController.toggleArmorUnlock(grid.currentItem.armorName);
                }

                else {
                    // Increase the armor level, if possible.
                    if (grid.currentItem.armorLevel !== "4") {
                        appController.increaseArmorLevel(grid.currentItem.armorName);
                    }
                }
            }
        }
    }
    Shortcut {
        id: decreaseLevelShortcut

        sequence: "Ctrl+Down"
        context: Qt.ApplicationShortcut
        onActivated: {
            if (grid.currentItem && appController.saveIsLoaded) {
                // If armor is already at the minimum level, lock it.
                if (grid.currentItem.armorLevel === "0" && grid.currentItem.armorIsUnlocked === true) {
                    appController.toggleArmorUnlock(grid.currentItem.armorName);
                }

                else {
                    // Decrease the armor level, if possible.
                    if (grid.currentItem.armorLevel !== "0") {
                        appController.decreaseArmorLevel(grid.currentItem.armorName);
                    }
                }
            }
        }
    }

    // DIALOG WINDOWS.
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
        id: unsavedChangesDialog

        property var localSaveName: null

        title: "Save Unsaved Changes"
        text: "Would you like to save any unsaved changes?"
        buttons: MessageDialog.Yes | MessageDialog.No
        onAccepted: {
            // Save all unsaved changes.
            appController.saveCurrentSave();

            // If a local save name was set, use it to load a local save.
            if (localSaveName) {
                appController.loadRecentSave(localSaveName);
            }
            // Otherwise, open the main save loading dialog.
            else {
                loadSaveDialog.open();
            }
        }
        onRejected: {
            // If a local save name was set, use it to load a local save.
            if (localSaveName) {
                appController.loadRecentSave(localSaveName);
            }
            // Otherwise, open the main save loading dialog.
            else {
                loadSaveDialog.open();
            }
        }
    }


    // MENU OPTIONS.
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
                    // If the user has unsaved changes, prompt them to save them.
                    if (appController.unsavedChanges) {
                        unsavedChangesDialog.localSaveName = null;
                        unsavedChangesDialog.open();
                    }
                    // Otherwise, open the save loading menu directly.
                    else {
                        loadSaveDialog.open();
                    }
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
                        onTriggered: {
                            // If the user has unsaved changes, prompt them to save them.
                            if (appController.unsavedChanges) {
                                unsavedChangesDialog.localSaveName = modelData;
                                unsavedChangesDialog.open();
                            }
                            // Otherwise, load the recent save directly.
                            else {
                                appController.loadRecentSave(modelData);

                            }
                        }
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
                onTriggered: appController.saveCurrentSave();
            }
            MenuSeparator { }
            Action {
                text: "Quit"
                onTriggered: Qt.quit()
            }
        }
    }

    // FOOTER LABELS.
    // Small labels present at the bottom of the app window.
    footer: Text {
        id: userChangesMadeText

        padding: 5
        text: (appController.unsavedChanges) ? "Unsaved changes." : ""
        color: Material.secondaryTextColor
    }

    // MAIN WINDOW CONTENTS.
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
                        appController.sortIsAsc = true;
                        // When changing sort types, reset sort direction to defaults.
                        appController.setSortDirection(true);
                        grid.positionViewAtBeginning();
                        grid.currentIndex = 0;
                    }
                }

                Button {
                    id: gridSortDirectionToggle

                    Layout.preferredHeight: parent.height
                    Layout.column: 2
                    enabled: appController.saveIsLoaded

                    icon.source: (appController.sortIsAsc) ? "images/arrow-up-solid.svg" : "images/arrow-down-solid.svg"
                    icon.color: Material.primaryTextColor
                    text: "Sort"

                    onClicked: {
                        appController.sortIsAsc = !appController.sortIsAsc;
                        appController.setSortDirection(appController.sortIsAsc);
                        grid.currentIndex = 0;
                    }
                }
            }

            GridView {
                id: grid

                property bool isInit: false

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

                // Arrow keys can be used to navigate the selected armor set around the selection area.
                Keys.onLeftPressed: (appController.saveIsLoaded) ? grid.moveCurrentIndexLeft() : ""
                Keys.onRightPressed: (appController.saveIsLoaded) ? grid.moveCurrentIndexRight() : ""
                Keys.onUpPressed: (appController.saveIsLoaded) ? grid.moveCurrentIndexUp() : ""
                Keys.onDownPressed: (appController.saveIsLoaded) ? grid.moveCurrentIndexDown() : ""
                // Also need to set focus on the grid for these key inputs to be properly registered.
                // This element should ALWAYS hold focus, so whenever lost, refocus the element.
                focus: true
                onFocusChanged: focus = true

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
                    property var armorUpgradeReqMap: upgradeReqs

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

                    ScrollView {
                        id: detailsScrollView

                        anchors {
                            fill: parent
                            margins: 5
                        }
                        contentWidth: detailsColumnLayout.width
                        contentHeight: detailsColumnLayout.height

                        ColumnLayout {
                            id: detailsColumnLayout

                            // The background rectangle is somehow a more *consistent* source of width
                            // here, so it is used and modified with the margins size to get correct sizing.
                            width: detaislsBodyRect.width - 10

                            // ARMOR DETAILS.
                            // References current item. If none is selected, short-circuits to default values.

                            // Armor Name + Icons.
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

                            // Armor Description.
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

                            // Passive Bonuses.
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

                            // Set Bonuses.
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

                            // Armor Defense (at current level).
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

                            // Armor Upgrades.
                            // Displays upgrades required for all upgrades the armor currently supports.
                            Repeater {
                                id: detailsArmorUpgradesRepeater

                                property int rowHeightsInPixels: 18
                                property int marginSizeInPixels: 5

                                // The fields for showing armor upgrades are always shown, but hidden if the armor cannot be upgraded.
                                model: 4
                                delegate: Rectangle {
                                    id: armorUpgradeRect

                                    required property int index
                                    property string levelStr: {
                                        var level = armorUpgradeRect.index + 1;
                                        level.toString();
                                    }
                                    property int itemCount: {
                                        if (grid.currentItem) {
                                            // Defaults to 0 if item is not upgradeable.
                                            if (grid.currentItem.armorIsUpgradeable) {
                                                grid.currentItem.armorUpgradeReqMap[armorUpgradeRect.levelStr].getFullItemList().length;
                                            } else {
                                                0;
                                            }
                                        } else {
                                            0;
                                        }
                                    }
                                    property bool isNextUpgrade: {
                                        // Set to true when the displaying the upgrades required for the armor's next level.
                                        // Used in determining default settings for color and expansion state.
                                        var prevLevel = armorUpgradeRect.index;
                                        if (grid.currentItem) {
                                            if (grid.currentItem.armorIsUnlocked) {
                                                grid.currentItem.armorLevel === prevLevel.toString();
                                            } else {
                                                false;
                                            }
                                        } else {
                                            // If no current item is available, set to false.
                                            false;
                                        }
                                    }

                                    property color textColor: (isNextUpgrade) ? Material.backgroundColor : Material.secondaryTextColor

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: {
                                        // Height is determined by a combination of all displayed rows and margins.
                                        (detailsArmorUpgradesRepeater.rowHeightsInPixels * (itemCount + 1)) // Height of all items...
                                        + (detailsArmorUpgradesRepeater.marginSizeInPixels * 2)             // ...plus the top/bottom margins...
                                        + (itemCount * detailsArmorUpgradesRepeater.marginSizeInPixels)     // ...plus space between each item
                                    }
                                    visible: (grid.currentItem) ? grid.currentItem.armorIsUpgradeable : false
                                    // Changed to more visible color when armor is at level before current upgrade tier.
                                    color: (isNextUpgrade) ? Material.accentColor : Material.dividerColor
                                    radius: 5

                                    // Each upgrade tier is composed of multiple rows, each containing info on a specific requirement or header.
                                    ColumnLayout {
                                        id: armorUpgradeColumn

                                        anchors {
                                            fill: parent
                                            margins: 5
                                        }
                                        spacing: 5

                                        // Header information and basic cost info.
                                        RowLayout {
                                            id: upgradeHeaderRow

                                            Layout.fillWidth: true
                                            Layout.preferredHeight: detailsArmorUpgradesRepeater.rowHeightsInPixels

                                            // Upgrade Level Info.
                                            Text {
                                                id: upgradeLevelInfoText

                                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                                text: "Level " + (armorUpgradeRect.index + 1)
                                                font.bold: true
                                                color: armorUpgradeRect.textColor
                                            }

                                            // Spacer.
                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            // Upgrade Rupee Cost.
                                            Text {
                                                id: upgradeRupeeCostText

                                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                                Layout.fillHeight: true
                                                text: {
                                                    if (grid.currentItem) {
                                                        (grid.currentItem.armorIsUpgradeable)
                                                            ? grid.currentItem.armorUpgradeReqMap[armorUpgradeRect.levelStr].costInRupees
                                                            : "0";
                                                    } else {
                                                        "0";
                                                    }
                                                }
                                                color: armorUpgradeRect.textColor
                                            }
                                            AppIcon {
                                                id: upgradeRupeeCostIcon

                                                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                                                // Icon size is fixed to prevent resizing issues.
                                                Layout.preferredHeight: detailsArmorUpgradesRepeater.rowHeightsInPixels
                                                Layout.preferredWidth: 10
                                                Layout.leftMargin: 5
                                                icon.source: "images/rupee-lightmode.svg"
                                                icon.color: armorUpgradeRect.textColor
                                            }
                                        }

                                        // Required Items.
                                        // Instantiates based on how many items are required at each tier.
                                        Repeater {
                                            id: upgradeItemsRepeater

                                            model: {
                                                // Item elements are only generated if an armor set is selected AND that armor has items to present.
                                                if (grid.currentItem) {
                                                    if (grid.currentItem.armorUpgradeReqMap[armorUpgradeRect.levelStr]) {
                                                        grid.currentItem.armorUpgradeReqMap[armorUpgradeRect.levelStr].getFullItemList();
                                                    } else {
                                                        []
                                                    }
                                                } else {
                                                    []
                                                }
                                            }
                                            delegate: RowLayout {
                                                id: upgradeItemRow

                                                required property var modelData

                                                Layout.fillWidth: true
                                                Layout.preferredHeight: detailsArmorUpgradesRepeater.rowHeightsInPixels

                                                // Item image.
                                                Image {
                                                    id: upgradeItemImage

                                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                                    Layout.preferredWidth: detailsArmorUpgradesRepeater.rowHeightsInPixels
                                                    Layout.preferredHeight: detailsArmorUpgradesRepeater.rowHeightsInPixels
                                                    fillMode: Image.PreserveAspectFit
                                                    source: "images/" + modelData.name + ".png"
                                                }

                                                // Item Name.
                                                Text {
                                                    id: upgradeItemName

                                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                                    text: modelData.name
                                                    color: armorUpgradeRect.textColor
                                                }

                                                // Spacer.
                                                Item {
                                                    Layout.fillWidth: true
                                                }

                                                // Item Quantity.
                                                Text {
                                                    id: upgradeItemQuantity

                                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                                    text: "x" + modelData.quantity
                                                    color: armorUpgradeRect.textColor
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Buffer element to push all other elements to the top of rectangle,
                            // as well as add some empty space at the bottom of the window.
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 50
                            }
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
                    if (grid.currentItem)
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
