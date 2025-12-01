@echo off
echo ========================================
echo Running Flutter App for Development
echo ========================================
echo.

cd /d "%~dp0"

echo Checking Flutter devices...
flutter devices

echo.
echo Starting Flutter app in debug mode...
echo This will install and run the app on connected device/emulator
echo.

flutter run --debug

pause

