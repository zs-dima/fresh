@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process wt.exe -ArgumentList 'cmd /k \"%~f0\"' -Verb RunAs"
    exit /b
)

@REM winget pin add Google.CloudSDK
call winget upgrade --all --include-unknown
call choco upgrade all -y
call rustup update
call dart pub global activate fvm
call gcloud components update --quiet
wsl --update
py install --update

echo.
echo All done.
pause

