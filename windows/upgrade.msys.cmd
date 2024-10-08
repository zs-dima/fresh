@echo off
setlocal

set MSYS2_PATH=c:\dev\msys64
set MSYS2_SHELL=%MSYS2_PATH%\usr\bin\bash.exe

echo Updating MSYS2 and installed packages...
%MSYS2_SHELL% -l -c "pacman -Syuu --noconfirm"

echo.
echo MSYS2 update completed.