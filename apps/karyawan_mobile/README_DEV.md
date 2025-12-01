# Development Guide - Karyawan Mobile

## Menjalankan Aplikasi untuk Development

Untuk development, gunakan `flutter run` yang akan langsung menjalankan aplikasi tanpa perlu build APK terlebih dahulu.

### Cara 1: Menggunakan Script (Recommended)

Jalankan script batch file:

```bash
run-dev.bat
```

### Cara 2: Manual Command

1. Buka terminal di folder `apps/karyawan_mobile`
2. Pastikan device/emulator sudah terhubung:
   ```bash
   flutter devices
   ```
3. Jalankan aplikasi:
   ```bash
   flutter run
   ```
   atau untuk debug mode:
   ```bash
   flutter run --debug
   ```

### Hot Reload

Setelah aplikasi berjalan:

- Tekan `r` untuk hot reload
- Tekan `R` untuk hot restart
- Tekan `q` untuk quit

### Troubleshooting

#### Error: "Gradle build failed to produce an .apk file"

Ini normal untuk development. Gunakan `flutter run` yang akan langsung install dan run tanpa perlu APK file.

#### Error: "No devices found"

1. Pastikan emulator sudah running atau device fisik terhubung via USB
2. Cek dengan: `flutter devices`
3. Enable USB debugging di device Android

#### Error: "Android x86 targets will be removed"

Ini hanya warning, tidak mempengaruhi development. Flutter akan tetap berjalan.

### Build APK (Hanya untuk Release)

Jika perlu build APK untuk testing release:

```bash
flutter build apk --debug
```

APK akan tersimpan di:

- `android/app/build/outputs/apk/debug/app-debug.apk`
