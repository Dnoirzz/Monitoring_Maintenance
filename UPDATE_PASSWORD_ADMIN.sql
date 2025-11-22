-- ============================================
-- UPDATE PASSWORD untuk admin.mt@kgb.local
-- ============================================
-- Password: 123456

-- Jalankan di Supabase SQL Editor

-- Update password hash untuk user admin.mt@kgb.local
-- Hash ini adalah bcrypt hash untuk password "123456"
UPDATE public.karyawan 
SET password_hash = '$2b$10$YQs3z5rI3L5L5L5L5L5L5eBqK7X5L5L5L5L5L5L5L5L5L5L5L5L5Lm'
WHERE email = 'admin.mt@kgb.local';

-- Verify update
SELECT 
  email,
  full_name,
  is_active,
  substring(password_hash, 1, 20) as password_preview
FROM 
  public.karyawan
WHERE 
  email = 'admin.mt@kgb.local';

-- Note: Hash di atas adalah placeholder
-- Generate hash yang benar dengan menjalankan:
-- cd backend
-- node generate-password.js 123456
-- Lalu ganti hash di UPDATE query dengan hasil dari script

