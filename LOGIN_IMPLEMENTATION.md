# 🔐 Implementasi Sistem Login - Maintenance App

## 📋 Overview

Sistem login ini mengkonsumsi API backend yang sudah ada dan menggunakan sistem tiket (pivot table) untuk authorization. User hanya bisa masuk ke aplikasi Maintenance jika memiliki tiket dengan `kode_aplikasi = 'MT'` di tabel `karyawan_aplikasi`.

## 🏗️ Arsitektur

### File yang Dibuat:

1. **`lib/model/auth_response_model.dart`**
   - Model untuk response API login
   - `AuthResponseModel`: Response utama
   - `UserModel`: Data user
   - `AppAccessModel`: Model tiket akses aplikasi

2. **`lib/config/api_config.dart`**
   - Konfigurasi base URL backend API
   - ⚠️ **PENTING**: Update `baseUrl` dengan URL backend yang sebenarnya

3. **`lib/services/auth_service.dart`**
   - Service untuk memanggil endpoint `POST /api/auth/login`
   - Handle error handling dan exception

4. **`lib/services/storage_service.dart`**
   - Service untuk menyimpan token dan data user ke local storage (SharedPreferences)
   - Menyimpan: token, userId, email, fullName, role

5. **`lib/providers/auth_provider.dart`**
   - Riverpod provider untuk state management
   - Logic utama:
     - ✅ Kirim request ke API login
     - ✅ Cek apakah ada tiket MT di `available_apps`
     - ✅ Validasi role (harus salah satu: Superadmin, Manajer, Admin, KASIE Teknisi, Teknisi)
     - ✅ Simpan token dan role jika valid
     - ❌ Tolak akses jika tidak ada tiket MT

## ⚙️ Setup

### 1. Install Dependencies

```bash
flutter pub get
```

Dependencies yang ditambahkan:
- `http: ^1.2.2` - Untuk HTTP requests
- `shared_preferences: ^2.3.2` - Untuk local storage

### 2. Konfigurasi API Base URL

**Edit file `lib/config/api_config.dart`:**

```dart
class ApiConfig {
  // Ganti dengan base URL backend API yang sebenarnya
  static const String baseUrl = 'https://api.yourdomain.com';
  // atau
  // static const String baseUrl = 'https://your-backend-url.com';
  
  static String get loginEndpoint => '$baseUrl/api/auth/login';
}
```

### 3. Pastikan Backend API Sesuai Spesifikasi

Backend harus menyediakan endpoint:
- **URL**: `POST /api/auth/login`
- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- **Response (200 OK)**:
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
      },
      {
        "kode_aplikasi": "KGB",
        "role": "Admin"
      }
    ]
  }
  ```

## 🔑 Logic Authorization

### Flow Login:

1. User input email & password → Submit
2. Frontend kirim request ke `POST /api/auth/login`
3. Backend validasi credentials dan return response dengan `available_apps`
4. **Frontend cek tiket MT:**
   - Filter `available_apps` untuk mencari `kode_aplikasi === 'MT'`
   - Jika **TIDAK ADA** → Tolak dengan pesan: *"Anda tidak memiliki akses ke System Maintenance. Hubungi IT."*
   - Jika **ADA** → Lanjut ke step 5
5. **Validasi role:**
   - Role harus salah satu: `'Superadmin'`, `'Manajer'`, `'Admin'`, `'KASIE Teknisi'`, `'Teknisi'`
   - Jika role tidak valid → Tolak dengan pesan error
6. **Simpan data:**
   - Simpan `token` ke storage
   - Simpan `userId`, `email`, `fullName`, `role` ke storage
7. **Update state:**
   - Set `isAuthenticated = true`
   - Navigate ke Dashboard

### Role yang Valid:

- `'Superadmin'` - Akses penuh
- `'Manajer'` - Monitoring
- `'Admin'` - Admin Maintenance
- `'KASIE Teknisi'` - KASIE Teknisi
- `'Teknisi'` - Teknisi

**Note**: Role validation adalah **case-sensitive**.

## 📱 Penggunaan di UI

### Login Page

Login page sudah diupdate untuk menggunakan `AuthProvider`:

```dart
// Di login_page.dart
final authState = ref.watch(authProvider);
final isLoading = authState.isLoading;

// Handle login
await ref.read(authProvider.notifier).login(
  email: email,
  password: password,
);
```

### Main App

`main.dart` sudah diupdate untuk routing otomatis:

```dart
// Otomatis redirect berdasarkan auth state
home: authState.isAuthenticated
    ? const AdminTemplate()
    : const LoginPage(),
```

### Logout

Untuk logout, panggil:

```dart
await ref.read(authProvider.notifier).logout();
```

### Get Current User Data

```dart
final authState = ref.watch(authProvider);
final userId = authState.userId;
final userEmail = authState.userEmail;
final userFullName = authState.userFullName;
final userRole = authState.userRole;
```

### Get Token (untuk API calls)

```dart
final token = await ref.read(authProvider.notifier).getToken();
```

## 🧪 Testing

### Test Case 1: Login dengan tiket MT
- **Input**: Email & password user yang punya tiket MT
- **Expected**: Login berhasil, redirect ke dashboard

### Test Case 2: Login tanpa tiket MT
- **Input**: Email & password user yang TIDAK punya tiket MT (tapi punya tiket KGB)
- **Expected**: Error message: *"Anda tidak memiliki akses ke System Maintenance. Hubungi IT."*

### Test Case 3: Login dengan role tidak valid
- **Input**: User dengan tiket MT tapi role tidak ada di daftar valid
- **Expected**: Error message tentang role tidak valid

### Test Case 4: Login dengan credentials salah
- **Input**: Email atau password salah
- **Expected**: Error message dari backend (401)

## 🔍 Troubleshooting

### Error: "Tidak ada koneksi internet"
- Cek koneksi internet
- Cek apakah base URL di `api_config.dart` benar

### Error: "Format response tidak valid dari server"
- Pastikan response dari backend sesuai format yang diharapkan
- Cek struktur JSON response

### Error: "Anda tidak memiliki akses ke System Maintenance"
- User tidak punya tiket MT di database
- Hubungi IT untuk menambahkan tiket di tabel `karyawan_aplikasi`

### Token tidak tersimpan
- Pastikan `shared_preferences` sudah terinstall
- Cek permission storage di Android/iOS

## 📝 Catatan Penting

1. **Database tidak diubah** - Sistem ini hanya mengkonsumsi API yang sudah ada
2. **Tiket System** - Authorization berdasarkan pivot table `karyawan_aplikasi`, bukan kolom role di user
3. **Case Sensitive** - Role validation case-sensitive
4. **Token Storage** - Token disimpan di SharedPreferences untuk persistensi
5. **Auto Login** - App akan auto-check token saat pertama kali dibuka

## 🚀 Next Steps

1. Update `baseUrl` di `lib/config/api_config.dart` dengan URL backend yang sebenarnya
2. Test dengan user yang punya tiket MT
3. Integrate token ke API calls lainnya (jika diperlukan)
4. Implement logout functionality di dashboard (jika belum ada)

