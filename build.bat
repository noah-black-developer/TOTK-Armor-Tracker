@echo off

REM Parse user inputs for tool paths.
set "qtPath=C:\Qt"
if not "%1"=="" (
    if not "%1"=="--compress" (
        set "qtPath=%1"
    )
)
if not "%2"=="" (
    if not "%2"=="--compress" (
        set "qtPath=%2"
    )
)

REM Parse user inputs for command line arguments.
set "compress=false"
if "%1"=="--compress" set "compress=true"
if "%2"=="--compress" set "compress=true"

REM Initialize bin directory, if not existing.
echo Generating bin directory...
if not exist "./bin" mkdir "bin"
cd bin

REM Clean and run qmake/make build steps.
echo Building new exe...
"%qtPath%\Tools\mingw1120_64\bin\mingw32-make.exe" clean
"%qtPath%\6.5.3\mingw_64\bin\qmake.exe" ../project/TotkArmorTracker.pro -spec win32-g++ "CONFIG+=qtquickcompiler"
"%qtPath%\Tools\mingw1120_64\bin\mingw32-make.exe" -f Makefile qmake_all
"%qtPath%\Tools\mingw1120_64\bin\mingw32-make.exe"

REM Run windeployqt to give the generated exe all required dll's.
copy *.xml release
windeployqt.exe ./release/TotkArmorTracker.exe --qmldir ../project

REM (OPTIONAL) Compress the final project using 7zip and move to the parent directory.
if "%compress%"=="true" (
    "C:\Program Files\7-Zip\7z.exe" a totkArmorTracker.zip .\release\*
    move /y totkArmorTracker.zip ..
)

cd ..
REM exit 0
