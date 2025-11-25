@echo off
cls
echo ========================================
echo   TEST LOGIN - Admin MT KGB
echo ========================================
echo.
echo User Info:
echo   Email    : admin.mt@kgb.local
echo   Password : 123456
echo   Role     : Admin
echo   App      : MT
echo.
echo ========================================
echo   Step 1: Generate Password Hash
echo ========================================
echo.

cd backend

echo Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js not installed!
    pause
    exit /b 1
)

echo.
echo Installing dependencies if needed...
if not exist "node_modules\" (
    call npm install
)

echo.
echo Generating password hash for: 123456
echo.
node generate-password.js 123456

echo.
echo ========================================
echo   INSTRUKSI:
echo ========================================
echo 1. Copy hash yang muncul di atas
echo 2. Buka Supabase SQL Editor
echo 3. Jalankan query:
echo.
echo    UPDATE public.karyawan 
echo    SET password_hash = 'PASTE_HASH_HERE'
echo    WHERE email = 'admin.mt@kgb.local';
echo.
echo 4. Setelah update, tekan tombol apapun
echo    untuk start backend dan test login
echo.
pause

cls
echo ========================================
echo   Step 2: Starting Backend Server
echo ========================================
echo.
echo Backend will start on http://localhost:3000
echo.
echo Test login dengan:
echo   Email    : admin.mt@kgb.local
echo   Password : 123456
echo.
echo Press Ctrl+C to stop
echo.

node server.js

pause

