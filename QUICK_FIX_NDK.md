# ⚡ Quick Fix: Android NDK Version Issue

## 🚨 Error yang Terjadi

```
Your project is configured with Android NDK 26.3.11579264, but the following plugin(s) depend on a different Android NDK version:
- app_links requires Android NDK 27.0.12077973
- flutter_plugin_android_lifecycle requires Android NDK 27.0.12077973
- image_picker_android requires Android NDK 27.0.12077973
... (dan lainnya)
```

## ✅ Solusi Cepat

### Opsi 1: Install NDK 27 (Recommended)

**Langkah-langkah:**

1. **Buka Android Studio**
2. **File** → **Settings** (atau `Ctrl+Alt+S`)
3. **Appearance & Behavior** → **System Settings** → **Android SDK**
4. Pilih tab **SDK Tools**
5. Di bagian bawah, centang **Show Package Details**
6. Expand **NDK (Side by side)**
7. Centang **27.0.12077973** (atau versi terbaru)
8. Klik **Apply** → **OK**
9. Tunggu instalasi selesai

### Opsi 2: Install via Command Line

```bash
# Pastikan $ANDROID_HOME sudah di-set
# Windows PowerShell:
& "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" "ndk;27.0.12077973"
```

### Opsi 3: Temporary Fix (Jika tidak bisa install NDK 27 sekarang)

Jika Anda tidak bisa install NDK 27 sekarang, Anda bisa **temporary comment out** NDK version di `apps/karyawan_mobile/android/app/build.gradle.kts`:

```kotlin
android {
    namespace = "com.example.monitoring_maintenance"
    compileSdk = flutter.compileSdkVersion
    // Temporary: Comment out jika NDK 27 belum terinstall
    // ndkVersion = "27.0.12077973"

    // Ini akan menggunakan Flutter default NDK (mungkin ada warning, tapi build tetap berjalan)
    ...
}
```

**⚠️ Warning:** Opsi 3 mungkin akan menyebabkan beberapa plugin tidak berfungsi optimal.

## 📝 Verifikasi

Setelah NDK 27 terinstall, verify:

```bash
# Check NDK yang terinstall
# Windows:
dir "%LOCALAPPDATA%\Android\Sdk\ndk"

# Seharusnya ada folder: 27.0.12077973
```

## 🔄 Setelah Install NDK 27

1. Pastikan `ndkVersion = "27.0.12077973"` **tidak di-comment** di `build.gradle.kts`
2. Clean build:
   ```bash
   cd apps/karyawan_mobile
   flutter clean
   flutter pub get
   ```
3. Build lagi:
   ```bash
   flutter build apk
   # atau
   flutter run -d android
   ```

## 📚 Dokumentasi Lengkap

Lihat `INSTALL_NDK_27.md` untuk instruksi lebih detail.

## Status

- ✅ `build.gradle.kts` sudah diupdate untuk menggunakan NDK 27
- ⚠️ **Action Required**: Install NDK 27.0.12077973 via Android Studio SDK Manager

