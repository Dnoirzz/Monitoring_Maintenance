-- ============================================
-- CEK USER YANG SUDAH ADA DI DATABASE
-- ============================================
-- Jalankan di Supabase SQL Editor

-- 1. Cek apakah user admin.mt@kgb.local ada
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

-- 2. Cek akses aplikasi user ini (tiket MT)
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

-- 3. Cek semua user yang ada
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
ORDER BY k.email;

-- ============================================
-- JIKA USER BELUM ADA, INSERT USER BARU
-- ============================================
-- Jalankan query ini HANYA jika user belum ada

-- Step 1: Generate password hash untuk "123456"
-- Jalankan di terminal:
-- cd backend
-- node generate-password.js 123456

-- Step 2: Insert user (ganti HASH_DARI_STEP_1 dengan hash yang dihasilkan)
INSERT INTO public.karyawan (email, password_hash, full_name, is_active)
VALUES (
  'admin.mt@kgb.local',
  'HASH_DARI_STEP_1', -- Hash untuk password: 123456
  'Admin MT',
  true
)
ON CONFLICT (email) DO NOTHING;

-- Step 3: Beri akses MT ke user dengan role Admin
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

-- ============================================
-- VERIFY USER SETELAH INSERT
-- ============================================
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

