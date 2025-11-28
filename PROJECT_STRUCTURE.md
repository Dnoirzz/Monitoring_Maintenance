# Maintenance Tracking (MT) - Project Structure

## Struktur Folder

```
Monitoring_Maintenance/
│
├── mt_backend/                  # ✅ Backend API (Node.js/Express)
│   ├── src/
│   │   ├── server.js            # Entry point
│   │   ├── config/              # Database config
│   │   ├── middleware/          # Auth middleware
│   │   └── routes/              # API routes
│   ├── package.json             # npm run dev
│   └── .env.example
│
├── flutter_application_mt/      # ✅ Flutter Mobile App
│   ├── lib/
│   │   ├── config/              # API configuration
│   │   ├── controller/          # Business logic
│   │   ├── model/               # Data models
│   │   ├── providers/           # State management (Riverpod)
│   │   ├── repositories/        # Data repositories
│   │   ├── screen/              # UI screens
│   │   └── services/            # API services
│   ├── assets/                  # Images, icons
│   └── pubspec.yaml
│
├── mt_web_kantor/               # 🚧 Web App untuk Kantor (Coming Soon)
│   └── README.md
│
└── .kiro/                       # Kiro specs & steering
```

## Menjalankan Project

### 1. Backend
```bash
cd mt_backend
npm install
cp .env.example .env  # Edit dengan credentials Supabase
npm run dev
```
Server berjalan di `http://localhost:3000`

### 2. Flutter App
```bash
cd flutter_application_mt
flutter pub get
flutter run
```

### 3. Web Kantor (Coming Soon)
```bash
cd mt_web_kantor
npm install
npm run dev
```

## API Endpoints

Base URL: `http://localhost:3000`

### Auth (2-Step)
- `POST /api/auth/login` - Step 1: Login dengan email/password
- `POST /api/auth/select-app` - Step 2: Pilih app & dapat token
- `GET /api/auth/me` - Get profile (Protected)

### Resources (Protected)
- `/api/karyawan` - CRUD karyawan
- `/api/mesin` - CRUD mesin
- `/api/maintenance` - CRUD maintenance
- `/api/checksheet` - CRUD checksheet
