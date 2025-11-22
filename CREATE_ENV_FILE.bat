@echo off
cls
echo ========================================
echo   Create .env File for Backend
echo ========================================
echo.
echo Creating .env file in backend folder...
echo.

cd backend

(
echo # Supabase Configuration
echo SUPABASE_URL=https://dxzkxvczjdviuvmgwsft.supabase.co
echo SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR4emt4dmN6amR2aXV2bWd3c2Z0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1OTYyMzYsImV4cCI6MjA3OTE3MjIzNn0.cXYHeOepjMX8coJWqTaiz5GlEgAGhm35VMwIqvQhTTw
echo.
echo # JWT Secret
echo JWT_SECRET=monitoring_maintenance_secret_key_2024
echo.
echo # Server Port
echo PORT=3000
) > .env

echo.
echo ========================================
echo   .env file created successfully!
echo ========================================
echo.
echo File location: backend\.env
echo.
echo Configuration:
echo   - Supabase URL: Connected
echo   - Supabase Key: Configured
echo   - Port: 3000
echo.
echo Press any key to start backend...
pause >nul

cls
echo ========================================
echo   Starting Backend Server
echo ========================================
echo.

node server.js

pause

