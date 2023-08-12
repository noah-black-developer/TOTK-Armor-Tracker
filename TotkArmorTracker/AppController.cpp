#include <AppController.h>
#include <AppFunctions.cpp>

AppController::AppController(QObject *qmlRootObject, QObject *parent)
    : QObject{parent}
{
    _qmlRootObject = qmlRootObject;
}

bool AppController::appInitialize(QString armorConfigsPath)
{
    return initialize(armorConfigsPath, _qmlRootObject);
}

bool AppController::appPullSave(QUrl saveFilePath)
{
    // Convert QUrl to QString. QML file dialogs return QUrl by default,
    // which must be converted to a local path before use in backend code.
    QString convertedSaveFilePath = saveFilePath.toLocalFile();

    return pullSave(convertedSaveFilePath, _qmlRootObject);
}

bool AppController::appSetSelectedArmor(QString armorName) {
    // DESELECTED ANY CURRENT ARMOR SELECTIONS.
    // If the class object _selectedArmor is not null, some armor is currently selected.
    // Make sure it is deselected before selecting the new one.
    if (_selectedArmor != nullptr) {
        // Get and deselect the current selection.
        QObject *currentSelectionObj = _getArmorIconByName(_selectedArmor->property("armorName").toString());
        currentSelectionObj->setProperty("selected", false);
    }

    // Locate the associated ArmorIcon for the given armor name. If null, return a failure.
    QObject *newSelectionObj = _getArmorIconByName(armorName);
    if (newSelectionObj == nullptr) {
        return false;
    }

    // Set new armor as the selected armor.
    newSelectionObj->setProperty("selected", true);
    _selectedArmor = newSelectionObj;
    return true;
}

void AppController::appDeselectAll() {
    // Deselect the current selection using local reference.
    QObject *currentSelectionObj = _getArmorIconByName(_selectedArmor->property("armorName").toString());
    currentSelectionObj->setProperty("selected", false);

    // Clear the local reference to selected objects and return.
    _selectedArmor = nullptr;
    return;
}

// Private method to get the associated ArmorIcon object for a given armor name.
// Inputs:
//  armorName - Name of the armor to select, as a QString.
// Outputs:
//  Returns a pointer to the ArmorIcon object, if successful. Otherwise, returns a nullptr.
QObject* AppController::_getArmorIconByName(QString armorName) {
    // Search for the object. If not found, findChild auto-returns a nullptr.
    return _qmlRootObject->findChild<QObject*>(armorName);
}
