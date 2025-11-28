# Implementation Plan

## 1. Backend API Updates

- [x] 1.1 Update POST /api/auth/login endpoint
  - Modify response to return karyawan_id, email, full_name, available_apps (with karyawan_aplikasi_id, aplikasi_id, nama_aplikasi, kode_aplikasi, role)
  - Remove token generation from login (move to select-app)
  - Add proper error responses (401, 403)
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

- [x] 1.2 Create POST /api/auth/select-app endpoint
  - Accept karyawan_id and aplikasi_id
  - Verify access in karyawan_aplikasi table
  - Generate JWT token with karyawan_id, karyawan_aplikasi_id, email, role, aplikasi_kode
  - Set token expiry to 7 days
  - Return token and user object with role and aplikasi info
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 1.3 Create GET /api/auth/me endpoint
  - Verify JWT token from Authorization header
  - Return user profile with karyawan_id, email, full_name, role, profile_picture, aplikasi info
  - Return 401 for invalid/expired/missing token
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

## 2. Flutter Data Models

- [x] 2.1 Create LoginResponse model
  - Create lib/model/login_response.dart
  - Fields: karyawanId, email, fullName, availableApps
  - Implement fromJson and toJson methods
  - _Requirements: 6.1_

- [x] 2.2 Create AvailableApp model
  - Create lib/model/available_app.dart
  - Fields: karyawanAplikasiId, aplikasiId, namaAplikasi, kodeAplikasi, role
  - Implement fromJson and toJson methods
  - _Requirements: 6.2_

- [x] 2.3 Create SelectAppResponse model
  - Create lib/model/select_app_response.dart
  - Fields: token, user (AppUser)
  - Implement fromJson and toJson methods
  - _Requirements: 6.3_

- [x] 2.4 Update AppUser model
  - Update lib/model/auth_response_model.dart or create new file
  - Fields: karyawanId, email, fullName, role, profilePicture, aplikasi (AppInfo)
  - Create AppInfo class with nama and kode
  - Implement fromJson and toJson methods
  - _Requirements: 6.3_

- [ ]* 2.5 Write property test for model serialization round-trip
  - **Property 9: Model serialization round-trip**
  - Test LoginResponse, AvailableApp, SelectAppResponse, AppUser
  - **Validates: Requirements 6.1, 6.2, 6.3, 6.4**

## 3. Flutter ApiClient

- [x] 3.1 Create ApiClient service
  - Create lib/services/api_client.dart
  - Implement get, post, put, delete methods
  - Auto-attach Authorization header from stored token
  - Handle 401 response → trigger logout callback
  - _Requirements: 4.6, 5.4_

- [ ]* 3.2 Write property test for 401 auto-logout
  - **Property 8: 401 response triggers auto-logout**
  - **Validates: Requirements 5.4**

## 4. Flutter AuthService Updates

- [x] 4.1 Update AuthService login method
  - Call POST /api/auth/login
  - Return LoginResponse (not token)
  - Handle error responses
  - _Requirements: 1.1, 1.2_

- [x] 4.2 Add AuthService selectApp method
  - Call POST /api/auth/select-app with karyawanId and aplikasiId
  - Return SelectAppResponse with token and user
  - Save token to StorageService
  - _Requirements: 2.1, 2.2, 2.3, 4.4_

- [x] 4.3 Add AuthService getProfile method
  - Call GET /api/auth/me with token
  - Return AppUser profile
  - _Requirements: 3.1, 3.2_

- [ ]* 4.4 Write property test for token storage after select-app
  - **Property 6: Token stored after select-app**
  - **Validates: Requirements 4.4, 4.6**

## 5. Flutter AuthProvider Updates

- [x] 5.1 Update AuthProvider state for 2-step flow
  - Add availableApps to state
  - Add karyawanId temporary storage
  - Add step indicator (login/selectApp/authenticated)
  - _Requirements: 4.1_

- [x] 5.2 Update AuthProvider login method
  - Call AuthService.login
  - Store karyawanId and availableApps in state
  - Filter availableApps for MT only
  - Auto-select if only one MT app
  - Show error if no MT app access
  - _Requirements: 4.1, 4.2, 4.5_

- [x] 5.3 Add AuthProvider selectApp method
  - Call AuthService.selectApp
  - Save token and user data to StorageService
  - Update state to authenticated
  - _Requirements: 4.4_

- [x] 5.4 Update AuthProvider logout method
  - Clear all stored data via StorageService
  - Reset state to initial
  - _Requirements: 5.1, 5.2_

- [ ]* 5.5 Write property test for single MT app auto-select
  - **Property 5: Single MT app triggers auto-select**
  - **Validates: Requirements 4.2**

- [ ]* 5.6 Write property test for logout clears all data
  - **Property 7: Logout clears all stored data**
  - **Validates: Requirements 5.1, 5.2**

## 6. Flutter Login UI Updates

- [x] 6.1 Update LoginPage for 2-step flow
  - Handle login response with availableApps
  - Show app selection dialog if multiple MT apps
  - Auto-navigate to dashboard after select-app
  - Show error messages for access denied
  - _Requirements: 4.2, 4.3, 4.5_

## 7. Checkpoint

- [x] 7. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## 8. Integration and Final Testing

- [ ]* 8.1 Write integration test for complete 2-step login flow
  - Test login → select-app → authenticated flow
  - Test auto-select behavior
  - Test logout flow
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 5.1, 5.2, 5.3_

- [ ] 9. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
