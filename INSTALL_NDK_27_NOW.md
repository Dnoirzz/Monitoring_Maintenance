# 🚨 URGENT: Install Android NDK 27.0.12077973

## Error yang Terjadi

```
[CXX1101] NDK at C:\Users\LENOVO\AppData\Local\Android\sdk\ndk\27.0.12077973 did not have a source.properties file
```

Ini berarti NDK 27.0.12077973 **belum terinstall dengan benar** di sistem Anda.

## Solusi: Install NDK 27 melalui Android Studio

### Langkah-langkah:

1. **Buka Android Studio**
2. **Tools** → **SDK Manager** (atau tekan `Ctrl+Alt+S`)
3. Pilih tab **SDK Tools** (bukan SDK Platforms)
4. **Centang "Show Package Details"** di bagian bawah jendela
5. Scroll ke bagian **NDK (Side by side)**
6. **Expand** NDK (Side by side)
7. **Centang versi 27.0.12077973** (atau versi terbaru yang tersedia)
8. Klik **Apply** → **OK**
9. Tunggu hingga instalasi selesai (bisa memakan waktu beberapa menit)

### Verifikasi Instalasi

Setelah instalasi selesai, verifikasi dengan:

```powershell
Test-Path "$env:LOCALAPPDATA\Android\Sdk\ndk\27.0.12077973\source.properties"
```

Jika mengembalikan `True`, berarti NDK 27 sudah terinstall dengan benar.

## Setelah NDK 27 Terinstall

1. **Uncomment** baris `ndkVersion` di `apps/karyawan_mobile/android/app/build.gradle.kts`:

```kotlin
android {
    namespace = "com.example.monitoring_maintenance"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Uncomment baris ini
    ...
}
```

2. **Clean dan rebuild** project:

```bash
cd apps/karyawan_mobile
flutter clean
flutter pub get
flutter build apk
```

## Alternative: Install via Command Line

Jika Anda memiliki `sdkmanager` di path, Anda bisa install via command line:

```powershell
$sdkManager = "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat"
& $sdkManager "ndk;27.0.12077973" --sdk_root="$env:LOCALAPPDATA\Android\Sdk"
```

## Catatan Penting

- ⚠️ **NDK 27 WAJIB diinstall** karena beberapa plugin memerlukannya:

  - app_links
  - flutter_plugin_android_lifecycle
  - image_picker_android
  - path_provider_android
  - shared_preferences_android
  - sqflite_android
  - url_launcher_android

- ✅ NDK versi lebih tinggi adalah **backward compatible**, jadi tidak akan menyebabkan masalah

- 📦 Ukuran instalasi NDK 27 sekitar 1-2 GB, pastikan Anda memiliki ruang disk yang cukup

## Status

⏳ **PENDING**: Install NDK 27.0.12077973 melalui Android Studio SDK Manager

Setelah NDK terinstall, uncomment `ndkVersion = "27.0.12077973"` di `build.gradle.kts`.

