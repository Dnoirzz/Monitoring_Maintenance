# 📱 Install Android NDK 27.0.12077973

## Masalah

Project memerlukan Android NDK 27.0.12077973 untuk beberapa plugin, tapi NDK tersebut belum terinstall di sistem Anda.

## Solusi: Install NDK melalui Android Studio

### Cara 1: Melalui Android Studio (Recommended)

1. **Buka Android Studio**
2. **Tools** → **SDK Manager** (atau `Ctrl+Alt+S`)
3. Pilih tab **SDK Tools**
4. Centang **Show Package Details** di bagian bawah
5. Di bagian **NDK (Side by side)**, cari dan centang:
   - ✅ **27.0.12077973** (atau versi terbaru yang tersedia)
6. Klik **Apply** → **OK**
7. Tunggu hingga instalasi selesai

### Cara 2: Melalui Command Line

```bash
# Install NDK 27 menggunakan sdkmanager
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "ndk;27.0.12077973"
```

### Cara 3: Update build.gradle.kts (Jika NDK sudah terinstall)

Setelah NDK 27 terinstall, uncomment baris ini di `apps/karyawan_mobile/android/app/build.gradle.kts`:

```kotlin
android {
    namespace = "com.example.monitoring_maintenance"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Uncomment ini
    ...
}
```

## Verifikasi NDK Terinstall

Untuk cek NDK yang sudah terinstall:

```bash
# Windows
dir "%LOCALAPPDATA%\Android\Sdk\ndk"

# Atau lihat di Android Studio: Tools → SDK Manager → SDK Tools → NDK (Side by side)
```

## Alternative: Gunakan NDK yang Sudah Terinstall

Jika Anda tidak ingin install NDK 27, Anda bisa:

1. Cek versi NDK yang sudah terinstall
2. Update `ndkVersion` di `build.gradle.kts` ke versi yang tersedia
3. Pastikan versi tersebut compatible dengan plugin yang digunakan

## Catatan

- NDK versions adalah **backward compatible**
- Menggunakan versi lebih tinggi biasanya lebih aman
- Jika NDK 27 belum terinstall, build akan gagal dengan error: `NDK at ... did not have a source.properties file`

## Status

⚠️ **Action Required**: Install NDK 27.0.12077973 melalui Android Studio SDK Manager

Setelah NDK terinstall, uncomment `ndkVersion = "27.0.12077973"` di `build.gradle.kts`.

