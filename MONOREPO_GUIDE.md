# 📁 Struktur Monorepo - Monitoring Maintenance

## Struktur Proyek

```
Monitoring_Maintenance/
├── apps/
│   ├── admin_web/              # ✅ Aplikasi Admin (Web)
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   └── screen/
│   │   │       ├── admin/
│   │   │       └── login_page.dart
│   │   ├── web/
│   │   └── pubspec.yaml
│   │
│   └── karyawan_mobile/        # ✅ Aplikasi Karyawan (Mobile)
│       ├── lib/
│       │   ├── main.dart
│       │   └── screen/
│       │       ├── teknisi/
│       │       ├── login_page.dart
│       │       └── splach_scr.dart
│       ├── android/
│       ├── ios/
│       └── pubspec.yaml
│
└── packages/
    └── shared/                 # ✅ Package Kode Bersama
        ├── lib/
        │   ├── config/
        │   ├── models/
        │   ├── repositories/
        │   ├── services/
        │   ├── providers/
        │   ├── controllers/
        │   └── utils/
        └── pubspec.yaml
```

## 🚀 Quick Start

### 1. Setup Dependencies

```bash
# Setup shared package
cd packages/shared
flutter pub get

# Setup admin web
cd ../../apps/admin_web
flutter pub get

# Setup karyawan mobile
cd ../karyawan_mobile
flutter pub get
```

### 2. Run Aplikasi

```bash
# Run Admin Web
cd apps/admin_web
flutter run -d chrome

# Run Karyawan Mobile
cd apps/karyawan_mobile
flutter run -d android
# atau
flutter run -d ios
```

## 📦 Package Structure

### Shared Package (`packages/shared/`)

Berisi kode yang digunakan bersama oleh kedua aplikasi:

- **config/** - API & Supabase configuration
- **models/** - Data models
- **repositories/** - Data access layer
- **services/** - Business logic & services
- **providers/** - Riverpod providers
- **controllers/** - Controllers
- **utils/** - Helper functions

### Admin Web App (`apps/admin_web/`)

Aplikasi web untuk admin (Superadmin, Manajer, Admin, KASIE Teknisi)

- Menggunakan `shared` package
- Web-specific UI dan routing

### Karyawan Mobile App (`apps/karyawan_mobile/`)

Aplikasi mobile untuk karyawan (Teknisi)

- Menggunakan `shared` package
- Mobile-specific UI dan routing
- Support Android & iOS

## 🔧 Development

### Build untuk Production

```bash
# Build admin web
cd apps/admin_web
flutter build web

# Build mobile APK
cd apps/karyawan_mobile
flutter build apk

# Build mobile App Bundle
flutter build appbundle
```

### Hot Reload

Kedua aplikasi support hot reload seperti biasa. File di `packages/shared/` juga akan auto-reload saat diubah.

## ⚠️ Important Notes

1. **Backend** tetap di root folder `backend/`
2. **Assets** tetap di root folder `assets/`
3. **Database schema** tetap di root
4. Setiap app memiliki `main.dart` sendiri
5. Import dari shared package menggunakan `package:shared/...`
6. Route helper sekarang hanya utility functions

## 📝 Struktur Sudah Dibuat

✅ Folder monorepo structure
✅ pubspec.yaml untuk semua packages/apps
✅ File shared dipindahkan ke packages/shared/
✅ File admin dipindahkan ke apps/admin_web/
✅ File karyawan dipindahkan ke apps/karyawan_mobile/
✅ Import paths sudah diupdate
✅ main.dart untuk kedua apps

**Status**: Ready to use! 🎉

