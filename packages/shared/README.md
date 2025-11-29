# Shared Package

Package berisi kode bersama untuk admin_web dan karyawan_mobile.

## Struktur

- `config/` - Konfigurasi
- `models/` - Data models
- `repositories/` - Data access
- `services/` - Business logic
- `providers/` - State management
- `controllers/` - Controllers
- `utils/` - Utilities

## Usage

```yaml
dependencies:
  shared:
    path: ../../packages/shared
```

```dart
import 'package:shared/config/api_config.dart';
import 'package:shared/models/karyawan_model.dart';
```



