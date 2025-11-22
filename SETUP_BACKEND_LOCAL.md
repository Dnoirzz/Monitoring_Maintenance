# 🚀 Setup Backend Local untuk Development

Backend API local yang connect ke database Supabase online.

## ✅ Keuntungan Setup Ini

- ✅ Database online di Supabase (tidak perlu setup database local)
- ✅ Backend local untuk development (mudah debug & test)
- ✅ Fast development cycle (edit code → auto refresh)
- ✅ Easy deployment (tinggal deploy backend ke production)

## 📋 Prerequisites

1. **Node.js** (v16 atau lebih baru)
   - Download: https://nodejs.org/
   - Cek instalasi: `node --version`

2. **Database Supabase** sudah setup
   - Tabel `karyawan` ada
   - Tabel `aplikasi` ada
   - Tabel `karyawan_aplikasi` ada

## 🔧 Langkah Setup

### Step 1: Install Node.js

Jika belum install, download dan install Node.js dari https://nodejs.org/

### Step 2: Setup Backend

Semua file backend sudah dibuat di folder `backend/`:
- `server.js` - Main server
- `package.json` - Dependencies
- `.env` - Konfigurasi (Supabase URL & Key)
- `README.md` - Dokumentasi

### Step 3: Setup User di Database

Buka **Supabase Dashboard** → **SQL Editor** dan jalankan query berikut:

```sql
-- 1. Pastikan tabel aplikasi ada entry MT
INSERT INTO public.aplikasi (nama_aplikasi, kode_aplikasi, deskripsi)
VALUES ('Maintenance System', 'MT', 'Sistem Monitoring Maintenance Mesin')
ON CONFLICT (kode_aplikasi) DO NOTHING;

-- 2. Insert test user
-- Password akan di-hash saat pertama kali login atau generate dulu
INSERT INTO public.karyawan (email, password_hash, full_name, is_active)
VALUES (
  'teknisi@test.com',
  -- Hash ini untuk password 'test123'
  -- Generate hash baru dengan: node backend/generate-password.js test123
  '$2b$10$YourHashHere',
  'Teknisi Test',
  true
);
```

**Atau** gunakan script generator:

```bash
cd backend
npm install
node generate-password.js test123
```

Copy hash yang dihasilkan dan gunakan di SQL INSERT.

### Step 4: Jalankan Backend

#### Cara 1: Pakai file .bat (MUDAH!)

Double-click file **`start-backend.bat`** di root folder project.

Backend akan otomatis:
1. Install dependencies (jika belum)
2. Start server di `http://localhost:3000`

#### Cara 2: Manual

```bash
# Masuk ke folder backend
cd backend

# Install dependencies (hanya sekali)
npm install

# Jalankan server
npm start
```

### Step 5: Test Backend

Buka browser dan akses:
```
http://localhost:3000/api/health
```

Harusnya muncul:
```json
{
  "status": "OK",
  "message": "Backend API is running",
  "timestamp": "..."
}
```

### Step 6: Test Login

Test dengan Postman atau curl:

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"teknisi@test.com\",\"password\":\"test123\"}"
```

Harusnya return:
```json
{
  "user": {
    "id": "uuid...",
    "email": "teknisi@test.com",
    "full_name": "Teknisi Test"
  },
  "token": "JWT_TOKEN...",
  "available_apps": [
    {
      "kode_aplikasi": "MT",
      "role": "Teknisi"
    }
  ]
}
```

### Step 7: Test dari Flutter App

1. Pastikan backend running (`start-backend.bat`)
2. Pastikan `api_config.dart` sudah diupdate:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:3000'; // Android Emulator
   ```
3. Run Flutter app
4. Login dengan:
   - Email: `teknisi@test.com`
   - Password: `test123`

## 🔄 Workflow Development

1. **Start Backend**: Double-click `start-backend.bat`
2. **Edit Code**: Edit file di `backend/server.js`
3. **Restart**: Press Ctrl+C di terminal, lalu run lagi
4. **Test**: Test dengan Postman atau Flutter app

Atau pakai nodemon untuk auto-restart:
```bash
cd backend
npm run dev
```

## 📱 Konfigurasi Platform

### Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

### iOS Simulator / Web / Desktop
```dart
static const String baseUrl = 'http://localhost:3000';
```

### Real Device (di network yang sama)
```dart
static const String baseUrl = 'http://192.168.x.x:3000'; // IP komputer Anda
```

Cek IP komputer:
- Windows: `ipconfig` (cari IPv4)
- Mac/Linux: `ifconfig` (cari inet)

## 📝 Create User Baru

### Cara 1: Menggunakan SQL + Generate Hash

```bash
# 1. Generate password hash
cd backend
node generate-password.js password_anda

# 2. Copy hash yang dihasilkan

# 3. Insert ke database via Supabase SQL Editor
INSERT INTO public.karyawan (email, password_hash, full_name, is_active)
VALUES ('email@example.com', 'HASH_DARI_STEP_1', 'Nama User', true);

# 4. Beri akses MT
INSERT INTO public.karyawan_aplikasi (karyawan_id, aplikasi_id, role)
SELECT 
  k.id,
  a.id,
  'Teknisi'
FROM 
  public.karyawan k,
  public.aplikasi a
WHERE 
  k.email = 'email@example.com'
  AND a.kode_aplikasi = 'MT';
```

### Cara 2: Langsung di Supabase Dashboard

Gunakan script di file `backend/SETUP_USER.sql`

## 🐛 Troubleshooting

### Backend tidak bisa start

**Error: "Node.js is not installed"**
- Install Node.js dari https://nodejs.org/

**Error: "Cannot find module..."**
```bash
cd backend
npm install
```

**Error: "Port 3000 already in use"**
- Stop aplikasi lain yang pakai port 3000
- Atau edit `backend/.env`: `PORT=3001`

### Login gagal dari Flutter

**Error: "Tidak ada koneksi internet"**
- Pastikan backend running
- Cek URL di `api_config.dart`:
  - Android: `http://10.0.2.2:3000`
  - iOS/Web: `http://localhost:3000`

**Error: "Email atau password salah"**
- Cek di console backend untuk detail error
- Pastikan user ada di database
- Pastikan password hash benar

### Password hash tidak match

Regenerate password hash:
```bash
cd backend
node generate-password.js password_baru
```

Update di database:
```sql
UPDATE public.karyawan 
SET password_hash = 'NEW_HASH_HERE'
WHERE email = 'email@example.com';
```

## 🚀 Deploy ke Production

Nanti saat mau production:

1. Deploy backend ke hosting (Vercel, Railway, Heroku, dll)
2. Update `api_config.dart`:
   ```dart
   static const String baseUrl = 'https://api-production.com';
   ```
3. Done!

## 📞 Support

Jika ada masalah, cek:
1. Console backend (terminal tempat backend running)
2. Log di Supabase Dashboard → Logs
3. DevTools di Flutter (F12 untuk web)

---

**Happy Coding! 🎉**

