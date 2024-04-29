@echo off

REM Parse user inputs for command line arguments.
set "qtdir="
if not "%1"=="" (
    if not "%1"=="--compress" (
        set "qtdir=%1"
    )
)

if "%qtdir%"=="" (
    echo Building with PATH qt installation.
) else (
    echo Building with custom qt installation.
    echo         jom path: %qtdir%\Tools\QtCreator\bin\jom\jom.exe
    echo       qmake path: %qtdir%\6.5.3\msvc2019_64\bin\qmake.exe
    echo windeployqt path: %qtdir%\6.5.3\msvc2019_64\bin\windeployqt.exe
)

set "compress=false"
if "%1"=="--compress" set "compress=true"
if "%2"=="--compress" set "compress=true"

REM Initialize bin directory, if not existing.
echo Generating bin directory...
if not exist "./bin" mkdir "bin"
cd bin

REM Clean and run qmake/make build steps.
echo Building new exe...
if "%qtdir%"=="" (
    call vcvarsall.bat x64
    jom clean
    qmake ../project/TotkArmorTracker.pro -spec win32-msvc "CONFIG+=qtquickcompiler"
    jom -f Makefile qmake_all
    jom
) else (
    call vcvarsall.bat x64
    "%qtdir%\Tools\QtCreator\bin\jom\jom.exe" clean
    "%qtdir%\6.5.3\msvc2019_64\bin\qmake.exe" ../project/TotkArmorTracker.pro -spec win32-msvc "CONFIG+=qtquickcompiler"
    "%qtdir%\Tools\QtCreator\bin\jom\jom.exe" -f Makefile qmake_all
    "%qtdir%\Tools\QtCreator\bin\jom\jom.exe"
)

REM Copy required Qt .dll files and other build-specific files
copy *.xml release
if "%qtdir%"=="" (
    windeployqt ./release/TotkArmorTracker.exe --qmldir ../project
) else (
    "%qtdir%\6.5.3\msvc2019_64\bin\windeployqt.exe" ./release/TotkArmorTracker.exe --qmldir ../project
)

REM (OPTIONAL) Compress the final project using 7zip and move to the parent directory.
if "%compress%"=="true" (
    "C:\Program Files\7-Zip\7z.exe" a TotkArmorTracker_Windows.zip .\release\*
    move /y TotkArmorTracker_Windows.zip ..
)

cd ..
