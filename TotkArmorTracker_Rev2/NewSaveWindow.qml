import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: newSaveRoot

    width: 600
    height: 500
    minimumWidth: 600
    maximumWidth: 600
    title: "Create a New Save"

    // ARMOR LIST.
    // Model storing data on all available armor sets.
    ListModel {
        id: armorSetListModel

        ListElement { name: "Amber Earrings" }
        ListElement { name: "Ancient Hero's Aspect" }
        ListElement { name: "Archaic Legwear" }
        ListElement { name: "Archaic Tunic" }
        ListElement { name: "Archaic Warm Greaves" }
        ListElement { name: "Barbarian Armor" }
        ListElement { name: "Barbarian Helm" }
        ListElement { name: "Barbarian Leg Wraps" }
        ListElement { name: "Bokoblin Mask" }
        ListElement { name: "Cap of Time" }
        ListElement { name: "Cap of Twilight" }
        ListElement { name: "Cap of the Hero" }
        ListElement { name: "Cap of the Sky" }
        ListElement { name: "Cap of the Wild" }
        ListElement { name: "Cap of the Wind" }
        ListElement { name: "Champion's Leathers" }
        ListElement { name: "Charged Headdress" }
        ListElement { name: "Charged Shirt" }
        ListElement { name: "Charged Trousers" }
        ListElement { name: "Climber's Bandana" }
        ListElement { name: "Climbing Boots" }
        ListElement { name: "Climbing Gear" }
        ListElement { name: "Dark Trousers" }
        ListElement { name: "Desert Voe Headband" }
        ListElement { name: "Desert Voe Spaulder" }
        ListElement { name: "Desert Voe Trousers" }
        ListElement { name: "Diamond Circlet" }
        ListElement { name: "Ember Headdress" }
        ListElement { name: "Ember Shirt" }
        ListElement { name: "Ember Trousers" }
        ListElement { name: "Evil Spirit Armor" }
        ListElement { name: "Evil Spirit Greaves" }
        ListElement { name: "Evil Spirit Mask" }
        ListElement { name: "Fierce Deity Armor" }
        ListElement { name: "Fierce Deity Boots" }
        ListElement { name: "Fierce Deity Mask" }
        ListElement { name: "Flamebreaker Armor" }
        ListElement { name: "Flamebreaker Boots" }
        ListElement { name: "Flamebreaker Helm" }
        ListElement { name: "Froggy Hood" }
        ListElement { name: "Froggy Leggings" }
        ListElement { name: "Froggy Sleeve" }
        ListElement { name: "Frostbite Headdress" }
        ListElement { name: "Frostbite Shirt" }
        ListElement { name: "Frostbite Trousers" }
        ListElement { name: "Gaiters of the Depths" }
        ListElement { name: "Glide Shirt" }
        ListElement { name: "Glide Tights" }
        ListElement { name: "Hood of the Depths" }
        ListElement { name: "Horriblin Mask" }
        ListElement { name: "Hylian Hood" }
        ListElement { name: "Hylian Trousers" }
        ListElement { name: "Hylian Tunic" }
        ListElement { name: "Lizalfos Mask" }
        ListElement { name: "Lobster Shirt" }
        ListElement { name: "Majora's Mask" }
        ListElement { name: "Mask of Awakening" }
        ListElement { name: "Midna's Helmet" }
        ListElement { name: "Miner's Mask" }
        ListElement { name: "Miner's Top" }
        ListElement { name: "Miner's Trousers" }
        ListElement { name: "Moblin Mask" }
        ListElement { name: "Mystic Headpiece" }
        ListElement { name: "Mystic Robe" }
        ListElement { name: "Mystic Trousers" }
        ListElement { name: "Opal Earrings" }
        ListElement { name: "Phantom Armor" }
        ListElement { name: "Phantom Greaves" }
        ListElement { name: "Phantom Helmet" }
        ListElement { name: "Radiant Mask" }
        ListElement { name: "Radiant Shirt" }
        ListElement { name: "Radiant Tights" }
        ListElement { name: "Ravio's Hood" }
        ListElement { name: "Royal Guard Boots" }
        ListElement { name: "Royal Guard Cap" }
        ListElement { name: "Royal Guard Uniform" }
        ListElement { name: "Rubber Armor" }
        ListElement { name: "Rubber Helm" }
        ListElement { name: "Rubber Tights" }
        ListElement { name: "Ruby Circlet" }
        ListElement { name: "Sapphire Circlet" }
        ListElement { name: "Sheik's Mask" }
        ListElement { name: "Snowquill Headdress" }
        ListElement { name: "Snowquill Trousers" }
        ListElement { name: "Snowquill Tunic" }
        ListElement { name: "Soldier's Armor" }
        ListElement { name: "Soldier's Greaves" }
        ListElement { name: "Soldier's Helm" }
        ListElement { name: "Stealth Chest Guard" }
        ListElement { name: "Stealth Mask" }
        ListElement { name: "Stealth Tights" }
        ListElement { name: "Thunder Helm" }
        ListElement { name: "Tingle's Hood" }
        ListElement { name: "Tingle's Shirt" }
        ListElement { name: "Tingle's Tights" }
        ListElement { name: "Topaz Earrings" }
        ListElement { name: "Trousers of Awakening" }
        ListElement { name: "Trousers of Time" }
        ListElement { name: "Trousers of Twilight" }
        ListElement { name: "Trousers of the Hero" }
        ListElement { name: "Trousers of the Sky" }
        ListElement { name: "Trousers of the Wild" }
        ListElement { name: "Trousers of the Wind" }
        ListElement { name: "Tunic of Awakening" }
        ListElement { name: "Tunic of Memories" }
        ListElement { name: "Tunic of Time" }
        ListElement { name: "Tunic of Twilight" }
        ListElement { name: "Tunic of the Depths" }
        ListElement { name: "Tunic of the Hero" }
        ListElement { name: "Tunic of the Sky" }
        ListElement { name: "Tunic of the Wild" }
        ListElement { name: "Tunic of the Wind" }
        ListElement { name: "Vah Medoh Divine Helm" }
        ListElement { name: "Vah Naboris Divine Helm" }
        ListElement { name: "Vah Rudania Divine Helm" }
        ListElement { name: "Vah Ruta Divine Helm" }
        ListElement { name: "Well-Worn Hair Band" }
        ListElement { name: "Yiga Tights" }
        ListElement { name: "Zant's Helmet" }
        ListElement { name: "Zonaite Helm" }
        ListElement { name: "Zonaite Shin Guards" }
        ListElement { name: "Zonaite Waistguard" }
        ListElement { name: "Zora Greaves" }
        ListElement { name: "Zora Helm" }
    }

    Pane {
        id: newSavePane

        anchors.fill: parent

        // Window elements.
        GridLayout {
            id: newSaveCentralColumn

            anchors {
                fill: parent
                margins: 20
            }
            rows: 2

            // SAVE NAME.
            RowLayout {
                id: saveNameRow

                Layout.row: 0

                Label {
                    id: saveNameText

                    text: "Save Name:"
                }

                TextField {
                    id: saveNameTextField

                    placeholderText: "Type save name here"
                    Layout.preferredWidth: 300
                }
            }

            // ARMOR CONFIGURATION.
            // Gives the user a list of template armor pieces to select from.
            Rectangle {
                id: armorConfigBorderRect

                Layout.row: 1
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: 10

                color: "darkgray"
                border.color: "gray"
                border.width: 3

                GridView {
                    id: armorConfigGridView

                    width: (idealCellWidth * 3)
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        bottom: parent.bottom
                        margins: 10
                    }

                    // "Desired" properties - view shoots to set spacing as these values,
                    // but will adjust actual values as needed to fit in given space.
                    property int idealCellWidth: 160
                    property int idealCellHeight: 160
                    property int spacing: 30

                    clip: true

                    cellWidth: width / Math.floor(width / idealCellWidth)
                    cellHeight: idealCellHeight
                    model: armorSetListModel
                    delegate: Rectangle {
                        id: armorSetup

                        width: armorConfigGridView.cellWidth - armorConfigGridView.spacing
                        height: armorConfigGridView.cellHeight - armorConfigGridView.spacing
                        color: "#494b4b"

                        // Armor Image.
                        Image {
                            id: armorImage

                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                leftMargin: 20
                                rightMargin: 20
                            }
                            height: width
                            source: "images/" + name + ".png"
                        }

                        // Armor Name.
                        Text {
                            id: armorName

                            width: parent.width
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                top: armorImage.bottom
                            }
                            color: "white"
                            text: name
                            horizontalAlignment: Qt.AlignHCenter
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 5
                            font.pixelSize: 12
                        }

                        // Armor Details/Controls.
                        RowLayout {
                            id: armorDetailsRow

                            height: 30
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: armorName.bottom
                                leftMargin: 20
                                rightMargin: 20
                            }

                            // Unlock Buttons.
                            Button {
                                id: unlockArmorButton

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: "Unlock"
                                z: 0
                                // Initally shown to the user.
                                visible: true

                                onPressed: {
                                    // When pressed, toggle widget settings to move into level adjustment.
                                    visible = false;
                                    levelDownButton.visible = true;
                                    levelUpButton.visible = true;
                                }
                            }

                            // Upgrade Buttons.
                            Button {
                                id: levelDownButton

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: "<"
                                z: 1
                                // Initally hidden from the user.
                                visible: false
                            }
                            Button {
                                id: levelUpButton

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: ">"
                                z: 1
                                // Initally hidden from the user.
                                visible: false
                            }
                        }
                    }
                }

            }

        }
    }
}
