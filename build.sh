#!/bin/bash

# Check for command line args.
if [ "$1" != "" -a "$1" != "--compress" ]
then
    qtdir="$1"
    echo Building with custom qt installation.
    echo qmake path: $qtdir/6.5.3/gcc_64/bin/qmake
else
    qtdir=""
    echo Building with PATH qt installation.
fi

# Initialize bin directory, if not existing.
echo Generating bin directory...
mkdir -p bin
cd bin

# Clean and run qmake/make build steps.
echo Building new exe...
if [ "$qtdir" = "" ]
then
    make clean -j
    qmake ../project/TotkArmorTracker.pro -spec linux-g++ CONFIG+=qtquickcompiler
    make -j
else
    make clean -j
    "$qtdir/6.5.3/gcc_64/bin/qmake" ../project/TotkArmorTracker.pro -spec linux-g++ CONFIG+=qtquickcompiler
    make -j
fi

# If flags are raised to compress outputs, zip all generated files.
if [ "$1" = "--compress" -o "$2" = "--compress" ]
then
    echo Compressing outputs...
    7z a TotkArmorTracker_Linux.zip *
    mv TotkArmorTracker_Linux.zip ..
fi

cd ..
