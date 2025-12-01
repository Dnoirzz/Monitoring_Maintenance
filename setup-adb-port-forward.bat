@echo off
cls
echo ========================================
echo   Setup ADB Port Forwarding
echo ========================================
echo.
echo Forwarding port 3000 dari HP ke komputer...
echo.

adb reverse tcp:3000 tcp:3000

if errorlevel 1 (
    echo.
    echo ========================================
    echo   ERROR: ADB tidak ditemukan!
    echo ========================================
    echo.
    echo Pastikan:
    echo 1. Android Studio sudah terinstall, ATAU
    echo 2. Android SDK Platform Tools sudah terinstall
    echo.
    echo Download Platform Tools:
    echo https://developer.android.com/studio/releases/platform-tools
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Port Forwarding Berhasil!
echo ========================================
echo.
echo Status port forwarding:
adb reverse --list
echo.
echo ========================================
echo   Catatan:
echo ========================================
echo - Port forwarding akan aktif selama:
echo   * HP terhubung via USB
echo   * ADB daemon running
echo.
echo - Jika HP di-reconnect, jalankan script ini lagi
echo.
echo - Pastikan useAdbPortForwarding = true
echo   di packages/shared/lib/config/api_config.dart
echo.
echo ========================================
echo.
pause

