-- ============================================
-- SETUP USER UNTUK TESTING
-- ============================================
-- Jalankan di Supabase SQL Editor

-- 1. Pastikan tabel aplikasi sudah ada entry untuk MT
-- Jika belum ada, insert dulu:
INSERT INTO public.aplikasi (nama_aplikasi, kode_aplikasi, deskripsi)
VALUES ('Maintenance System', 'MT', 'Sistem Monitoring Maintenance Mesin')
ON CONFLICT (kode_aplikasi) DO NOTHING;

-- 2. Insert test user teknisi
-- Password: test123
INSERT INTO public.karyawan (email, password_hash, full_name, is_active)
VALUES (
  'teknisi@test.com',
  '$2b$10$rZx9pxKxQy5KxQxKxQxKxeuH1J5L5L5L5L5L5L5L5L5L5L5L5L5L5Lm', -- bcrypt hash untuk 'test123'
  'Teknisi Test',
  true
)
ON CONFLICT (email) DO NOTHING;

-- 3. Beri akses MT ke user teknisi
INSERT INTO public.karyawan_aplikasi (karyawan_id, aplikasi_id, role)
SELECT 
  k.id as karyawan_id,
  a.id as aplikasi_id,
  'Teknisi' as role
FROM 
  public.karyawan k,
  public.aplikasi a
WHERE 
  k.email = 'teknisi@test.com'
  AND a.kode_aplikasi = 'MT'
ON CONFLICT DO NOTHING;

-- 4. Insert test user admin
-- Password: admin123
INSERT INTO public.karyawan (email, password_hash, full_name, is_active)
VALUES (
  'admin@test.com',
  '$2b$10$rZx9pxKxQy5KxQxKxQxKxeuH1J5L5L5L5L5L5L5L5L5L5L5L5L5L5Lm', -- bcrypt hash untuk 'admin123'
  'Admin Test',
  true
)
ON CONFLICT (email) DO NOTHING;

-- 5. Beri akses MT ke user admin dengan role Admin
INSERT INTO public.karyawan_aplikasi (karyawan_id, aplikasi_id, role)
SELECT 
  k.id as karyawan_id,
  a.id as aplikasi_id,
  'Admin' as role
FROM 
  public.karyawan k,
  public.aplikasi a
WHERE 
  k.email = 'admin@test.com'
  AND a.kode_aplikasi = 'MT'
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFY
-- ============================================
-- Cek apakah user sudah terbuat dengan benar
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
  k.email IN ('teknisi@test.com', 'admin@test.com');

-- ============================================
-- NOTES
-- ============================================
-- Password hash di atas adalah contoh.
-- Untuk generate password hash yang benar, gunakan Node.js:
-- 
-- const bcrypt = require('bcrypt');
-- const hash = await bcrypt.hash('password_anda', 10);
-- console.log(hash);

