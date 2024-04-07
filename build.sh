#!/bin/bash

# Initialize bin directory, if not existing.
echo Generating bin directory...
mkdir -p bin
cd bin

# Clean and run qmake/make build steps.
echo Building new exe...
"/usr/bin/make" clean -j4
"/opt/Qt/6.5.2/gcc_64/bin/qmake" ../project/TotkArmorTracker.pro -spec linux-g++ CONFIG+=qtquickcompiler
"/usr/bin/make" -j4

# If flags are raised to compress outputs, tar all generated files.
if [ "$1" = "--compress" ]
then
    echo Compressing outputs...
    tar -cf totkArmorTracker.tar *.*
    mv totkArmorTracker.tar ..
fi

exit 0
