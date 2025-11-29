# 📦 Struktur Kode Bersama (Shared Code)

## ✅ Yang Sudah Benar

Dalam struktur monorepo, **controller, model, repository, services, dan utilities TIDAK berada di masing-masing aplikasi**, tetapi berada di **`packages/shared/`** karena mereka adalah **kode bersama** yang digunakan oleh kedua aplikasi.

## 📁 Struktur Saat Ini

### ✅ `packages/shared/lib/` - Kode Bersama

```
packages/shared/lib/
├── config/              ✅ API & Supabase config
├── controllers/         ✅ Semua controllers
│   ├── admin_controller.dart
│   ├── asset_controller.dart
│   ├── dashboard_controller.dart
│   ├── karyawan_controller.dart
│   └── ...
├── models/              ✅ Semua data models
│   ├── asset_model.dart
│   ├── karyawan_model.dart
│   ├── auth_response_model.dart
│   └── ...
├── repositories/        ✅ Semua repositories
│   ├── asset_repository.dart
│   ├── karyawan_repository.dart
│   └── ...
├── services/            ✅ Semua services
│   ├── auth_service.dart
│   ├── supabase_service.dart
│   └── ...
├── providers/           ✅ State management (Riverpod)
│   └── auth_provider.dart
└── utils/               ✅ Utilities & helpers
    ├── name_helper.dart
    └── route_helper.dart
```

### ✅ `apps/admin_web/lib/` - Hanya UI Admin

```
apps/admin_web/lib/
├── main.dart            ✅ Entry point
└── screen/              ✅ Hanya screen UI
    ├── admin/
    │   ├── dashboard_admin.dart
    │   ├── pages/
    │   └── widgets/
    └── login_page.dart
```

### ✅ `apps/karyawan_mobile/lib/` - Hanya UI Mobile

```
apps/karyawan_mobile/lib/
├── main.dart            ✅ Entry point
└── screen/              ✅ Hanya screen UI
    ├── teknisi/
    │   ├── dashboard_page.dart
    │   └── pages/
    ├── login_page.dart
    └── splach_scr.dart
```

## 🎯 Prinsip Monorepo

### ✅ BENAR (Struktur Saat Ini)

```
packages/shared/          ← Kode bersama (models, services, controllers, dll)
apps/admin_web/           ← Hanya UI khusus admin
apps/karyawan_mobile/     ← Hanya UI khusus mobile
```

### ❌ SALAH (Tidak Perlu Duplikasi)

```
apps/admin_web/lib/
  ├── controllers/        ❌ JANGAN duplikasi
  ├── models/             ❌ JANGAN duplikasi
  └── services/           ❌ JANGAN duplikasi

apps/karyawan_mobile/lib/
  ├── controllers/        ❌ JANGAN duplikasi
  ├── models/             ❌ JANGAN duplikasi
  └── services/           ❌ JANGAN duplikasi
```

## 💡 Keuntungan Struktur Ini

1. **Tidak Ada Duplikasi Kode** - Satu source of truth untuk logic
2. **Konsistensi** - Kedua aplikasi menggunakan logic yang sama
3. **Maintainability** - Update sekali, berlaku untuk semua
4. **Code Reusability** - Kode bisa digunakan berulang kali

## 📝 Cara Menggunakan

Kedua aplikasi mengimport dari `packages/shared/`:

```dart
// Di apps/admin_web/lib/screen/admin/dashboard_admin.dart
import 'package:shared/controllers/admin_controller.dart';
import 'package:shared/models/karyawan_model.dart';
import 'package:shared/services/supabase_service.dart';
```

```dart
// Di apps/karyawan_mobile/lib/screen/teknisi/dashboard_page.dart
import 'package:shared/controllers/dashboard_controller.dart';
import 'package:shared/models/asset_model.dart';
import 'package:shared/services/supabase_service.dart';
```

## ✅ Konfirmasi

**Ya, controller, model, repository, services, dll TIDAK dimasukkan di masing-masing lib aplikasi.**

Mereka berada di **`packages/shared/`** dan diimport melalui dependency di `pubspec.yaml`:

```yaml
# apps/admin_web/pubspec.yaml
dependencies:
  shared:
    path: ../../packages/shared
```

```yaml
# apps/karyawan_mobile/pubspec.yaml
dependencies:
  shared:
    path: ../../packages/shared
```

**Ini adalah struktur monorepo yang benar dan efisien!** ✅

