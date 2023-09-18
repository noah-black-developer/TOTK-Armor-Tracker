import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: newSaveRoot

    width: 600
    height: 500
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

            Text {
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
        ListView {
            id: armorConfigGridView

            Layout.row: 1
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 5
            clip: true

            model: armorSetListModel
            delegate: Rectangle {
                id: armorRect

                width: 300
                height: 40

                Image {
                    id: armorImage

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                    }
                    width: height
                    source: "images/" + name + ".png"
                }
                Text {
                    id: armorName

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: armorImage.right
                        leftMargin: 5
                    }
                    verticalAlignment: Qt.AlignVCenter
                    text: name
                }

                Button {
                    id: armorIncreaseButton

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                        margins: 5
                    }
                    width: height
                    text: ">"
                }
                Button {
                    id: armorDecreaseButton

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: armorIncreaseButton.left
                        margins: 5
                    }
                    width: height
                    text: "<"
                }
            }
        }
    }
}
