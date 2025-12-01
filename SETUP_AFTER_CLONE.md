# 🚀 Panduan Setup Setelah Clone Repository

Panduan lengkap langkah-langkah yang harus dilakukan setelah melakukan clone repository **Monitoring Maintenance**.

---

## 📋 Checklist Setup

- [ ] **1. Install Flutter Dependencies** (Shared Package & Apps)
- [ ] **2. Setup Backend Environment File** (Opsional - untuk development)
- [ ] **3. Verifikasi Konfigurasi Supabase**
- [ ] **4. Setup Database Schema** (Jika belum ada)
- [ ] **5. Buat User Admin** (Untuk login)
- [ ] **6. Jalankan Aplikasi**

---

## 🛠️ Langkah 1: Install Flutter Dependencies

Karena ini adalah **monorepo** dengan struktur packages dan apps, Anda perlu install dependencies untuk masing-masing bagian.

### 1.1 Install Dependencies untuk Shared Package

```powershell
cd packages/shared
flutter pub get
cd ../..
```

### 1.2 Install Dependencies untuk Admin Web App

```powershell
cd apps/admin_web
flutter pub get
cd ../..
```

### 1.3 Install Dependencies untuk Karyawan Mobile App

```powershell
cd apps/karyawan_mobile
flutter pub get
cd ../..
```

### 1.4 Install Dependencies untuk Root Project (Jika ada)

```powershell
# Kembali ke root folder
flutter pub get
```

**✅ Tips:** Anda bisa menjalankan semua perintah di atas sekaligus:

```powershell
# Dari root folder
cd packages/shared && flutter pub get && cd ../..
cd apps/admin_web && flutter pub get && cd ../..
cd apps/karyawan_mobile && flutter pub get && cd ../..
```

---

## 🔧 Langkah 2: Setup Backend Environment File (Opsional)

**Catatan:** Langkah ini hanya diperlukan jika Anda ingin menjalankan backend secara lokal untuk development.

### 2.1 Cara Otomatis (Mudah!)

Double-click file **`CREATE_ENV_FILE.bat`** di root folder project.

File ini akan otomatis membuat file `.env` di folder `backend/` dengan konfigurasi yang sudah diisi.

### 2.2 Cara Manual

1. Buka folder `backend/`
2. Copy file `ENV_TEMPLATE.txt` dan rename menjadi `.env`
3. Atau buat file baru bernama `.env` dengan isi:

```env
# Supabase Configuration
SUPABASE_URL=https://dxzkxvczjdviuvmgwsft.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR4emt4dmN6amR2aXV2bWd3c2Z0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1OTYyMzYsImV4cCI6MjA3OTE3MjIzNn0.cXYHeOepjMX8coJWqTaiz5GlEgAGhm35VMwIqvQhTTw

# JWT Secret
JWT_SECRET=monitoring_maintenance_secret_key_2024

# Server Port
PORT=3000
```

### 2.3 Install Backend Dependencies (Jika perlu)

Jika Anda ingin menjalankan backend lokal:

```powershell
cd backend
npm install
cd ..
```

**✅ Tips:** Backend sudah bisa dijalankan dengan double-click file `start-backend.bat` (akan auto install jika belum).

---

## 🔐 Langkah 3: Verifikasi Konfigurasi Supabase

### 3.1 Cek File Konfigurasi Supabase

Buka file: `packages/shared/lib/config/supabase_config.dart`

