# 🔧 Fix: Error "Tidak ada koneksi internet" saat Login

## 🐛 Masalah

Saat login, muncul error: **"Tidak ada koneksi internet"**

**Penyebab**: URL backend API belum dikonfigurasi dengan benar.

## ✅ Solusi

### Step 1: Update Base URL Backend

Buka file: `lib/config/api_config.dart`

**Ganti baris 6** dengan URL backend Anda yang sebenarnya:

```dart
class ApiConfig {
  // Ganti URL ini dengan URL backend Anda
  static const String baseUrl = 'https://your-actual-backend-url.com';
  // atau
  // static const String baseUrl = 'http://localhost:3000'; // untuk development
  // atau
  // static const String baseUrl = 'https://api.production.com';
  
  static String get loginEndpoint => '$baseUrl/api/auth/login';
}
```

### Step 2: Pastikan Format URL Benar

URL harus:
- ✅ Dimulai dengan `http://` atau `https://`
- ✅ Tidak ada trailing slash di akhir
- ✅ Bisa diakses dari device/emulator Anda

**Contoh URL yang benar:**
```dart
// Production
static const String baseUrl = 'https://api.yourcompany.com';

// Development (jika backend di localhost)
// Untuk Android Emulator: gunakan 10.0.2.2
static const String baseUrl = 'http://10.0.2.2:3000';

// Untuk iOS Simulator: gunakan localhost
static const String baseUrl = 'http://localhost:3000';

// Untuk Web: bisa pakai localhost atau IP
static const String baseUrl = 'http://localhost:3000';
```

### Step 3: Test Koneksi

Setelah update URL, test lagi login. Error message sekarang akan lebih informatif jika masih ada masalah.

## 🔍 Cara Cek URL Backend yang Benar

### Jika Backend Menggunakan Supabase Functions:

```dart
// Jika backend adalah Supabase Edge Functions
static const String baseUrl = 'https://dxzkxvczjdviuvmgwsft.supabase.co/functions/v1';
// Endpoint akan menjadi: https://...supabase.co/functions/v1/api/auth/login
```

### Jika Backend Terpisah (Node.js, Express, dll):

1. Tanya tim backend tentang URL production/staging
2. Atau cek file `.env` atau dokumentasi backend
3. Atau test dengan Postman/curl untuk memastikan endpoint aktif

### Test Endpoint dengan Browser/Postman:

Buka browser dan test:
```
POST https://your-backend-url.com/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "test123"
}
```

Jika endpoint tidak bisa diakses, berarti:
- Backend belum running
- URL salah
- Ada firewall/network issue

## 📝 Contoh Konfigurasi

### Contoh 1: Backend di Production
```dart
class ApiConfig {
  static const String baseUrl = 'https://api.production.com';
  static String get loginEndpoint => '$baseUrl/api/auth/login';
}
```

### Contoh 2: Backend di Development (Local)
```dart
class ApiConfig {
  // Untuk Android Emulator
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  // Untuk iOS Simulator atau Web
  // static const String baseUrl = 'http://localhost:3000';
  
  static String get loginEndpoint => '$baseUrl/api/auth/login';
}
```

### Contoh 3: Backend di Supabase Functions
```dart
class ApiConfig {
  static const String baseUrl = 'https://dxzkxvczjdviuvmgwsft.supabase.co/functions/v1';
  static String get loginEndpoint => '$baseUrl/api/auth/login';
}
```

## ⚠️ Troubleshooting

### Masih Error Setelah Update URL?

1. **Cek apakah backend sedang running**
   ```bash
   # Test dengan curl
   curl -X POST https://your-backend-url.com/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"test","password":"test"}'
   ```

2. **Cek koneksi internet**
   - Pastikan device/emulator terhubung ke internet
   - Test buka website lain

3. **Cek CORS (untuk Web)**
   - Jika error di web browser, mungkin masalah CORS
   - Backend harus allow origin dari frontend

4. **Cek firewall/network**
   - Pastikan tidak ada firewall yang block request
   - Untuk localhost, pastikan port tidak di-block

5. **Cek log error di console**
   - Buka DevTools (F12) untuk web
   - Cek log di terminal untuk mobile

## 🎯 Quick Fix

Jika Anda tidak tahu URL backend, tanyakan ke:
- Tim backend developer
- Dokumentasi project
- File `.env` atau config file backend
- Atau cek di Supabase Dashboard → Functions (jika pakai Supabase)

Setelah mendapatkan URL yang benar, update di `lib/config/api_config.dart` dan test lagi!

