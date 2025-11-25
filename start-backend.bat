@echo off
echo ========================================
echo   Starting Backend Development Server
echo ========================================
echo.

cd backend

echo Checking Node.js installation...
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed!
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo Node.js is installed
echo.

echo Checking if node_modules exists...
if not exist "node_modules\" (
    echo Installing dependencies...
    echo This may take a few minutes...
    call npm install
    echo.
) else (
    echo Dependencies already installed
    echo.
)

echo ========================================
echo   Starting server on http://localhost:3000
echo ========================================
echo.
echo Press Ctrl+C to stop the server
echo.

node server.js

pause

