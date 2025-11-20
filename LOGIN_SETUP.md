# 🔐 Setup Login & Autentikasi

## ✅ Logika Login Sudah Diimplementasikan

File `lib/screen/login_page.dart` sekarang sudah memiliki:
- ✅ Integrasi dengan Supabase Auth
- ✅ Validasi form (email & password)
- ✅ Error handling dengan pesan yang jelas
- ✅ Loading indicator saat proses login
- ✅ Show/hide password
- ✅ Auto redirect ke Dashboard Admin setelah login berhasil

---

## 🎯 Cara Membuat User Admin di Supabase

### Opsi 1: Melalui Supabase Dashboard (Paling Mudah)

1. **Login ke Supabase Dashboard**
   - Buka [https://app.supabase.com](https://app.supabase.com)
   - Pilih project `dxzkxvczjdviuvmgwsft`

2. **Buka Authentication**
   - Klik **Authentication** di sidebar kiri
   - Klik **Users**

3. **Tambah User Baru**
   - Klik tombol **"Add user"** → **"Create new user"**
   - Isi form:
     - **Email**: `admin@monitoring.com` (atau email lain)
     - **Password**: `admin123` (minimal 6 karakter)
     - **Auto Confirm User**: ✅ CENTANG (agar langsung bisa login tanpa verifikasi email)
   - Klik **"Create user"**

4. **User Siap Digunakan!**
   - Email: `admin@monitoring.com`
   - Password: `admin123`

### Opsi 2: Melalui SQL Editor

```sql
-- Insert user langsung ke auth.users
-- NOTE: Password akan di-hash otomatis oleh Supabase
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'admin@monitoring.com',
  crypt('admin123', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"role":"admin"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
);
```

**⚠️ Catatan:** Opsi 1 lebih mudah dan aman!

---

## 🧪 Cara Test Login

### 1. Jalankan Aplikasi

```powershell
cd Monitoring_Maintenance
flutter run -d chrome
```

### 2. Test Login dengan Berbagai Skenario

#### ✅ Login Berhasil
- **Email**: `admin@monitoring.com`
- **Password**: `admin123`
- **Hasil**: Redirect ke Dashboard Admin

#### ❌ Email Salah
- **Email**: `wrong@email.com`
- **Password**: `admin123`
- **Pesan Error**: "Email atau password salah. Silakan periksa kembali."

#### ❌ Password Salah
- **Email**: `admin@monitoring.com`
- **Password**: `wrongpassword`
- **Pesan Error**: "Email atau password salah. Silakan periksa kembali."

#### ❌ Email Kosong
- **Email**: (kosong)
- **Password**: `admin123`
- **Pesan Error**: "Email harus diisi"

#### ❌ Password Kosong
- **Email**: `admin@monitoring.com`
- **Password**: (kosong)
- **Pesan Error**: "Password harus diisi"

#### ❌ Email Format Salah
- **Email**: `adminemail` (tanpa @)
- **Password**: `admin123`
- **Pesan Error**: "Format email tidak valid"

#### ❌ Password Kurang dari 6 Karakter
- **Email**: `admin@monitoring.com`
- **Password**: `123`
- **Pesan Error**: "Password minimal 6 karakter"

---

## 📋 Pesan Error yang Ditampilkan

| Kondisi | Pesan Error |
|---------|-------------|
| Email/Password salah | "Email atau password salah. Silakan periksa kembali." |
| Email belum verified | "Email belum diverifikasi. Silakan cek inbox Anda." |
| User tidak ditemukan | "Akun tidak ditemukan. Silakan daftar terlebih dahulu." |
| Tidak ada internet | "Tidak ada koneksi internet. Silakan cek koneksi Anda." |
| Email kosong | "Email harus diisi" |
| Email format salah | "Format email tidak valid" |
| Password kosong | "Password harus diisi" |
| Password < 6 karakter | "Password minimal 6 karakter" |

---

## 🔒 Fitur Login yang Sudah Ada

- ✅ **Validasi Form** - Email & password divalidasi sebelum submit
- ✅ **Show/Hide Password** - Icon mata untuk toggle visibility password
- ✅ **Loading State** - Button disabled & spinner saat proses login
- ✅ **Error Handling** - Pesan error spesifik sesuai kondisi
- ✅ **Supabase Auth** - Integrasi dengan Supabase Authentication
- ✅ **Auto Redirect** - Otomatis ke Dashboard Admin jika berhasil
- ✅ **SnackBar Notifikasi** - Error ditampilkan dengan snackbar merah

---

## 🚀 Next Steps (Opsional)

### 1. Role-Based Access Control
Tambahkan role di user metadata untuk membedakan Admin, Teknisi, Kepala Teknisi:

```sql
-- Update user metadata untuk role
UPDATE auth.users
SET raw_user_meta_data = '{"role": "admin", "name": "Admin User"}'
WHERE email = 'admin@monitoring.com';
```

### 2. Persistent Login (Remember Me)
Supabase sudah otomatis handle session persistence dengan localStorage.

### 3. Logout
Tambahkan tombol logout di Dashboard:

```dart
await SupabaseService.instance.signOut();
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (_) => const LoginPage()),
);
```

### 4. Forgot Password
Implementasi reset password dengan Supabase:

```dart
await supabase.auth.resetPasswordForEmail(email);
```

---

## 🐛 Troubleshooting

### Error: "Invalid login credentials"
**Penyebab**: Email atau password salah  
**Solusi**: Cek di Supabase Dashboard → Authentication → Users apakah user sudah dibuat

### Error: "Email not confirmed"
**Penyebab**: User belum verify email  
**Solusi**: Di Supabase Dashboard, klik user → **Confirm Email**

### Error: Network Error
**Penyebab**: Tidak ada koneksi internet atau Supabase down  
**Solusi**: Cek koneksi internet, cek status Supabase

### Login Berhasil Tapi Tidak Redirect
**Penyebab**: Route atau navigation error  
**Solusi**: Cek console browser (F12) untuk error

---

## 📊 Alur Login

```
User Input Email & Password
         ↓
Validasi Form (Client-side)
         ↓
Submit ke Supabase Auth
         ↓
    ┌─────────────┐
    │ Berhasil?   │
    └─────────────┘
      ↙         ↘
    Yes         No
     ↓           ↓
Redirect ke   Show Error
 Dashboard    Message
```

---

**Status**: ✅ **Login Logic Implemented & Ready for Testing**
