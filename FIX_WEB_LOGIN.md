# 🔧 Fix: Login Error di Web Browser

## Masalah
Anda melihat error:
> "URL yang dicoba: http://10.0.2.2:3000/api/auth/login"

Ini terjadi karena Anda menjalankan aplikasi di **Web Browser**, tapi konfigurasi URL diset untuk **Android Emulator** (`10.0.2.2`).

Di Web, `10.0.2.2` tidak valid. Harus pakai `localhost`.

## ✅ Solusi (Sudah Diimplementasikan!)

Saya sudah mengupdate file `lib/config/api_config.dart` agar otomatis mendeteksi platform:

```dart
static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:3000'; // Web Browser
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000'; // Android Emulator
  } else {
    return 'http://localhost:3000'; // iOS / Desktop
  }
}
```

## 🚀 Apa yang Harus Anda Lakukan:

1. **Stop** aplikasi Flutter (tekan tombol Stop/Kotak Merah di IDE)
2. **Run** ulang aplikasi Flutter (`flutter run -d chrome` atau tekan F5)
3. **Test Login** lagi:
   - Email: `admin.mt@kgb.local`
   - Password: `123456`

(Pastikan backend server masih running di terminal lain dengan `start-backend.bat`)

Sekarang harusnya login berhasil! 🎉

