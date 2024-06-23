#include <rapidxml-1.13/rapidxml.hpp>
#include <rapidxml-1.13/rapidxml_print.hpp>

// HELPER FUNCTIONS.
// Load in an XML file at given path and convert it to a parse-ready char vector.
// Inputs:
//  xmlFilePath - Path to the XML file as a QString.
// Outputs:
//  True if the file could be parsed correctly. Otherwise, false.
//  char vector object, formatted for parsing using RapidXML, will be saved to parseReadyDataOut.
inline bool readXmlToParseReadyObj(QString xmlFilePath, std::vector<char> &parseReadyDataOut)
{
    // LOAD IN XML FILE.
    // First, verify that the XML file exists.
    std::ifstream xmlFileStream;
    xmlFileStream.open(xmlFilePath.toStdString());

    std::string xmlFileString = "";
    if(xmlFileStream)
    {
        std::string xmlFileLine;

        // If so, load the XML document in as a string.
        while(std::getline(xmlFileStream, xmlFileLine))
        {
            xmlFileString += xmlFileLine;
        }

        // Close the file once finished.
        xmlFileStream.close();
    }
    else
    {
        // If the file could not be read, return a failure with error logs.
        qDebug("Given XML document could not be read correctly");
        qDebug("%s", xmlFilePath.toStdString().c_str());
        return false;
    }

    // Convert the XML string into a RapidXML-compatable document object.
    // Make a safe-to-modify copy of the save file string to load into RapidXML.
    std::vector<char> saveFileStreamCopy(xmlFileString.begin(), xmlFileString.end());
    saveFileStreamCopy.push_back('\0');

    // Save the file stream to output variables and return a success.
    parseReadyDataOut = saveFileStreamCopy;
    return true;
}

// Function to check for the existance of a file in the local file system.
// https://stackoverflow.com/questions/12774207/fastest-way-to-check-if-a-file-exists-using-standard-c-c11-14-17-c
inline bool fileExists (const std::string& name)
{
    if (FILE *file = fopen(name.c_str(), "r")) {
        fclose(file);
        return true;
    } else {
        return false;
    }
}
