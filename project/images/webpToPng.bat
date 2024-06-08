REM @echo off

set name=%1
set name=%name:"=%
ffmpeg -y -i "%name%.webp" "%name%.png" && del "%name%.webp"
