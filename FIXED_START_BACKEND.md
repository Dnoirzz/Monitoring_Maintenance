# 🔧 Fix: Backend Error - supabaseUrl is required

## Error yang Terjadi
```
Error: supabaseUrl is required.
```

## Penyebab
File `.env` belum ada di folder `backend/`

## ✅ Solusi (SUPER MUDAH!)

### Cara 1: Otomatis dengan .bat (RECOMMENDED)

**Double-click file: `CREATE_ENV_FILE.bat`**

Script akan:
1. ✅ Otomatis create file `.env`
2. ✅ Isi dengan konfigurasi Supabase
3. ✅ Auto start backend server

**Done!** Backend langsung jalan!

---

### Cara 2: Manual

1. **Buat file baru** di folder `backend/` dengan nama: `.env`
   
   (Perhatikan: nama file dimulai dengan titik: `.env`)

2. **Isi file `.env`** dengan:

```env
# Supabase Configuration
SUPABASE_URL=https://dxzkxvczjdviuvmgwsft.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR4emt4dmN6amR2aXV2bWd3c2Z0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1OTYyMzYsImV4cCI6MjA3OTE3MjIzNn0.cXYHeOepjMX8coJWqTaiz5GlEgAGhm35VMwIqvQhTTw

# JWT Secret
JWT_SECRET=monitoring_maintenance_secret_key_2024

# Server Port
PORT=3000
```

3. **Save** file `.env`

4. **Jalankan backend** lagi:
   ```
   Double-click: start-backend.bat
   ```

---

## 🎯 Quick Fix

**Paling mudah:** Double-click **`CREATE_ENV_FILE.bat`**

Backend akan otomatis jalan!

---

## ✅ Verify

Setelah backend jalan, harusnya muncul:

```
==================================================
🚀 Server running on http://localhost:3000
==================================================

📌 Endpoints:
   - GET  / 
   - GET  /api/health
   - POST /api/auth/login

📊 Database: Supabase Online
   URL: https://dxzkxvczjdviuvmgwsft.supabase.co

⌨️  Press Ctrl+C to stop
==================================================
```

Backend siap! 🎉

