# Backend API - Monitoring Maintenance (Development)

Backend API local untuk development aplikasi Monitoring Maintenance yang connect ke database Supabase online.

## 📋 Prerequisites

- Node.js (v16 atau lebih baru) - [Download](https://nodejs.org/)
- Database sudah setup di Supabase

## 🚀 Cara Menjalankan

### Opsi 1: Menggunakan File .bat (Windows)

1. Double-click file `start-backend.bat` di root folder project
2. Backend akan otomatis install dependencies (jika belum) dan start server
3. Server akan running di `http://localhost:3000`

### Opsi 2: Manual

```bash
# Masuk ke folder backend
cd backend

# Install dependencies (hanya pertama kali)
npm install

# Jalankan server
npm start

# Atau untuk development dengan auto-restart
npm run dev
```

## 📁 Struktur File

```
backend/
├── .env                # Konfigurasi environment (Supabase URL & Key)
├── .env.example        # Template environment
├── package.json        # Dependencies
├── server.js           # Main server file
└── README.md          # Dokumentasi ini
```

## 🔧 Konfigurasi

File `.env` sudah dikonfigurasi dengan:
- Supabase URL
- Supabase Anon Key
- JWT Secret
- Port (default: 3000)

Jangan share file `.env` ke publik!

## 📡 Endpoints

### 1. Health Check
```
GET http://localhost:3000/api/health
```

Response:
```json
{
  "status": "OK",
  "message": "Backend API is running",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### 2. Login
```
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

Response (Success):
```json
{
  "user": {
    "id": "uuid...",
    "email": "user@example.com",
    "full_name": "Nama User"
  },
  "token": "JWT_TOKEN...",
  "available_apps": [
    {
      "kode_aplikasi": "MT",
      "role": "Teknisi"
    }
  ]
}
```

Response (Error):
```json
{
  "message": "Email atau password salah"
}
```

## 🧪 Test Backend

### Test dengan Browser
Buka: http://localhost:3000/api/health

### Test dengan curl
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"test123\"}"
```

### Test dengan Postman
1. Method: POST
2. URL: http://localhost:3000/api/auth/login
3. Body (raw JSON):
```json
{
  "email": "test@example.com",
  "password": "test123"
}
```

## 🔐 Setup User untuk Testing

Di Supabase, jalankan SQL berikut untuk membuat test user:

```sql
-- 1. Insert user ke tabel karyawan
INSERT INTO public.karyawan (email, password_hash, full_name, is_active)
VALUES (
  'teknisi@test.com',
  '$2b$10$6rMN5qZ3Y9X1Q5K8ZqXG9.YX8CZX0Q8X1Q5K8ZqXG9.YX8CZX0Q8X1', -- password: test123
  'Teknisi Test',
  true
);

-- 2. Get ID aplikasi MT
-- (Cek dulu ID aplikasi MT di tabel aplikasi)
SELECT id, kode_aplikasi FROM public.aplikasi WHERE kode_aplikasi = 'MT';

-- 3. Beri akses MT ke user
INSERT INTO public.karyawan_aplikasi (karyawan_id, aplikasi_id, role)
VALUES (
  (SELECT id FROM public.karyawan WHERE email = 'teknisi@test.com'),
  (SELECT id FROM public.aplikasi WHERE kode_aplikasi = 'MT'),
  'Teknisi'
);
```

## 🐛 Troubleshooting

### Error: "Node.js is not installed"
- Install Node.js dari https://nodejs.org/
- Restart terminal/command prompt

### Error: "Cannot find module..."
```bash
cd backend
npm install
```

### Error: "Port 3000 already in use"
- Stop aplikasi lain yang pakai port 3000
- Atau edit `.env` dan ganti `PORT=3000` ke port lain

### Error: "Supabase connection failed"
- Cek koneksi internet
- Cek SUPABASE_URL dan SUPABASE_ANON_KEY di `.env`

### Login gagal - "Email atau password salah"
- Pastikan user sudah dibuat di database
- Pastikan password di-hash dengan bcrypt
- Cek console/log backend untuk detail error

## 📝 Catatan

- Backend ini untuk **DEVELOPMENT ONLY**
- Connect ke database Supabase **ONLINE**
- Untuk production, deploy backend ke server dan ganti URL di Flutter app

