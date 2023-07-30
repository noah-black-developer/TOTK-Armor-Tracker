

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.XmlListModel

Rectangle {
    id: rectangle1
    height: 900
    width: 1600

    // Armor Data.
    // Defines what data should be read, but the source is set at runtime.

    // UI Controls.
    Rectangle {
        id: leftControlsRectangle
        width: 320
        color: "#dedede"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        // Armor Icon (Buttons).
        // Show the user what armors they have unlocked and
        // what tier those armor pieces are currently at.
        ScrollView {
            id: armorIconsFlickable

            anchors.fill: parent
            contentWidth: armorIconsGrid.width
            contentHeight: armorIconsGrid.height + 200

            // Allow the list to extend past the current window.
            clip: true

            Grid {
                id: armorIconsGrid
                columns: 3

                // ARMOR ICONS.
                // By default, each armor set loads in with just an object name.
                // UI is initialized from c++ at runtime for things like name, image, etc.
                ArmorIcon { objectName: "Amber Earrings" }
                ArmorIcon { objectName: "Ancient Hero's Aspect" }
                ArmorIcon { objectName: "Archaic Legwear" }
                ArmorIcon { objectName: "Archaic Tunic" }
                ArmorIcon { objectName: "Archaic Warm Greaves" }
                ArmorIcon { objectName: "Barbarian Armor" }
                ArmorIcon { objectName: "Barbarian Helm" }
                ArmorIcon { objectName: "Barbarian Leg Wraps" }
                ArmorIcon { objectName: "Bokoblin Mask" }
                ArmorIcon { objectName: "Cap of Time" }
                ArmorIcon { objectName: "Cap of Twilight" }
                ArmorIcon { objectName: "Cap of the Hero" }
                ArmorIcon { objectName: "Cap of the Sky" }
                ArmorIcon { objectName: "Cap of the Wild" }
                ArmorIcon { objectName: "Cap of the Wind" }
                ArmorIcon { objectName: "Cece's Hat" }
                ArmorIcon { objectName: "Champion's Leathers" }
                ArmorIcon { objectName: "Charged Headdress" }
                ArmorIcon { objectName: "Charged Shirt" }
                ArmorIcon { objectName: "Charged Trousers" }
                ArmorIcon { objectName: "Climber's Bandana" }
                ArmorIcon { objectName: "Climbing Boots" }
                ArmorIcon { objectName: "Climbing Gear" }
                ArmorIcon { objectName: "Dark Hood" }
                ArmorIcon { objectName: "Dark Trousers" }
                ArmorIcon { objectName: "Dark Tunic" }
                ArmorIcon { objectName: "Desert Voe Headband" }
                ArmorIcon { objectName: "Desert Voe Spaulder" }
                ArmorIcon { objectName: "Desert Voe Trousers" }
                ArmorIcon { objectName: "Diamond Circlet" }
                ArmorIcon { objectName: "Ember Headdress" }
                ArmorIcon { objectName: "Ember Shirt" }
                ArmorIcon { objectName: "Ember Trousers" }
                ArmorIcon { objectName: "Evil Spirit Armor" }
                ArmorIcon { objectName: "Evil Spirit Greaves" }
                ArmorIcon { objectName: "Evil Spirit Mask" }
                ArmorIcon { objectName: "Fierce Deity Armor" }
                ArmorIcon { objectName: "Fierce Deity Boots" }
                ArmorIcon { objectName: "Fierce Deity Mask" }
                ArmorIcon { objectName: "Flamebreaker Armor" }
                ArmorIcon { objectName: "Flamebreaker Boots" }
                ArmorIcon { objectName: "Flamebreaker Helm" }
                ArmorIcon { objectName: "Froggy Hood" }
                ArmorIcon { objectName: "Froggy Leggings" }
                ArmorIcon { objectName: "Froggy Sleeve" }
                ArmorIcon { objectName: "Frostbite Headdress" }
                ArmorIcon { objectName: "Frostbite Shirt" }
                ArmorIcon { objectName: "Frostbite Trousers" }
                ArmorIcon { objectName: "Gaiters of the Depths" }
                ArmorIcon { objectName: "Glide Mask" }
                ArmorIcon { objectName: "Glide Shirt" }
                ArmorIcon { objectName: "Glide Tights" }
                ArmorIcon { objectName: "Hood of the Depths" }
                ArmorIcon { objectName: "Horriblin Mask" }
                ArmorIcon { objectName: "Hylian Hood" }
                ArmorIcon { objectName: "Hylian Trousers" }
                ArmorIcon { objectName: "Hylian Tunic" }
                ArmorIcon { objectName: "Korok Mask" }
                ArmorIcon { objectName: "Lizalfos Mask" }
                ArmorIcon { objectName: "Lobster Shirt" }
                ArmorIcon { objectName: "Lynel Mask" }
                ArmorIcon { objectName: "Majora's Mask" }
                ArmorIcon { objectName: "Mask of Awakening" }
                ArmorIcon { objectName: "Midna's Helmet" }
                ArmorIcon { objectName: "Miner's Mask" }
                ArmorIcon { objectName: "Miner's Top" }
                ArmorIcon { objectName: "Miner's Trousers" }
                ArmorIcon { objectName: "Moblin Mask" }
                ArmorIcon { objectName: "Mystic Headpiece" }
                ArmorIcon { objectName: "Mystic Robe" }
                ArmorIcon { objectName: "Mystic Trousers" }
                ArmorIcon { objectName: "Opal Earrings" }
                ArmorIcon { objectName: "Phantom Armor" }
                ArmorIcon { objectName: "Phantom Greaves" }
                ArmorIcon { objectName: "Phantom Helmet" }
                ArmorIcon { objectName: "Radiant Mask" }
                ArmorIcon { objectName: "Radiant Shirt" }
                ArmorIcon { objectName: "Radiant Tights" }
                ArmorIcon { objectName: "Ravio's Hood" }
                ArmorIcon { objectName: "Royal Guard Boots" }
                ArmorIcon { objectName: "Royal Guard Cap" }
                ArmorIcon { objectName: "Royal Guard Uniform" }
                ArmorIcon { objectName: "Rubber Armor" }
                ArmorIcon { objectName: "Rubber Helm" }
                ArmorIcon { objectName: "Rubber Tights" }
                ArmorIcon { objectName: "Ruby Circlet" }
                ArmorIcon { objectName: "Sand Boots" }
                ArmorIcon { objectName: "Sapphire Circlet" }
                ArmorIcon { objectName: "Sheik's Mask" }
                ArmorIcon { objectName: "Snow Boots" }
                ArmorIcon { objectName: "Snowquill Headdress" }
                ArmorIcon { objectName: "Snowquill Trousers" }
                ArmorIcon { objectName: "Snowquill Tunic" }
                ArmorIcon { objectName: "Soldier's Armor" }
                ArmorIcon { objectName: "Soldier's Greaves" }
                ArmorIcon { objectName: "Soldier's Helm" }
                ArmorIcon { objectName: "Stealth Chest Guard" }
                ArmorIcon { objectName: "Stealth Mask" }
                ArmorIcon { objectName: "Stealth Tights" }
                ArmorIcon { objectName: "Thunder Helm" }
                ArmorIcon { objectName: "Tingle's Hood" }
                ArmorIcon { objectName: "Tingle's Shirt" }
                ArmorIcon { objectName: "Tingle's Tights" }
                ArmorIcon { objectName: "Topaz Earrings" }
                ArmorIcon { objectName: "Trousers of Awakening" }
                ArmorIcon { objectName: "Trousers of Time" }
                ArmorIcon { objectName: "Trousers of Twilight" }
                ArmorIcon { objectName: "Trousers of the Hero" }
                ArmorIcon { objectName: "Trousers of the Sky" }
                ArmorIcon { objectName: "Trousers of the Wild" }
                ArmorIcon { objectName: "Trousers of the Wind" }
                ArmorIcon { objectName: "Tunic of Awakening" }
                ArmorIcon { objectName: "Tunic of Memories" }
                ArmorIcon { objectName: "Tunic of Time" }
                ArmorIcon { objectName: "Tunic of Twilight" }
                ArmorIcon { objectName: "Tunic of the Depths" }
                ArmorIcon { objectName: "Tunic of the Hero" }
                ArmorIcon { objectName: "Tunic of the Sky" }
                ArmorIcon { objectName: "Tunic of the Wild" }
                ArmorIcon { objectName: "Tunic of the Wind" }
                ArmorIcon { objectName: "Vah Medoh Divine Helm" }
                ArmorIcon { objectName: "Vah Naboris Divine Helm" }
                ArmorIcon { objectName: "Vah Rudania Divine Helm" }
                ArmorIcon { objectName: "Vah Ruta Divine Helm" }
                ArmorIcon { objectName: "Well-Worn Hair Band" }
                ArmorIcon { objectName: "Yiga Armor" }
                ArmorIcon { objectName: "Yiga Mask" }
                ArmorIcon { objectName: "Yiga Tights" }
                ArmorIcon { objectName: "Zant's Helmet" }
                ArmorIcon { objectName: "Zonaite Helm" }
                ArmorIcon { objectName: "Zonaite Shin Guards" }
                ArmorIcon { objectName: "Zonaite Waistguard" }
                ArmorIcon { objectName: "Zora Armor" }
                ArmorIcon { objectName: "Zora Greaves" }
                ArmorIcon { objectName: "Zora Helm" }
            }
        }
    }

    Rectangle {
        id: rightControlsRectangle
        width: 400
        color: "#dedede"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
}
