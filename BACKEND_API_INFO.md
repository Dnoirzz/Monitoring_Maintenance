# 🔍 Informasi Backend API

## ✅ Status Backend API

Berdasarkan informasi awal, **Backend API sudah ada dan berjalan di Production**.

Backend menyediakan endpoint:
- **Method**: `POST`
- **Path**: `/api/auth/login`
- **Request**: 
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- **Response**:
  ```json
  {
    "user": {
      "id": "uuid...",
      "email": "user@example.com",
      "full_name": "Nama User"
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

## 🔧 Konfigurasi URL Backend

File konfigurasi: `lib/config/api_config.dart`

### Skenario 1: Backend Menggunakan Supabase Edge Functions

Jika backend login Anda adalah Supabase Edge Function, gunakan:

```dart
static const String baseUrl = 'https://dxzkxvczjdviuvmgwsft.supabase.co/functions/v1';
```

**Endpoint lengkap**: `https://dxzkxvczjdviuvmgwsft.supabase.co/functions/v1/api/auth/login`

**Cara cek apakah menggunakan Supabase Functions:**
1. Buka Supabase Dashboard → Functions
2. Cek apakah ada function dengan nama `api` atau `auth` atau `login`
3. Jika ada, berarti menggunakan Supabase Functions

### Skenario 2: Backend Terpisah (Node.js, Express, Python, dll)

Jika backend adalah aplikasi terpisah, gunakan URL production/staging:

```dart
// Production
static const String baseUrl = 'https://api.yourcompany.com';

// Staging
// static const String baseUrl = 'https://staging-api.yourcompany.com';
```

**Cara mendapatkan URL:**
1. Tanya tim backend developer
2. Cek dokumentasi project
3. Cek file `.env` atau config backend
4. Cek deployment platform (Vercel, Railway, Heroku, dll)

### Skenario 3: Development Local

Untuk development, gunakan localhost:

```dart
// Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000';

// iOS Simulator atau Web
// static const String baseUrl = 'http://localhost:3000';
```

## 🧪 Cara Test Backend API

### Test dengan Browser/Postman:

```bash
POST https://your-backend-url.com/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "test123"
}
```

### Test dengan curl:

```bash
curl -X POST https://your-backend-url.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

### Test dengan Flutter (Debug):

Uncomment baris di `auth_service.dart` untuk melihat URL yang digunakan:

```dart
// Debug: Log URL yang digunakan
print('🔗 Login URL: $url');
```

## 📋 Checklist

- [ ] Tentukan jenis backend (Supabase Functions atau terpisah)
- [ ] Dapatkan URL backend yang benar
- [ ] Update `baseUrl` di `lib/config/api_config.dart`
- [ ] Test endpoint dengan Postman/curl
- [ ] Test login dari aplikasi Flutter
- [ ] Pastikan response sesuai format yang diharapkan

## ⚠️ Troubleshooting

### Error: "Endpoint tidak ditemukan (404)"

**Kemungkinan:**
1. URL backend salah
2. Path endpoint salah (bukan `/api/auth/login`)
3. Backend belum deployed/running

**Solusi:**
- Cek URL di `api_config.dart`
- Test endpoint dengan Postman
- Tanya tim backend tentang path yang benar

### Error: "Request timeout"

**Kemungkinan:**
1. Backend tidak running
2. Network issue
3. Backend terlalu lambat

**Solusi:**
- Cek apakah backend sedang running
- Test dengan Postman untuk memastikan endpoint aktif
- Cek network connection

### Error: "Format response tidak valid"

**Kemungkinan:**
1. Response format berbeda dari yang diharapkan
2. Response bukan JSON
3. Field name berbeda

**Solusi:**
- Cek response actual dengan Postman
- Bandingkan dengan format di `auth_response_model.dart`
- Update model jika format berbeda

## 📞 Kontak

Jika tidak yakin tentang URL backend, hubungi:
- Tim backend developer
- Project manager
- Atau cek dokumentasi project

