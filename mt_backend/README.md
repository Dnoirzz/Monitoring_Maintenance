# MT Backend

Backend API untuk aplikasi Maintenance Tracking (MT) dengan 2-Step Authentication.

## Setup

1. Install dependencies:
```bash
cd mt_backend
npm install
```

2. Copy `.env.example` ke `.env` dan isi dengan credentials:
```bash
cp .env.example .env
```

3. Edit `.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
JWT_SECRET=your-secret-key
PORT=3000
```

## Running

Development (dengan auto-reload):
```bash
npm run dev
```

Production:
```bash
npm start
```

## API Endpoints

### Auth (2-Step)
- `POST /api/auth/login` - Step 1: Login dengan email/password
- `POST /api/auth/select-app` - Step 2: Pilih aplikasi dan dapat token
- `GET /api/auth/me` - Get profile (Protected)

### Resources (Protected)
- `GET/POST/PUT/DELETE /api/karyawan`
- `GET/POST/PUT/DELETE /api/mesin`
- `GET/POST/PUT/DELETE /api/maintenance`
- `GET/POST/PUT/DELETE /api/checksheet`

### Utility
- `GET /` - API info
- `GET /api/health` - Health check

## 2-Step Authentication Flow

```
1. POST /api/auth/login
   Request: { email, password }
   Response: { karyawan_id, available_apps[] }

2. POST /api/auth/select-app
   Request: { karyawan_id, aplikasi_id }
   Response: { token, user }

3. Use token in Authorization header:
   Authorization: Bearer <token>
```
