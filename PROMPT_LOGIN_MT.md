# Prompt untuk Implementasi Login Aplikasi MT

Tolong buatkan sistem login untuk aplikasi Flutter "Maintenance Tracking (MT)" dengan spesifikasi berikut:

---

## Arsitektur Login: 2-Step Authentication

### Flow:
1. **Step 1 - Login**: User input email + password → Backend validasi → Return list aplikasi yang bisa diakses user
2. **Step 2 - Select App**: User pilih aplikasi "MT" → Backend generate JWT token → User masuk ke app

### Kenapa 2-Step?
- Satu karyawan bisa punya akses ke banyak aplikasi (KGB, MT, dll)
- Setiap aplikasi bisa punya role berbeda (Admin di KGB, Operator di MT)
- JWT token berisi info spesifik per aplikasi

---

## Database Schema (MySQL)

```sql
-- 1. Tabel Karyawan (User Master)
CREATE TABLE karyawan (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  jabatan VARCHAR(100),
  department VARCHAR(100),
  profile_picture VARCHAR(500),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Tabel Aplikasi (App Master)
CREATE TABLE aplikasi (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  nama_aplikasi VARCHAR(100) NOT NULL,
  kode_aplikasi VARCHAR(20) UNIQUE NOT NULL,
  deskripsi TEXT,
  is_active BOOLEAN DEFAULT TRUE
);

-- 3. Tabel Karyawan-Aplikasi (User-App Access dengan Role)
CREATE TABLE karyawan_aplikasi (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  karyawan_id CHAR(36) NOT NULL,
  aplikasi_id CHAR(36) NOT NULL,
  role VARCHAR(50) NOT NULL,
  FOREIGN KEY (karyawan_id) REFERENCES karyawan(id),
  FOREIGN KEY (aplikasi_id) REFERENCES aplikasi(id),
  UNIQUE KEY unique_karyawan_app (karyawan_id, aplikasi_id)
);

-- Insert aplikasi MT
INSERT INTO aplikasi (nama_aplikasi, kode_aplikasi, deskripsi) 
VALUES ('Maintenance Tracking', 'MT', 'Aplikasi tracking maintenance mesin');
```

---

## Backend API (Node.js/Express)

### Endpoint yang dibutuhkan:

#### 1. POST /api/auth/login
**Request:**
```json
{
  "email": "user@nkp.com",
  "password": "password123"
}
```

**Response (Success):**
```json
{
  "success": true,
  "karyawan_id": "uuid-karyawan",
  "email": "user@nkp.com",
  "full_name": "John Doe",
  "available_apps": [
    {
      "karyawan_aplikasi_id": "uuid-1",
      "aplikasi_id": "uuid-app-mt",
      "nama_aplikasi": "Maintenance Tracking",
      "kode_aplikasi": "MT",
      "role": "Operator"
    }
  ]
}
```

**Logic:**
1. Cari karyawan by email
2. Cek is_active = true
3. Verify password dengan bcrypt.compare()
4. Query karyawan_aplikasi JOIN aplikasi untuk dapat list app yang bisa diakses
5. Return karyawan_id + available_apps

#### 2. POST /api/auth/select-app
**Request:**
```json
{
  "karyawan_id": "uuid-karyawan",
  "aplikasi_id": "uuid-app-mt"
}
```

**Response (Success):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "karyawan_id": "uuid-karyawan",
    "email": "user@nkp.com",
    "full_name": "John Doe",
    "role": "Operator",
    "aplikasi": {
      "nama": "Maintenance Tracking",
      "kode": "MT"
    }
  }
}
```

**Logic:**
1. Verify karyawan punya akses ke aplikasi tersebut (query karyawan_aplikasi)
2. Generate JWT token dengan payload: karyawan_id, email, role, aplikasi_kode
3. Return token + user info

#### 3. GET /api/auth/me (Protected)
**Header:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "user": {
    "karyawan_id": "uuid",
    "email": "user@nkp.com",
    "full_name": "John Doe",
    "role": "Operator",
    "profile_picture": "url-or-null",
    "aplikasi": {
      "nama": "Maintenance Tracking",
      "kode": "MT"
    }
  }
}
```

