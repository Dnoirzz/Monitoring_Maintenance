# Karyawan Mobile App

Aplikasi mobile untuk karyawan/teknisi Monitoring Maintenance.

## Setup

```bash
flutter pub get
```

## Development (Recommended)

Untuk development, gunakan `flutter run` yang akan langsung menjalankan aplikasi tanpa perlu build APK:

### Quick Start

```bash
# Menggunakan script (Windows)
run-dev.bat

# Atau manual
flutter run
```

### Hot Reload

Setelah aplikasi berjalan:

- Tekan `r` untuk hot reload
- Tekan `R` untuk hot restart
- Tekan `q` untuk quit

**Catatan**: Error "Gradle build failed to produce an .apk file" adalah normal untuk development. `flutter run` akan langsung install dan run tanpa perlu APK file.

Lihat [README_DEV.md](README_DEV.md) untuk panduan lengkap development.

## Run (Alternative)

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

## Build (Hanya untuk Release)

```bash
# APK Debug
flutter build apk --debug

# APK Release
flutter build apk --release

# App Bundle
flutter build appbundle

# iOS
flutter build ios
```
