#ifndef SAVECONTROL_H
#define SAVECONTROL_H

// Header file defining functions to load/save/edit user saves.
// Author: Noah Black
// Date: July 15th, 2023

// Converting to/from xml-style save files.
bool convertXmlSaveFileToSaveStruct();
bool convertSaveStructToUserSaveFile();

// Create a save struct from current user changes.
bool generateCurrentSaveStruct();

// Create a new 'blank' save struct.
bool createNewSaveStruct();

#endif // SAVECONTROL_H
