# 🧪 Test Login dengan User Existing

## User yang Sudah Ada di Database

Menurut informasi, sudah ada user yang dibuat oleh superadmin:
- **Email**: `admin.mt@kgb.local`
- **Password**: `123456`

## 🔍 Langkah Cek Database

### Step 1: Buka Supabase Dashboard

1. Buka https://app.supabase.com
2. Pilih project: `dxzkxvczjdviuvmgwsft`
3. Klik **SQL Editor** di sidebar

### Step 2: Cek User di Database

Jalankan query ini di SQL Editor:

```sql
-- Cek apakah user admin.mt@kgb.local ada
SELECT 
  id,
  email,
  password_hash,
  full_name,
  is_active,
  created_at
FROM 
  public.karyawan
WHERE 
  email = 'admin.mt@kgb.local';
```

**Hasil yang diharapkan:**
- Jika ada: akan muncul 1 row dengan email `admin.mt@kgb.local`
- Jika tidak ada: hasil kosong (perlu insert user baru)

### Step 3: Cek Akses Aplikasi (Tiket MT)

```sql
-- Cek apakah user punya akses MT
SELECT 
  k.email,
  k.full_name,
  k.is_active,
  ka.role,
  a.kode_aplikasi,
  a.nama_aplikasi
FROM 
  public.karyawan k
  LEFT JOIN public.karyawan_aplikasi ka ON k.id = ka.karyawan_id
  LEFT JOIN public.aplikasi a ON ka.aplikasi_id = a.id
WHERE 
  k.email = 'admin.mt@kgb.local';
```

**Hasil yang diharapkan:**
- **email**: `admin.mt@kgb.local`
- **role**: `Admin` (atau `Superadmin`, `Manajer`, dll)
- **kode_aplikasi**: `MT`

Jika `kode_aplikasi` NULL atau bukan `MT`, user tidak punya akses ke Maintenance.

## 🔧 Skenario & Solusi

### Skenario 1: User Ada & Punya Tiket MT ✅

Jika query di atas menunjukkan user ada dan punya tiket MT, **LANGSUNG TEST LOGIN!**

#### Test dengan Backend Local:

1. Start backend: double-click `start-backend.bat`
2. Test dengan curl:

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin.mt@kgb.local\",\"password\":\"123456\"}"
```

3. Atau test dengan Postman:
   - Method: POST
   - URL: `http://localhost:3000/api/auth/login`
   - Body (raw JSON):
   ```json
   {
     "email": "admin.mt@kgb.local",
     "password": "123456"
   }
   ```

#### Test dengan Flutter App:

1. Pastikan backend running
2. Run Flutter app
3. Login dengan:
   - Email: `admin.mt@kgb.local`
   - Password: `123456`

**Harusnya login berhasil!** ✅

---

### Skenario 2: User Ada tapi TIDAK Punya Tiket MT ❌

Jika user ada tapi kolom `kode_aplikasi` NULL atau bukan `MT`, jalankan query ini:

```sql
-- Beri akses MT ke user
INSERT INTO public.karyawan_aplikasi (karyawan_id, aplikasi_id, role)
SELECT 
  k.id as karyawan_id,
  a.id as aplikasi_id,
  'Admin' as role
FROM 
  public.karyawan k,
  public.aplikasi a
WHERE 
  k.email = 'admin.mt@kgb.local'
  AND a.kode_aplikasi = 'MT'
ON CONFLICT DO NOTHING;
```

Lalu test login lagi.

---

### Skenario 3: User TIDAK Ada ❌

Jika user tidak ditemukan di database, buat user baru:

#### Step 1: Generate Password Hash

```bash
cd backend
npm install
node generate-password.js 123456
```

Output:
```
✅ Password hash generated successfully!

Password: 123456
Hash: $2b$10$abc123...xyz

Copy hash ini...
```

#### Step 2: Insert User Baru

Jalankan di Supabase SQL Editor (ganti `HASH_DARI_STEP_1`):

```sql
-- 1. Pastikan aplikasi MT ada
INSERT INTO public.aplikasi (nama_aplikasi, kode_aplikasi, deskripsi)
VALUES ('Maintenance System', 'MT', 'Sistem Monitoring Maintenance Mesin')
ON CONFLICT (kode_aplikasi) DO NOTHING;

-- 2. Insert user
INSERT INTO public.karyawan (email, password_hash, full_name, is_active)
VALUES (
  'admin.mt@kgb.local',
  'HASH_DARI_STEP_1', -- Paste hash dari generate-password
  'Admin MT',
  true
);

-- 3. Beri akses MT
INSERT INTO public.karyawan_aplikasi (karyawan_id, aplikasi_id, role)
SELECT 
  k.id,
  a.id,
  'Admin'
FROM 
  public.karyawan k,
  public.aplikasi a
WHERE 
  k.email = 'admin.mt@kgb.local'
  AND a.kode_aplikasi = 'MT';
```

#### Step 3: Verify

```sql
SELECT 
  k.email,
  k.full_name,
  ka.role,
  a.kode_aplikasi
FROM 
  public.karyawan k
  LEFT JOIN public.karyawan_aplikasi ka ON k.id = ka.karyawan_id
  LEFT JOIN public.aplikasi a ON ka.aplikasi_id = a.id
WHERE 
  k.email = 'admin.mt@kgb.local';
```

Harusnya muncul:
- email: `admin.mt@kgb.local`
- role: `Admin`
- kode_aplikasi: `MT`

Lalu test login!

---

## 🐛 Troubleshooting

### Login Gagal: "Email atau password salah"

**Kemungkinan 1: Password Hash Salah**
- Password di database tidak match dengan "123456"
- Solusi: Generate hash baru dan update:

```bash
cd backend
node generate-password.js 123456
```

```sql
UPDATE public.karyawan 
SET password_hash = 'NEW_HASH_HERE'
WHERE email = 'admin.mt@kgb.local';
```

**Kemungkinan 2: User Tidak Aktif**
- `is_active = false`
- Solusi:

```sql
UPDATE public.karyawan 
SET is_active = true
WHERE email = 'admin.mt@kgb.local';
```

### Login Gagal: "Anda tidak memiliki akses ke System Maintenance"

User tidak punya tiket MT. Jalankan:

```sql
INSERT INTO public.karyawan_aplikasi (karyawan_id, aplikasi_id, role)
SELECT k.id, a.id, 'Admin'
FROM public.karyawan k, public.aplikasi a
WHERE k.email = 'admin.mt@kgb.local' AND a.kode_aplikasi = 'MT';
```

### Backend Error: "Cannot find module..."

```bash
cd backend
npm install
```

## 📝 Checklist

- [ ] User `admin.mt@kgb.local` ada di database
- [ ] User punya `is_active = true`
- [ ] User punya tiket MT di `karyawan_aplikasi`
- [ ] Password hash untuk "123456" benar
- [ ] Backend running di `http://localhost:3000`
- [ ] Test login berhasil

---

**Lakukan pengecekan database dulu, lalu laporkan hasilnya!** 🔍

