# ✅ READY TO TEST!

Berdasarkan database check, user sudah ada dengan info:

## 📊 User Info (dari Database)
- **Email**: `admin.mt@kgb.local`
- **Full Name**: `Supiardi`
- **Status**: `Active` ✅
- **Role**: `Admin` ✅
- **Aplikasi**: `MT` ✅

**Semua requirement SUDAH TERPENUHI!** 🎉

## 🔐 Update Password Hash

Karena password-nya "123456", kita perlu pastikan hash-nya benar.

### Langkah Cepat:

1. **Generate Hash yang Benar**
   
   Double-click file: **`START_TEST.bat`**
   
   Script akan:
   - Generate password hash untuk "123456"
   - Tampilkan hash yang harus di-copy
   - Tunggu Anda update database
   - Start backend server untuk test

2. **Copy Hash & Update Database**
   
   Setelah hash muncul di console, copy hash-nya, lalu:
   
   Buka **Supabase SQL Editor** dan jalankan:
   ```sql
   UPDATE public.karyawan 
   SET password_hash = 'PASTE_HASH_YANG_DICOPY'
   WHERE email = 'admin.mt@kgb.local';
   ```

3. **Test Login**
   
   Setelah update, backend akan auto-start.
   
   Test dengan Flutter app:
   - Email: `admin.mt@kgb.local`
   - Password: `123456`
   
   **Harusnya login berhasil!** ✅

## 🎯 Atau Manual (Jika Prefer)

### Manual Step 1: Generate Hash
```bash
cd backend
npm install
node generate-password.js 123456
```

### Manual Step 2: Update Database
Copy hash dari output, lalu jalankan di Supabase:
```sql
UPDATE public.karyawan 
SET password_hash = 'HASH_DARI_STEP_1'
WHERE email = 'admin.mt@kgb.local';
```

### Manual Step 3: Start Backend
```
Double-click: start-backend.bat
```

### Manual Step 4: Test Login
Run Flutter app dan login.

---

## 🚀 Quick Start

**Paling mudah:** Double-click **`START_TEST.bat`** dan ikuti instruksi!

Backend sudah 100% siap, tinggal:
1. Update password hash
2. Test login

**LET'S GO!** 🎉

