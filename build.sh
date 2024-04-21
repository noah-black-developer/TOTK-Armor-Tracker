#!/bin/bash

# Initialize bin directory, if not existing.
echo Generating bin directory...
mkdir -p bin
cd bin

# Clean and run qmake/make build steps.
echo Building new exe...
make clean -j
qmake ../project/TotkArmorTracker.pro -spec linux-g++ CONFIG+=qtquickcompiler
make -j

# If flags are raised to compress outputs, zip all generated files.
if [ "$1" = "--compress" ]
then
    echo Compressing outputs...
    7z a totkArmorTracker_linux.zip *
    mv totkArmorTracker_linux.zip ..
fi

exit 0
