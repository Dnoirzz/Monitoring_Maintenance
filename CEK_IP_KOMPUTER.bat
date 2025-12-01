@echo off
cls
echo ========================================
echo   Cek IP Address Komputer
echo ========================================
echo.
echo Mencari IP address di network adapter...
echo.

ipconfig | findstr /C:"IPv4"

echo.
echo ========================================
echo   Cara Menggunakan:
echo ========================================
echo 1. Cari IP yang dimulai dengan 192.168.x.x
echo 2. Pastikan HP dan komputer di WiFi yang sama
echo 3. Update IP di packages/shared/lib/config/api_config.dart
echo 4. Set useAdbPortForwarding = false
echo.
echo ========================================
echo.
pause

