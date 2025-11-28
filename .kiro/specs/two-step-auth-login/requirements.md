# Requirements Document

## Introduction

Sistem login 2-step authentication untuk aplikasi Maintenance Tracking (MT). Flow login terdiri dari dua tahap: pertama user login dengan email dan password untuk mendapatkan daftar aplikasi yang bisa diakses, kemudian user memilih aplikasi MT untuk mendapatkan JWT token dan masuk ke aplikasi.

## Glossary

- **Karyawan**: User/pengguna yang terdaftar dalam sistem
- **Aplikasi**: Sistem/aplikasi yang bisa diakses oleh karyawan (contoh: MT, KGB)
- **MT (Maintenance Tracking)**: Aplikasi tracking maintenance mesin
- **JWT Token**: JSON Web Token untuk autentikasi API
- **Available Apps**: Daftar aplikasi yang bisa diakses oleh karyawan berdasarkan karyawan_aplikasi
- **Role**: Peran karyawan dalam aplikasi tertentu (Superadmin, Manajer, Admin, KASIE Teknisi, Teknisi)
- **2-Step Authentication**: Proses login dua tahap (login → select app)

## Requirements

### Requirement 1

**User Story:** As a karyawan, I want to login with email and password, so that I can see which applications I have access to.

#### Acceptance Criteria

1. WHEN a karyawan submits email and password THEN the Backend SHALL validate credentials against karyawan table
2. WHEN credentials are valid and karyawan is_active is true THEN the Backend SHALL return karyawan_id, email, full_name, and available_apps list
3. WHEN email is not found in karyawan table THEN the Backend SHALL return 401 error with message "Email atau password salah"
4. WHEN password does not match password_hash THEN the Backend SHALL return 401 error with message "Email atau password salah"
5. WHEN karyawan is_active is false THEN the Backend SHALL return 403 error with message "Akun tidak aktif"
6. WHEN karyawan has no aplikasi access THEN the Backend SHALL return empty available_apps array

### Requirement 2

**User Story:** As a karyawan, I want to select an application after login, so that I can get a JWT token specific to that application.

#### Acceptance Criteria

1. WHEN a karyawan selects an aplikasi_id with valid karyawan_id THEN the Backend SHALL verify access in karyawan_aplikasi table
2. WHEN access is verified THEN the Backend SHALL generate JWT token containing karyawan_id, karyawan_aplikasi_id, email, role, and aplikasi_kode
3. WHEN access is verified THEN the Backend SHALL return token and user object with role and aplikasi info
4. WHEN karyawan does not have access to selected aplikasi THEN the Backend SHALL return 403 error
5. WHEN JWT token is generated THEN the Backend SHALL set expiry to 7 days

### Requirement 3

**User Story:** As a karyawan, I want to verify my session, so that I can access protected resources.

#### Acceptance Criteria

1. WHEN a request includes valid JWT token in Authorization header THEN the Backend SHALL decode and verify the token
2. WHEN token is valid THEN the Backend SHALL return user profile with karyawan_id, email, full_name, role, profile_picture, and aplikasi info
3. WHEN token is expired or invalid THEN the Backend SHALL return 401 error
4. WHEN Authorization header is missing THEN the Backend SHALL return 401 error

### Requirement 4

**User Story:** As a karyawan, I want the Flutter app to handle the 2-step login flow, so that I can seamlessly access the MT application.

#### Acceptance Criteria

1. WHEN login is successful THEN the Flutter App SHALL store karyawan_id temporarily for step 2
2. WHEN available_apps contains only one MT app THEN the Flutter App SHALL auto-select that app
3. WHEN available_apps contains multiple apps THEN the Flutter App SHALL display app selection dialog
4. WHEN app is selected THEN the Flutter App SHALL call select-app endpoint and store JWT token in SharedPreferences
5. WHEN available_apps does not contain MT app THEN the Flutter App SHALL display error "Tidak memiliki akses ke MT"
6. WHEN JWT token is stored THEN the Flutter App SHALL attach token to all subsequent API requests via Authorization header

### Requirement 5

**User Story:** As a karyawan, I want to logout from the application, so that my session is cleared securely.

#### Acceptance Criteria

1. WHEN karyawan triggers logout THEN the Flutter App SHALL clear JWT token from SharedPreferences
2. WHEN karyawan triggers logout THEN the Flutter App SHALL clear all stored user data
3. WHEN logout is complete THEN the Flutter App SHALL navigate to login screen
4. WHEN API returns 401 error THEN the Flutter App SHALL automatically logout and redirect to login screen

### Requirement 6

**User Story:** As a developer, I want proper data models for authentication, so that the code is type-safe and maintainable.

#### Acceptance Criteria

1. WHEN parsing login response THEN the Flutter App SHALL deserialize into AuthResponseModel with user, token, and available_apps
2. WHEN parsing available app THEN the Flutter App SHALL deserialize into AvailableApp with karyawan_aplikasi_id, aplikasi_id, nama_aplikasi, kode_aplikasi, and role
3. WHEN parsing user data THEN the Flutter App SHALL deserialize into AppUser with id, email, fullName, profilePicture, role, and aplikasi info
4. WHEN serializing models to JSON THEN the Flutter App SHALL produce valid JSON matching API contract