### JWT Token Payload:
```javascript
{
  karyawan_id: "uuid",
  karyawan_aplikasi_id: "uuid",
  email: "user@nkp.com",
  role: "Operator",
  aplikasi_kode: "MT"
}
```

### Dependencies Backend:
```json
{
  "bcrypt": "^5.1.0",
  "jsonwebtoken": "^9.0.0",
  "express-validator": "^7.0.0"
}
```

---

## Flutter Implementation

### 1. Model: AppUser
```dart
class AppUser {
  final String id;
  final String username; // email
  final String fullName;
  final String? profilePicture;
  final String role;
  final bool active;
  final DateTime createdAt;
}
```

### 2. Model: AvailableApp
```dart
class AvailableApp {
  final String karyawanAplikasiId;
  final String aplikasiId;
  final String namaAplikasi;
  final String kodeAplikasi;
  final String role;
}
```

### 3. ApiClient
- Method: get(), post(), put(), delete()
- Token management: saveToken(), clearToken(), init()
- Auto-attach header `Authorization: Bearer <token>`
- Handle 401 Unauthorized → clear token, redirect ke login

### 4. AuthService
```dart
class AuthService {
  // Step 1: Login → return list available apps
  Future<List<AvailableApp>> login(String email, String password);
  
  // Step 2: Select app → return user + save token
  Future<AppUser> selectApp(String aplikasiId);
  
  // Get profile from server
  Future<AppUser?> getProfile();
  
  // Logout → clear token + saved user
  Future<void> logout();
  
  // Init → load saved token & user from SharedPreferences
  Future<void> init();
}
```

### 5. AuthProvider (ChangeNotifier)
```dart
class AuthProvider with ChangeNotifier {
  AppUser? _currentUser;
  List<AvailableApp> _availableApps = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isAuthenticated => _currentUser != null;
  
  Future<void> login(String email, String password);
  Future<void> selectApp(String aplikasiId);
  Future<void> logout();
  Future<void> init();
}
```

### 6. Login Screen UI
- Form dengan email + password
- Setelah login sukses, jika hanya 1 app → auto select
- Jika banyak app → tampilkan dialog pilih aplikasi
- Filter hanya tampilkan app dengan kode "MT"

### Dependencies Flutter:
```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.0
  provider: ^6.0.0
```

---

## Login Flow Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Login Screen│────▶│ POST /login │────▶│ Available   │
│ (email+pass)│     │             │     │ Apps List   │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Home Screen │◀────│ JWT Token   │◀────│ Select App  │
│             │     │ Saved       │     │ (MT)        │
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## Catatan Penting

1. **Password Hashing**: Gunakan bcrypt dengan salt rounds 10
2. **JWT Secret**: Simpan di environment variable, jangan hardcode
3. **JWT Expiry**: Default 7 hari (`7d`)
4. **Token Storage**: SharedPreferences di Flutter
5. **Error Handling**: 
   - 401 = Email/password salah atau token expired
   - 403 = Akun tidak aktif atau tidak punya akses
   - 500 = Server error

6. **Untuk MT**: Filter `available_apps` hanya yang `kode_aplikasi == 'MT'`

---

## File yang Perlu Dibuat

**Backend:**
1. `src/routes/auth.js` - Auth routes

**Flutter:**
1. `lib/services/api_client.dart` - HTTP client
2. `lib/services/auth_service.dart` - Auth logic
3. `lib/services/auth_provider.dart` - State management
4. `lib/models/app_user.dart` - User model
5. `lib/models/available_app.dart` - App model
6. `lib/screens/auth/login_screen.dart` - Login UI

---

Tolong implementasikan semua file di atas dengan logic yang sudah dijelaskan. Pastikan error handling lengkap dan kode bersih.
