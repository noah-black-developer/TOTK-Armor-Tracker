import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: armorProgressPageRoot

    // DIALOGS.
    // MessageBox to confirm the unlocking of armor sets.
    MessageDialog {
        id: unlockMessageDialog

        property string armorSetName: "lorem ipsum"

        text: "Unlock the " + armorSetName + "?"
        buttons: MessageDialog.Ok | MessageDialog.Cancel
    }

    // Armor Image.
    // Displays a background image of ,the currently selected armor.
    Image {
        id: selectedArmorImage
        objectName: "selectedArmorImage"

        width: 350
        height: 350
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        // Uses a default blank image as a starting source.
        source: "images/Default.png"
        mipmap: true
    }

    // Armor Details (Right Side).
    Rectangle {
        id: armorDetailsRectangle

        width: 280
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 10
        }
        // Sits above the other controls on the z-axis.
        z: 1
        color: "transparent"

        // Color Rectangle.
        // Separated from main rectangle to allow just the backing of the controls to be transluscent,
        // without diminishing all of the content objects (text, icons, etc...).
        Rectangle {
            id: armorDetailsColorRect

            anchors.fill: parent
            color: "#dedede"
            opacity: 0.9
        }

        // DETAILS.
        // All detail controls are kept on a flickable to allow them to scroll with smaller UI sizes.
        ScrollView {
            id: armorDetailsScrollView

            anchors.fill: parent
            clip: true

            Item {
                id: armorDetailsContentsWrapper

                width: parent.width
                height: childrenRect.height
                implicitHeight: height

                // DETAILS COLUMN.
                // Contains fields for armor info, decorative objects, etc...
                ColumnLayout {
                    id: armorDetailsColumnLayout

                    width: parent.width

                    // SPACER.
                    // Add a blank element to push down the contents of the column a bit.
                    Item {
                        id: armorDetailsTopSpacer
                        Layout.preferredHeight: 20
                    }

                    // ARMOR LEVEL ROW.
                    Row {
                        id: armorLevelRow
                        objectName: "armorLevelRow"

                        property int armorLevel: 0

                        // Only visible if the armor has a level above 0.
                        visible: (armorLevel > 0)
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 1

                        Repeater {
                            id: armorLevelIcons

                            model: armorLevelRow.armorLevel

                            Image {
                                required property int index

                                width: 15
                                height: width

                                fillMode: Image.PreserveAspectFit

                                source: "images/star-solid.svg"
                            }
                        }
                    }

                    // ARMOR NAME ROW.
                    Row {
                        id: armorRowLayout

                        spacing: 8
                        Layout.alignment: Qt.AlignHCenter

                        // Selected Armor Name.
                        Text {
                            id: selectedArmorNameLabel
                            objectName: "selectedArmorNameLabel"

                            text: "Lorem Ipsum"
                            font.bold: true
                            font.pointSize: 14
                        }

                        // Unlock Status.
                        Image {
                            id: selectedArmorUnlockedIcon
                            objectName: "selectedArmorUnlockedIcon"

                            property bool isUnlocked: true

                            anchors {
                                verticalCenter: selectedArmorNameLabel.verticalCenter
                            }
                            source: "images/lock-solid.svg"
                            fillMode: Image.PreserveAspectFit
                            // Hidden from view by setting the icon to 0 size.
                            width: (isUnlocked) ? 0 : 18
                            height: (isUnlocked) ? 0 : 18
                        }
                    }

                    // Armor Set Name.
                    Text {
                        id: selectedArmorSetNameLabel
                        objectName: "selectedArmorSetNameLabel"

                        Layout.fillWidth: true
                        Layout.topMargin: -5
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: "Lorem Ipsum"
                        font.pointSize: 9
                    }

                    // Armor Quote.
                    Text {
                        id: selectedArmorQuoteLabel
                        objectName: "selectedArmorQuoteLabel"

                        Layout.fillWidth: true
                        Layout.margins: 5
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: "Lorem ipsum lorem ipsum lorem ipsum lorem ipsum..."
                        font.italic: true
                        font.pointSize: 8
                        wrapMode: Text.Wrap
                    }

                    // Separator.
                    Rectangle {
                        id: selectedArmorQuoteSeparator

                        Layout.preferredHeight: 2
                        Layout.fillWidth: true
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        Layout.alignment: Qt.AlignHCenter
                        color: "black"
                    }

                    // Armor Defense.
                    Text {
                        id: selectedArmorDefenseLabel
                        objectName: "selectedArmorDefenseLabel"

                        property int defense: 0

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: "> Current Defense: " + defense.toString()
                        wrapMode: Text.Wrap
                    }

                    // Passive Bonus.
                    Text {
                        id: selectedArmorPassiveLabel
                        objectName: "selectedArmorPassiveLabel"

                        property string passiveBonus: "None"

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: "> Passive Bonus: " + passiveBonus
                        wrapMode: Text.Wrap
                    }

                    // Passive Bonus.
                    Text {
                        id: selectedArmorsSetBonusLabel
                        objectName: "selectedArmorSetBonusLabel"

                        property string setBonus: "None"

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: "> Set Bonus: " + setBonus
                        wrapMode: Text.Wrap
                    }

                    // UPGRADE MATERIAL MENUS.
                    // Initializes one menu per armor tier. Displays what is required to bring armor to each tier.
                    ArmorUpgradeViewer {
                        id: armorUpgradeTierOne
                        objectName: "armorUpgradeTierOne"

                        Layout.fillWidth: true
                        Layout.topMargin: 10
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        upgradeRank: 1
                    }
                    ArmorUpgradeViewer {
                        id: armorUpgradeTierTwo
                        objectName: "armorUpgradeTierTwo"

                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        upgradeRank: 2
                    }
                    ArmorUpgradeViewer {
                        id: armorUpgradeTierThree
                        objectName: "armorUpgradeTierThree"

                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        upgradeRank: 3
                    }
                    ArmorUpgradeViewer {
                        id: armorUpgradeTierFour
                        objectName: "armorUpgradeTierFour"

                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        upgradeRank: 4
                    }

                    // UPGRADE BUTTONS.
                    // Button displayed when the armor is still locked.
                    Button {
                        id: unlockArmorButton
                        objectName: "unlockArmorButton"

                        // Non-visible by default. Handled by backend code.
                        visible: false
                        Layout.alignment: Qt.AlignHCenter
                        text: "Unlock Armor"
                        icon.source: "images/unlock-solid.svg"
                        display: Button.TextBesideIcon

                        onClicked: {
                            AppController.setArmorUnlockedState(selectedArmorNameLabel.text, true);
                        }
                    }

                    // Button displayed to increase armor level.
                    Button {
                        id: upgradeArmorButton
                        objectName: "upgradeArmorButton"

                        // Non-visible by default. Handled by backend code.
                        visible: false
                        Layout.alignment: Qt.AlignHCenter
                        text: "Enhance Away!"

                        onClicked: {
                            AppController.setArmorLevel(selectedArmorNameLabel.text, armorLevelRow.armorLevel + 1);
                        }
                    }

                    // SPACER.
                    // Add a blank element to add some space at the bottom of the column
                    Item {
                        id: armorDetailsBottomSpacer
                        Layout.preferredHeight: 20
                    }
                }
            }
        }
    }

    // Armor Progress Bar (Left Side).
    Rectangle {
        id: armorProgressRectangle

        width: 280
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 10
        }
        // Sits above the other controls on the z-axis.
        z: 1
        color: "transparent"

        // Color Rectangle.
        // Separated from main rectangle to allow just the backing of the controls to be transluscent,
        // without diminishing all of the content objects (text, icons, etc...).
        Rectangle {
            id: armorIconsColorRect

            anchors.fill: parent
            color: "#dedede"
            opacity: 0.9
        }

        // Sort Combobox.
        // Gives the user a number of different options for sorting the different armors.
        ComboBox {
            id: armorSortComboBox

            // Track initialized. Used to prevent accessing AppController before it is reachable,
            // which simplfies the code for changing selections significantly.
            property bool isInitialized: false

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }
            model: [
                "Alphabetical",
                "By Set"
            ]

            onCurrentTextChanged: {
                if(isInitialized) {
                    AppController.setArmorSort(currentText);
                }
            }

            Component.onCompleted: isInitialized = true;
        }

        // Armor Icon (Buttons).
        // Show the user what armors they have unlocked and
        // what tier those armor pieces are currently at.
        Flickable {
            id: armorIconsFlickable

            anchors {
                top: armorSortComboBox.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 10
            }

            ScrollView {
                id: armorIconsScrollView
                objectName: "armorIconsScrollView"

                // Tracks current sort displayed. Defaults to alphabetical.
                property string activeSort: "Alphabetical"

                anchors.fill: parent
                // Allow the list to extend past the current window.
                clip: true
                // Force the scrollbar to only work vertically + to make grid fit inside.
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                // ARMOR ICON ARRANGEMENTS.
                // There are several simultaneous GridLayouts initialized, each with a different sorting arrangement
                // for the armor icons based on the user's selections.
                // Some other design elements are included to increase user readability.
                Item {
                    id: sortWrapperItem

                    width: parent.width
                    height: childrenRect.height + 50
                    implicitHeight: height

                    // Alphabetical Sort.
                    GridLayout {
                        id: armorIconsGridAlphabetical
                        objectName: "Alphabetical"

                        width: parent.width
                        columns: 3

                        // Only visible if it is the active sort.
                        visible: (armorIconsScrollView.activeSort === objectName)

                        // ARMOR ICONS.
                        // By default, each armor set loads in with just an object name.
                        // UI is initialized from c++ at runtime for things like name, image, etc.
                        ArmorIcon { Layout.fillWidth: true; objectName: "Amber Earrings" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ancient Hero's Aspect" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Archaic Legwear" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Archaic Tunic" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Archaic Warm Greaves" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Barbarian Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Barbarian Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Barbarian Leg Wraps" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Bokoblin Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of Time" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of Twilight" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of the Hero" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of the Sky" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of the Wild" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of the Wind" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cece's Hat" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Champion's Leathers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Charged Headdress" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Charged Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Charged Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Climber's Bandana" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Climbing Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Climbing Gear" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Dark Hood" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Dark Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Dark Tunic" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Desert Voe Headband" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Desert Voe Spaulder" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Desert Voe Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Diamond Circlet" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ember Headdress" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ember Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ember Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Evil Spirit Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Evil Spirit Greaves" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Evil Spirit Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Fierce Deity Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Fierce Deity Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Fierce Deity Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Flamebreaker Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Flamebreaker Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Flamebreaker Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Froggy Hood" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Froggy Leggings" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Froggy Sleeve" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Frostbite Headdress" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Frostbite Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Frostbite Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Gaiters of the Depths" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Glide Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Glide Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Glide Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Hood of the Depths" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Horriblin Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Hylian Hood" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Hylian Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Hylian Tunic" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Korok Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Lizalfos Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Lobster Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Lynel Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Majora's Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Mask of Awakening" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Midna's Helmet" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Miner's Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Miner's Top" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Miner's Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Moblin Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Mystic Headpiece" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Mystic Robe" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Mystic Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Opal Earrings" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Phantom Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Phantom Greaves" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Phantom Helmet" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Radiant Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Radiant Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Radiant Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ravio's Hood" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Royal Guard Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Royal Guard Cap" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Royal Guard Uniform" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Rubber Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Rubber Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Rubber Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ruby Circlet" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Sand Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Sapphire Circlet" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Sheik's Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Snow Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Snowquill Headdress" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Snowquill Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Snowquill Tunic" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Soldier's Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Soldier's Greaves" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Soldier's Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Stealth Chest Guard" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Stealth Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Stealth Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Thunder Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tingle's Hood" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tingle's Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tingle's Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Topaz Earrings" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of Awakening" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of Time" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of Twilight" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of the Hero" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of the Sky" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of the Wild" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of the Wind" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of Awakening" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of Memories" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of Time" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of Twilight" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of the Depths" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of the Hero" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of the Sky" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of the Wild" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of the Wind" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Vah Medoh Divine Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Vah Naboris Divine Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Vah Rudania Divine Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Vah Ruta Divine Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Well-Worn Hair Band" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Yiga Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Yiga Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Yiga Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zant's Helmet" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zonaite Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zonaite Shin Guards" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zonaite Waistguard" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zora Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zora Greaves" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zora Helm" }
                    }

                    // Sort By Set Name.
                    GridLayout {
                        id: armorIconsGridBySet
                        objectName: "By Set"

                        width: parent.width
                        columns: 3

                        // Only visible if it is the active sort.
                        visible: (armorIconsScrollView.activeSort === objectName)

                        // ARMOR ICONS.
                        // By default, each armor set loads in with just an object name.
                        // UI is initialized from c++ at runtime for things like name, image, etc.
                        ArmorIcon { Layout.fillWidth: true; objectName: "Archaic Tunic" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Archaic Legwear" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Archaic Warm Greaves" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Mask of Awakening" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of Awakening" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of Awakening" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of the Wild" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of the Wild" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of the Wild" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Barbarian Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Barbarian Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Barbarian Leg Wraps" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Charged Headdress" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Charged Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Charged Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Climber's Bandana" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Climbing Gear" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Climbing Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Dark Hood" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Dark Tunic" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Dark Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Hood of the Depths" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of the Depths" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Gaiters of the Depths" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Desert Voe Headband" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Desert Voe Spaulder" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Desert Voe Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ember Headdress" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ember Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ember Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Evil Spirit Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Evil Spirit Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Evil Spirit Greaves" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Fierce Deity Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Fierce Deity Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Fierce Deity Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Flamebreaker Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Flamebreaker Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Flamebreaker Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Froggy Hood" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Froggy Sleeve" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Froggy Leggings" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Frostbite Headdress" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Frostbite Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Frostbite Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Glide Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Glide Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Glide Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of the Hero" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of the Hero" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of the Hero" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Hylian Hood" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Hylian Tunic" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Hylian Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Miner's Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Miner's Top" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Miner's Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Mystic Headpiece" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Mystic Robe" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Mystic Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Phantom Helmet" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Phantom Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Phantom Greaves" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Radiant Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Radiant Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Radiant Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Royal Guard Cap" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Royal Guard Uniform" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Royal Guard Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Rubber Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Rubber Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Rubber Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of the Sky" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of the Sky" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of the Sky" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Snowquill Headdress" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Snowquill Tunic" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Snowquill Trousers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Soldier's Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Soldier's Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Soldier's Greaves" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Stealth Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Stealth Chest Guard" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Stealth Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of Time" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of Time" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of Time" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tingle's Hood" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tingle's Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tingle's Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of Twilight" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of Twilight" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of Twilight" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cap of the Wind" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of the Wind" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Trousers of the Wind" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Yiga Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Yiga Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Yiga Tights" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zonaite Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zonaite Waistguard" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zonaite Shin Guards" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zora Armor" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zora Greaves" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zora Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Amber Earrings" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ancient Hero's Aspect" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Bokoblin Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Cece's Hat" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Champion's Leathers" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Diamond Circlet" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Horriblin Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Korok Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Lizalfos Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Lobster Shirt" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Lynel Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Majora's Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Midna's Helmet" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Moblin Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Opal Earrings" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ravio's Hood" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Ruby Circlet" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Sand Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Sapphire Circlet" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Sheik's Mask" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Snow Boots" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Thunder Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Topaz Earrings" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Tunic of Memories" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Vah Medoh Divine Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Vah Naboris Divine Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Vah Rudania Divine Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Vah Ruta Divine Helm" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Well-Worn Hair Band" }
                        ArmorIcon { Layout.fillWidth: true; objectName: "Zant's Helmet" }
                    }
                }
            }
        }
    }
}
