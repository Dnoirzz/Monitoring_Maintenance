# Maintenance Tracking (MT) System

Sistem monitoring dan tracking maintenance mesin dengan arsitektur 2-Step Authentication.

## 📁 Project Structure

```
Monitoring_Maintenance/
├── mt_backend/              # Backend API (Node.js/Express)
│   ├── src/
│   │   ├── server.js        # Entry point
│   │   ├── config/          # Database configuration
│   │   ├── middleware/      # JWT auth middleware
│   │   └── routes/          # API routes (auth, karyawan, mesin, dll)
│   ├── .env.example         # Environment template
│   └── package.json
│
├── flutter_application_mt/  # Mobile App (Flutter)
│   ├── lib/
│   │   ├── config/          # API configuration
│   │   ├── controller/      # Business logic controllers
│   │   ├── model/           # Data models
│   │   ├── providers/       # State management (Riverpod)
│   │   ├── repositories/    # Data repositories
│   │   ├── screen/          # UI screens (admin, teknisi)
│   │   └── services/        # API & storage services
│   ├── assets/              # Images, icons
│   └── pubspec.yaml
│
├── mt_web_kantor/           # Web App (Coming Soon)
│   └── README.md
│
└── .kiro/                   # Specs & documentation
```

## 🚀 Quick Start

### 1. Backend Setup

```bash
cd mt_backend
npm install

# Copy dan edit environment file
cp .env.example .env
# Edit .env dengan credentials Supabase Anda

# Jalankan server (development dengan auto-reload)
npm run dev
```

Server berjalan di `http://localhost:3000`

### 2. Flutter App Setup

```bash
cd flutter_application_mt
flutter pub get

# Jalankan aplikasi
flutter run
```

## 🔐 Authentication Flow (2-Step)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Login Screen│────▶│ POST /login │────▶│ Available   │
│ (email+pass)│     │             │     │ Apps List   │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Dashboard   │◀────│ JWT Token   │◀────│ Select App  │
│             │     │ Saved       │     │ (MT)        │
└─────────────┘     └─────────────┘     └─────────────┘
```

**Step 1 - Login:**
- User input email + password
- Backend validasi credentials
- Return list aplikasi yang bisa diakses

**Step 2 - Select App:**
- User pilih aplikasi "MT"
- Backend generate JWT token
- User masuk ke dashboard

## 📡 API Endpoints

Base URL: `http://localhost:3000`

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Step 1: Login dengan email/password |
| POST | `/api/auth/select-app` | Step 2: Pilih app & dapat token |
| GET | `/api/auth/me` | Get profile (Protected) |

### Resources (Protected - butuh JWT token)
| Resource | Endpoints |
|----------|-----------|
| Karyawan | `GET/POST/PUT/DELETE /api/karyawan` |
| Mesin | `GET/POST/PUT/DELETE /api/mesin` |
| Maintenance | `GET/POST/PUT/DELETE /api/maintenance` |
| Checksheet | `GET/POST/PUT/DELETE /api/checksheet` |

## 🛠 Tech Stack

### Backend
- Node.js + Express
- Supabase (PostgreSQL)
- JWT Authentication
- bcrypt (password hashing)

### Mobile App
- Flutter
- Riverpod (state management)
- SharedPreferences (local storage)
- HTTP client

## 📋 Environment Variables

File `mt_backend/.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
JWT_SECRET=your-secret-key-min-32-chars
PORT=3000
```

## 👥 User Roles

- Superadmin
- Manajer
- Admin
- KASIE Teknisi
- Teknisi

## 📱 Features

- ✅ 2-Step Authentication
- ✅ Dashboard Admin & Teknisi
- ✅ Manajemen Asset/Mesin
- ✅ Maintenance Schedule
- ✅ Check Sheet
- ✅ Laporan Kerusakan
- 🚧 Web Kantor (Coming Soon)
