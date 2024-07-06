import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: newSaveDialog

    readonly property int minimumArmorLevel: 0
    readonly property int maximumArmorLevel: 4

    signal newSaveCreated(string name)

    anchors.centerIn: parent
    title: "Create New Save"
    standardButtons: Dialog.Ok | Dialog.Cancel

    // By default, confirmation button is disabled until user input.
    Component.onCompleted: {
        standardButton(Dialog.Ok).enabled = nameTextInput.acceptableInput;
    }

    onOpened: {
        // Whenever the window is first opened, return the armor list to default settings
        nameTextInput.clear();
        appController.clearNewSaveArmorData();
        armorSetupView.forceLayout();
        armorSetupView.positionViewAtBeginning();
    }

    onAccepted: {
        // If a save file already exists for the given name, prompt the user to confirm they want to overwrite it.
        if (appController.saveExists(nameTextInput.text + ".xml")) {
            confirmOverwriteDialog.open();
        }

        // Otherwise, save file can be created immediately.
        else {
            // If approved, create the new save file.
            var saveResult = appController.createNewSave(nameTextInput.text);
            if (saveResult === true)
            {
                newSaveDialog.newSaveCreated(nameTextInput.text);
            }
        }
    }

    // CONFIRM OVERWRITE PROMPT.
    // Displayed if the user is attempting to overwrite a pre-exiting save file.
    MessageDialog {
        id: confirmOverwriteDialog

        title: "Overwrite Existing Save"
        text: "A save named '" + nameTextInput.text + "' already exists. Overwrite?"
        buttons: MessageDialog.No | MessageDialog.Yes
        onAccepted: {
            // If accepted, create and overwrite the save, sending required signals on a success.
            var overwriteSaveResult = appController.createNewSave(nameTextInput.text);
            if (overwriteSaveResult === true)
            {
                newSaveDialog.newSaveCreated(nameTextInput.text);
            }
        }
    }

    // SAVE DATA ENTRY FIELDS.
    RowLayout {
        id: nameRow

        height: 30
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 60
            rightMargin: 60
        }

        Label {
            id: newSaveNameLabel
            text: "Name: "
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            verticalAlignment: Qt.AlignVCenter
        }

        TextField {
            id: nameTextInput

            readonly property int saveMaxLength: 24

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            // Valid file names allow characters, dashes, underscores, and spaces.
            // Additionally, a maximum character limit is set to prevent file names from growing too long.
            validator: RegularExpressionValidator {
                regularExpression: {
                    var saveNameMatchStr = "^[\\w\\- ]{0,%1}$".arg(nameTextInput.saveMaxLength);
                    new RegExp(saveNameMatchStr);
                }
            }
            placeholderText: "Save Name"

            // Update the "OK" button every time the user edits the field.
            onTextChanged: {
                createNewSaveDialog.standardButton(Dialog.Ok).enabled = acceptableInput;
            }
        }
    }

    // ARMOR LIST SORTING.
    RowLayout {
        id: armorSortingRow

        height: 30
        anchors {
            left: parent.left
            right: parent.right
            top: nameRow.bottom
            margins: 10
        }

        // Search field.
        TextField {
            id: armorSortTextField

            Layout.fillWidth: true
            Layout.fillHeight: true
            placeholderText: "Search"

            onTextChanged: appController.newSaveSetSortSearchFilter(text)
        }

        Rectangle {
            id: clearButtonRect

            Layout.preferredWidth: 40
            Layout.fillHeight: true
            radius: 5
            color: "transparent"
            border.color: Material.accentColor
            border.width: 2

            Text {
                id: clearButtonText

                anchors.fill: parent
                text: "Clear"
                color: Material.accentColor
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: armorSortTextField.clear()
            }
        }
    }

    // ARMOR LIST.
    Rectangle {
        id: armorSetupViewFrame

        anchors {
            left: parent.left
            right: parent.right
            top: armorSortingRow.bottom
            bottom: parent.bottom
            margins: 10
        }
        // Add some padding to help with rendering the different list elements properly.
        height: parent.height + 40
        color: "transparent"
        border.color: Material.accentColor
        border.width: 2
        radius: 5

        Rectangle {
            id: armorSetupViewBackground

            anchors {
                fill: parent
                margins: 5
            }
            color: Material.dividerColor
            radius: 3
        }
    }

    // Pre-rendered images for use in grid elements.
    Image {
        id: lockedImageIcon

        source: "images/lock-solid.svg"
        visible: false
    }
    Image {
        id: unlockedImageIcon

        source: "images/unlock-solid.svg"
        visible: false
    }
    Image {
        id: startImageIcon

        source: "images/star-solid.svg"
        visible: false
    }

    // Pre-rendering for all images in the grid.
    // These are applied to each element at runtime, removing the need to recreate different images.
    Repeater {
        id: armorIcons

        function loadImage(index) {
            var image = itemAt(index);
            if (image) {
                return image.source;
            } else {
                return null;
            }
        }

        visible: false
        // The unfiltered armor list is used so that elements are never filtered out.
        model: appController.getRawArmorData()
        delegate: Image {
            property int armorIndex: index
            property string armorName: name

            source: "images/" + armorName + ".png"
            visible: false
        }
    }

    GridView {
        id: armorSetupView

        anchors {
            fill: armorSetupViewFrame
            margins: 15
        }
        clip: true
        cellWidth: 200
        cellHeight: 100
        // Impossibly high cache buffer is set to keep all elements existing at all times.
        cacheBuffer: 100000
        // Set width up to allow for 3 columns.
        width: cellWidth * 3

        // For whatever reason, the 'hack' used to keep images rendered in the item list
        // will NOT render the first list index upon being initialized.
        // To get around this, a filter is set and cleared to force a list refresh.
        Component.onCompleted: {
            appController.newSaveSetSortSearchFilter("a");
            appController.newSaveSetSortSearchFilter("");
        }

        model: appController.getNewSaveArmorData();
        delegate: Item {
            id: armorItem

            property string armorName: name
            property int armorLevel: level
            property bool armorIsUnlocked: isUnlocked
            property bool armorIsUpgradeable: isUpgradeable

            function updateImage() {
                // Icons are attached by sourcing from a separate delegate list.
                // Ensures that grid elements do not need to recreate images when filtering.
                // See https://forum.qt.io/topic/154178/images-in-gridview-re-caching-on-filtering/2 for more details.
                var sourceModelRow = armorIcons.model.getArmorRowByName(armorItem.armorName);
                var imageSource = armorIcons.loadImage(sourceModelRow);
                if (imageSource !== null) {
                    delegateArmorImage.source = imageSource;
                } else {
                    delegateArmorImage.source = "";
                }
            }

            // Update the image anytime an icon moves around the grid.
            Component.onCompleted: updateImage();
            onArmorNameChanged: updateImage();

            width: armorSetupView.cellWidth
            height: armorSetupView.cellHeight

            Rectangle {
                id: armorItemRect

                anchors {
                    fill: parent
                    margins: 5
                }
                color: Material.dialogColor
                border.color: Material.accentColor
                border.width: 2
                radius: 5

                ColumnLayout {
                    id: armorContentColumn

                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 5
                        bottomMargin: 5
                    }

                    Text {
                        id: armorNameText

                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        text: armorItem.armorName
                        color: Material.primaryTextColor
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                        minimumPointSize: 5
                        fontSizeMode: Text.Fit
                    }

                    RowLayout {
                        id: armorTextRow

                        Layout.fillWidth: true

                        Repeater {
                            model: armorItem.armorLevel
                            delegate: IconImage {
                                id: armorLevelFilledIcon

                                Layout.preferredWidth: 10
                                Layout.preferredHeight: 10
                                sourceSize.width: 10
                                sourceSize.height: 10
                                source: startImageIcon.source
                                color: Material.primaryTextColor
                                fillMode: IconImage.PreserveAspectFit
                                visible: armorItem.armorIsUpgradeable
                                asynchronous: true
                            }
                        }
                        Repeater {
                            model: 4 - armorItem.armorLevel
                            delegate: IconImage {
                                id: armorLevelEmptyIcon

                                Layout.preferredWidth: 10
                                Layout.preferredHeight: 10
                                sourceSize.width: 10
                                sourceSize.height: 10
                                source: startImageIcon.source
                                color: Material.frameColor
                                fillMode: IconImage.PreserveAspectFit
                                visible: armorItem.armorIsUpgradeable
                            }
                        }
                        Text {
                            Layout.preferredHeight: 10
                            text: (armorItem.armorIsUnlocked) ? "Unlocked" : "Locked"
                            font.italic: true
                            font.pointSize: 9
                            color: Material.secondaryTextColor
                            horizontalAlignment: Qt.AlignLeft
                            verticalAlignment: Qt.AlignVCenter
                            visible: !armorItem.armorIsUpgradeable
                        }
                    }

                    RowLayout {
                        id: armorDetailsRow

                        Layout.fillWidth: true
                        Layout.preferredHeight: 40

                        Image {
                            id: delegateArmorImage

                            Layout.preferredWidth: parent.height
                            Layout.preferredHeight: parent.height
                            sourceSize.width: parent.height
                            sourceSize.height: parent.height
                            Layout.alignment: Qt.AlignLeft
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: true

                            // If armor is unlocked, gray out picture.
                            Rectangle {
                                anchors.fill: parent
                                color: "gray"
                                opacity: 0.5
                                visible: !armorItem.armorIsUnlocked
                            }
                        }

                        IconImage {
                            id: armorUnlockedIcon

                            Layout.preferredWidth: 12
                            Layout.preferredHeight: 12
                            Layout.leftMargin: 3
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            sourceSize.width: 12
                            sourceSize.height: 12
                            source: "images/lock-solid.svg"
                            color: Material.primaryTextColor
                            fillMode: IconImage.PreserveAspectFit
                            visible: !armorItem.armorIsUnlocked
                        }

                        // SPACER.
                        Item {
                            Layout.fillWidth: true
                        }

                        // LEVEL MODIFIERS.
                        RowLayout {
                            id: armorLevelColumnLayout

                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Rectangle {
                                id: armorLevelDownButton

                                Layout.preferredHeight: parent.height
                                Layout.preferredWidth: 25
                                color: (enabled) ? Material.frameColor : Material.backgroundDimColor
                                radius: 2
                                visible: armorItem.armorIsUpgradeable
                                // Enabled as long as the armor is unlocked (since level can be reduced until it locks).
                                enabled: armorItem.armorIsUnlocked

                                Text {
                                    id: armorLevelDownText

                                    anchors.fill: parent
                                    text: "-"
                                    font.pointSize: 11
                                    font.bold: true
                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter
                                    color: Material.primaryTextColor

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            // If the armor is being reduced to below 0, lock it instead.
                                            if (armorItem.armorLevel === minimumArmorLevel) {
                                                appController.toggleArmorUnlock(armorItem.armorName, true);
                                            }
                                            // Otherwise, decrease the armor level.
                                            else {
                                                appController.decreaseArmorLevel(armorItem.armorName, true);
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: armorLevelUpButton

                                Layout.preferredHeight: parent.height
                                Layout.preferredWidth: 25
                                color: (enabled) ? Material.frameColor : Material.backgroundDimColor
                                radius: 2
                                visible: armorItem.armorIsUpgradeable
                                // Enabled as long as the armor is below the maximum level.
                                enabled: (armorItem.armorLevel < maximumArmorLevel)

                                Text {
                                    id: armorLevelUpText

                                    anchors.fill: parent
                                    text: "+"
                                    font.pointSize: 11
                                    font.bold: true
                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter
                                    color: Material.primaryTextColor

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            // If armor is locked, unlock it.
                                            if (!armorItem.armorIsUnlocked) {
                                                appController.toggleArmorUnlock(armorItem.armorName, true);
                                            }
                                            // Otherwise, increase the armor level.
                                            else {
                                                appController.increaseArmorLevel(armorItem.armorName, true);
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: armorUnlockButton

                                Layout.preferredHeight: parent.height
                                Layout.preferredWidth: 25
                                color: (enabled) ? Material.frameColor : Material.backgroundDimColor
                                radius: 2
                                // Always enabled, always visible.
                                visible: true
                                enabled: true

                                IconImage {
                                    id: armorUnlockIcon

                                    anchors.centerIn: parent
                                    width: 10
                                    height: 10
                                    sourceSize.width: width
                                    sourceSize.height: height
                                    source: (armorItem.armorIsUnlocked) ? lockedImageIcon.source : unlockedImageIcon.source
                                    color: Material.primaryTextColor
                                    asynchronous: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        // Toggle armor unlock state.
                                        appController.toggleArmorUnlock(armorItem.armorName, true);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
