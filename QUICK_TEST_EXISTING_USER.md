# ⚡ Quick Test - User Existing

## User Info
- **Email**: `admin.mt@kgb.local`
- **Password**: `123456`
- **Dibuat oleh**: Superadmin

## 🚀 Test Cepat (3 Langkah)

### 1. Cek Database (Supabase)

Buka **Supabase Dashboard → SQL Editor** dan jalankan:

```sql
-- Quick check user & access
SELECT 
  k.email,
  k.full_name,
  k.is_active,
  ka.role,
  a.kode_aplikasi
FROM 
  public.karyawan k
  LEFT JOIN public.karyawan_aplikasi ka ON k.id = ka.karyawan_id
  LEFT JOIN public.aplikasi a ON ka.aplikasi_id = a.id
WHERE 
  k.email = 'admin.mt@kgb.local';
```

**Hasil yang dibutuhkan:**
- ✅ `email = admin.mt@kgb.local`
- ✅ `is_active = true`
- ✅ `kode_aplikasi = MT`
- ✅ `role` = salah satu dari: Superadmin, Admin, Manajer, KASIE Teknisi, atau Teknisi

**Jika ada yang NULL atau tidak sesuai**, lihat file `TEST_LOGIN.md` untuk solusi.

### 2. Generate Password Hash (Jika Perlu)

**HANYA jika password hash di database salah atau user belum ada:**

```bash
cd backend
npm install
node generate-password.js 123456
```

Copy hash yang dihasilkan, lalu update di database:

```sql
UPDATE public.karyawan 
SET password_hash = 'PASTE_HASH_HERE'
WHERE email = 'admin.mt@kgb.local';
```

### 3. Test Login

#### Start Backend:
```
Double-click: start-backend.bat
```

#### Test dengan curl:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin.mt@kgb.local\",\"password\":\"123456\"}"
```

#### Atau test dengan Flutter:
1. Run Flutter app
2. Login dengan email `admin.mt@kgb.local` dan password `123456`

**Expected Response:**
```json
{
  "user": {
    "id": "...",
    "email": "admin.mt@kgb.local",
    "full_name": "..."
  },
  "token": "JWT_TOKEN...",
  "available_apps": [
    {
      "kode_aplikasi": "MT",
      "role": "Admin"
    }
  ]
}
```

## 🎯 Status Check

Setelah cek database, report hasil:

- [ ] User ada di tabel `karyawan`? (Ya/Tidak)
- [ ] `is_active = true`? (Ya/Tidak)
- [ ] Ada entry di `karyawan_aplikasi`? (Ya/Tidak)
- [ ] `kode_aplikasi = MT`? (Ya/Tidak)
- [ ] Role valid? (Sebutkan role-nya)

Beri tahu hasil pengecekan ini agar saya bisa bantu langkah selanjutnya!