Pastikan sudah terisi dengan credentials Supabase:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://dxzkxvczjdviuvmgwsft.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
}
```

**⚠️ PENTING:** Jika file ini masih berisi placeholder (`YOUR_ANON_KEY_HERE`), Anda perlu:

1. Login ke [Supabase Dashboard](https://app.supabase.com)
2. Pilih project: `dxzkxvczjdviuvmgwsft`
3. Klik **Project Settings** (icon gear) → **API**
4. Copy **anon public** key
5. Paste ke `supabaseAnonKey` di file config

**Catatan:** Berdasarkan file yang ada, key sudah terisi, jadi biasanya sudah OK! ✅

### 3.2 Verifikasi Koneksi Supabase

Setelah aplikasi dijalankan, cek console untuk memastikan tidak ada error koneksi.

---

## 🗄️ Langkah 4: Setup Database Schema (Jika Belum Ada)

### 4.1 Cek Apakah Tabel Sudah Ada

Buka **Supabase Dashboard** → **Table Editor** dan pastikan tabel-tabel berikut sudah ada:

- ✅ `assets` - Data master asset/mesin
- ✅ `bg_mesin` - Bagian dari mesin/asset
- ✅ `komponen_assets` - Komponen detail dari bagian mesin
- ✅ `karyawan` - Data karyawan
- ✅ `aplikasi` - Data aplikasi
- ✅ `karyawan_aplikasi` - Relasi karyawan dengan aplikasi
- ✅ `mt_schedule` - Jadwal maintenance
- ✅ `mt_template` - Template maintenance
- ✅ `cek_sheet_schedule` - Jadwal check sheet
- ✅ `cek_sheet_template` - Template check sheet

### 4.2 Jika Tabel Belum Ada

Jalankan file SQL schema yang ada di root project:

1. Buka **Supabase Dashboard** → **SQL Editor**
2. Buka file `database_schema.sql` di root project
3. Copy-paste dan jalankan semua query di SQL Editor

**Catatan:** Biasanya database schema sudah dibuat, jadi langkah ini opsional.

---

## 👤 Langkah 5: Buat User Admin untuk Login

Anda perlu membuat user admin di Supabase Authentication untuk bisa login ke aplikasi.

### 5.1 Cara 1: Melalui Supabase Dashboard (Paling Mudah!)

1. **Login ke Supabase Dashboard**
   - Buka [https://app.supabase.com](https://app.supabase.com)
   - Pilih project: `dxzkxvczjdviuvmgwsft`

2. **Buka Authentication**
   - Klik **Authentication** di sidebar kiri
   - Klik **Users**

3. **Tambah User Baru**
   - Klik tombol **"Add user"** → **"Create new user"**
   - Isi form:
     - **Email**: `admin@monitoring.com` (atau email lain)
     - **Password**: `admin123` (minimal 6 karakter)
     - **Auto Confirm User**: ✅ **CENTANG** (agar langsung bisa login tanpa verifikasi email)
   - Klik **"Create user"**

4. **User Siap Digunakan!**
   - Email: `admin@monitoring.com`
   - Password: `admin123`

### 5.2 Cara 2: Menggunakan SQL (Advanced)

Buka **Supabase Dashboard** → **SQL Editor** dan jalankan query dari file `SETUP_USER.sql` atau `UPDATE_PASSWORD_ADMIN.sql`.

**Catatan:** Cara 1 lebih mudah dan aman untuk pemula!

---

## 🚀 Langkah 6: Jalankan Aplikasi

### 6.1 Jalankan Admin Web App

```powershell
cd apps/admin_web
flutter run -d chrome
```

Atau untuk web browser lainnya:

```powershell
flutter run -d edge    # Microsoft Edge
flutter run -d firefox # Firefox
```

### 6.2 Jalankan Karyawan Mobile App

Untuk Android:

```powershell
cd apps/karyawan_mobile
flutter run -d android
```

Untuk iOS (hanya Mac):

```powershell
flutter run -d ios
```

### 6.3 Test Login

1. Buka aplikasi yang sudah dijalankan
2. Login dengan credentials admin yang sudah dibuat:
   - **Email**: `admin@monitoring.com`
   - **Password**: `admin123`
3. Jika berhasil, Anda akan diarahkan ke Dashboard Admin

---

## 🔄 Langkah Opsional: Jalankan Backend Local

Jika Anda ingin development dengan backend lokal:

### 6.1 Start Backend Server

Double-click file **`start-backend.bat`** di root folder.

Backend akan running di `http://localhost:3000`

### 6.2 Test Backend

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

**Catatan:** Jika menggunakan backend lokal, pastikan `api_config.dart` sudah dikonfigurasi dengan benar untuk localhost.

---

## ✅ Checklist Final

Setelah semua langkah di atas selesai, pastikan:

- [ ] ✅ Semua dependencies sudah terinstall (shared, admin_web, karyawan_mobile)
- [ ] ✅ Konfigurasi Supabase sudah benar
- [ ] ✅ Database schema sudah ada (atau sudah dibuat)
- [ ] ✅ User admin sudah dibuat di Supabase Authentication
- [ ] ✅ Aplikasi bisa dijalankan tanpa error
- [ ] ✅ Login berhasil dengan credentials admin
- [ ] ✅ (Opsional) Backend lokal running jika diperlukan

---

## 🐛 Troubleshooting

### Error: "Supabase client not initialized"

**Solusi:**
- Pastikan `supabaseAnonKey` sudah diisi di `packages/shared/lib/config/supabase_config.dart`
- Pastikan `SupabaseService.initialize()` dipanggil di `main.dart` sebelum `runApp()`

### Error: "Failed to create asset" atau "Connection error"

**Solusi:**
- Cek koneksi internet
- Verifikasi `supabaseAnonKey` sudah benar
- Cek Supabase Dashboard → **Table Editor** apakah tabel sudah ada
- Cek Supabase Dashboard → **Logs** untuk melihat detail error

### Error: "Email atau password salah" saat login

**Solusi:**
- Pastikan user sudah dibuat di Supabase Authentication
- Pastikan "Auto Confirm User" sudah dicentang saat membuat user
- Cek email dan password sudah benar
- Lihat dokumentasi lengkap di `LOGIN_SETUP.md`

### Error: "Flutter pub get" gagal

**Solusi:**
- Pastikan Flutter sudah terinstall: `flutter --version`
- Pastikan Anda menjalankan dari folder yang benar
- Cek koneksi internet
- Hapus folder `pubspec.lock` dan coba lagi:
  ```powershell
  flutter clean
  flutter pub get
  ```

### Backend tidak bisa start

**Solusi:**
- Pastikan Node.js sudah terinstall: `node --version`
- Install dependencies: `cd backend && npm install`
- Cek file `.env` sudah ada di folder `backend/`
- Cek port 3000 tidak digunakan aplikasi lain

---

## 📚 Dokumentasi Tambahan

Untuk informasi lebih detail, lihat dokumentasi berikut:

- **`MONOREPO_GUIDE.md`** - Panduan struktur monorepo
- **`QUICK_START_ADMIN.md`** - Quick start untuk fitur admin
- **`SUPABASE_SETUP.md`** - Setup Supabase lengkap
- **`LOGIN_SETUP.md`** - Setup login & autentikasi
- **`SETUP_BACKEND_LOCAL.md`** - Setup backend lokal untuk development
- **`BACKEND_API_INFO.md`** - Informasi backend API

---

## 🎉 Selesai!

Setelah semua langkah di atas selesai, Anda sudah siap untuk development!

**Happy Coding! 🚀**

---

## 📞 Butuh Bantuan?

Jika masih ada masalah:

1. Cek dokumentasi di folder root project
2. Cek Supabase Dashboard → Logs
3. Cek console browser/terminal untuk error message
4. Lihat file troubleshooting di dokumentasi masing-masing fitur


