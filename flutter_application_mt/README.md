# Flutter Application MT

Aplikasi mobile Maintenance Tracking (MT) menggunakan Flutter.

## Setup

1. Install dependencies:
```bash
cd flutter_application_mt
flutter pub get
```

2. Run aplikasi:
```bash
flutter run
```

## Build

### Android
```bash
flutter build apk
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

## Struktur Folder

```
lib/
├── config/          # API & Supabase configuration
├── controller/      # Business logic controllers
├── model/           # Data models
├── providers/       # State management (Riverpod)
├── repositories/    # Data repositories
├── screen/          # UI screens
│   ├── admin/       # Admin screens
│   └── teknisi/     # Teknisi screens
└── services/        # API & storage services
```

## Features

- 2-Step Authentication (Login → Select App)
- Dashboard Admin & Teknisi
- Manajemen Asset/Mesin
- Maintenance Schedule
- Check Sheet
- Laporan Kerusakan
