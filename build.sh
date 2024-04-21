#!/bin/bash

# Initialize bin directory, if not existing.
echo Generating bin directory...
mkdir -p bin
cd bin

# Clean and run qmake/make build steps.
echo Building new exe...
make clean -j4
qmake ../project/TotkArmorTracker.pro -spec linux-g++ CONFIG+=qtquickcompiler
make -j4

# If flags are raised to compress outputs, tar all generated files.
if [ "$1" = "--compress" ]
then
    echo Compressing outputs...
    tar -cf totkArmorTracker.tar *.*
    mv totkArmorTracker.tar ..
fi

exit 0
