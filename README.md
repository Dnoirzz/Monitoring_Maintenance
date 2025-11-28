# Maintenance Tracking (MT) System

Sistem monitoring dan tracking maintenance mesin.

## Project Structure

```
├── mt_backend/              # Backend API (Node.js/Express)
├── flutter_application_mt/  # Mobile App (Flutter)
├── mt_web_kantor/           # Web App (Coming Soon)
└── .kiro/                   # Specs & Documentation
```

## Quick Start

### Backend
```bash
cd mt_backend
npm install
# Edit .env dengan credentials Supabase
npm run dev
```

### Flutter App
```bash
cd flutter_application_mt
flutter pub get
flutter run
```

## API Documentation

Base URL: `http://localhost:3000`

- `POST /api/auth/login` - Login (Step 1)
- `POST /api/auth/select-app` - Select App (Step 2)
- `GET /api/auth/me` - Get Profile
