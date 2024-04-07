#!/bin/bash

"/usr/bin/make" clean -j4
"/opt/Qt/6.5.2/gcc_64/bin/qmake" /home/noah/Documents/GitHub/TOTK-Armor-Tracker/TotkArmorTracker/TotkArmorTracker.pro -spec linux-g++ CONFIG+=qtquickcompiler
"/usr/bin/make" -j4
exit 0
