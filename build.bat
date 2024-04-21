@echo off

REM Parse user inputs for command line arguments.
set "compress=false"
if "%1"=="--compress" set "compress=true"

REM Initialize bin directory, if not existing.
echo Generating bin directory...
if not exist "./bin" mkdir "bin"
cd bin

REM Clean and run qmake/make build steps.
echo Building new exe...
mingw32-make clean
qmake ../project/TotkArmorTracker.pro -spec win32-g++ "CONFIG+=qtquickcompiler"
mingw32-make -f Makefile qmake_all
mingw32-make

REM Run windeployqt to give the generated exe all required dll's.
copy *.xml release
windeployqt ./release/TotkArmorTracker.exe --qmldir ../project

REM (OPTIONAL) Compress the final project using 7zip and move to the parent directory.
if "%compress%"=="true" (
    "C:\Program Files\7-Zip\7z.exe" a totkArmorTracker.zip .\release\*
    move /y totkArmorTracker.zip ..
)

cd ..
REM exit 0
