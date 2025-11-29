# ✅ Fix Import Error - package:shar..

## Masalah yang Ditemukan

Error: `Couldn't resolve the package 'shar..' in 'package:shar../models/mt_schedule_model.dart'.`

## Penyebab

Beberapa file di `packages/shared/lib/services/maintenance_schedule/` memiliki typo pada import statement:

- ❌ `package:shar../models/mt_schedule_model.dart` (salah - ada titik-titik setelah "shar")
- ✅ `package:shared/models/mt_schedule_model.dart` (benar)

## File yang Diperbaiki

1. ✅ `packages/shared/lib/services/maintenance_schedule/calendar_service.dart`
2. ✅ `packages/shared/lib/services/maintenance_schedule/maintenance_date_service.dart`
3. ✅ `packages/shared/lib/services/maintenance_schedule/maintenance_dialog_service.dart`

## Solusi

Semua import yang salah sudah diperbaiki menjadi:

```dart
import 'package:shared/models/mt_schedule_model.dart';
```

## Verifikasi

Setelah perbaikan, jalankan:

```bash
cd packages/shared
flutter pub get

cd ../../apps/admin_web
flutter pub get
flutter analyze
```

## Status

✅ **FIXED** - Semua import typo sudah diperbaiki!

