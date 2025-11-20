-- ============================================
-- SQL Schema untuk Monitoring Maintenance
-- Supabase Database Setup
-- ============================================
-- Jalankan script ini di Supabase SQL Editor
-- untuk membuat tabel-tabel yang diperlukan
-- ============================================

-- 1. Tabel ASSETS (Data Master Asset/Mesin)
CREATE TABLE IF NOT EXISTS assets (
    id BIGSERIAL PRIMARY KEY,
    kode_aset TEXT,
    nama_aset TEXT NOT NULL,
    jenis_aset TEXT,
    lokasi_id TEXT,
    status TEXT,
    maintenance_terakhir TIMESTAMP WITH TIME ZONE,
    maintenance_selanjutnya TIMESTAMP WITH TIME ZONE,
    gambar_aset TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk performa query
CREATE INDEX IF NOT EXISTS idx_assets_nama ON assets(nama_aset);
CREATE INDEX IF NOT EXISTS idx_assets_jenis ON assets(jenis_aset);
CREATE INDEX IF NOT EXISTS idx_assets_status ON assets(status);
CREATE INDEX IF NOT EXISTS idx_assets_maintenance_selanjutnya ON assets(maintenance_selanjutnya);

-- Trigger untuk update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_assets_updated_at
    BEFORE UPDATE ON assets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================

-- 2. Tabel BG_MESIN (Bagian Mesin)
CREATE TABLE IF NOT EXISTS bg_mesin (
    id BIGSERIAL PRIMARY KEY,
    aset_id BIGINT NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    nama_bagian TEXT NOT NULL,
    keterangan TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk performa query
CREATE INDEX IF NOT EXISTS idx_bg_mesin_aset_id ON bg_mesin(aset_id);

-- Trigger untuk update updated_at
CREATE TRIGGER update_bg_mesin_updated_at
    BEFORE UPDATE ON bg_mesin
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================

-- 3. Tabel KOMPONEN_ASSETS (Komponen dari Bagian Mesin)
CREATE TABLE IF NOT EXISTS komponen_assets (
    id BIGSERIAL PRIMARY KEY,
    bagian_id BIGINT NOT NULL REFERENCES bg_mesin(id) ON DELETE CASCADE,
    nama_komponen TEXT NOT NULL,
    spesifikasi TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk performa query
CREATE INDEX IF NOT EXISTS idx_komponen_bagian_id ON komponen_assets(bagian_id);

-- Trigger untuk update updated_at
CREATE TRIGGER update_komponen_assets_updated_at
    BEFORE UPDATE ON komponen_assets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================

-- 4. Tabel CEK_SHEET_TEMPLATE (Template untuk Cek Sheet)
CREATE TABLE IF NOT EXISTS cek_sheet_template (
    id BIGSERIAL PRIMARY KEY,
    nama_template TEXT NOT NULL,
    deskripsi TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TRIGGER update_cek_sheet_template_updated_at
    BEFORE UPDATE ON cek_sheet_template
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================

-- 5. Tabel CEK_SHEET_SCHEDULE (Jadwal Cek Sheet)
CREATE TABLE IF NOT EXISTS cek_sheet_schedule (
    id BIGSERIAL PRIMARY KEY,
    template_id BIGINT REFERENCES cek_sheet_template(id) ON DELETE SET NULL,
    aset_id BIGINT REFERENCES assets(id) ON DELETE CASCADE,
    tanggal_cek TIMESTAMP WITH TIME ZONE NOT NULL,
    petugas_id TEXT,
    status TEXT DEFAULT 'pending', -- pending, in_progress, completed
    catatan TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cek_sheet_schedule_aset_id ON cek_sheet_schedule(aset_id);
CREATE INDEX IF NOT EXISTS idx_cek_sheet_schedule_tanggal ON cek_sheet_schedule(tanggal_cek);
CREATE INDEX IF NOT EXISTS idx_cek_sheet_schedule_status ON cek_sheet_schedule(status);

CREATE TRIGGER update_cek_sheet_schedule_updated_at
    BEFORE UPDATE ON cek_sheet_schedule
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================

-- 6. Tabel MT_TEMPLATE (Template Maintenance)
CREATE TABLE IF NOT EXISTS mt_template (
    id BIGSERIAL PRIMARY KEY,
    nama_template TEXT NOT NULL,
    deskripsi TEXT,
    interval_hari INTEGER, -- Interval maintenance dalam hari
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TRIGGER update_mt_template_updated_at
    BEFORE UPDATE ON mt_template
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================

-- 7. Tabel MT_SCHEDULE (Jadwal Maintenance)
CREATE TABLE IF NOT EXISTS mt_schedule (
    id BIGSERIAL PRIMARY KEY,
    template_id BIGINT REFERENCES mt_template(id) ON DELETE SET NULL,
    aset_id BIGINT REFERENCES assets(id) ON DELETE CASCADE,
    tanggal_maintenance TIMESTAMP WITH TIME ZONE NOT NULL,
    petugas_id TEXT,
    status TEXT DEFAULT 'scheduled', -- scheduled, in_progress, completed, cancelled
    catatan TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mt_schedule_aset_id ON mt_schedule(aset_id);
CREATE INDEX IF NOT EXISTS idx_mt_schedule_tanggal ON mt_schedule(tanggal_maintenance);
CREATE INDEX IF NOT EXISTS idx_mt_schedule_status ON mt_schedule(status);

CREATE TRIGGER update_mt_schedule_updated_at
    BEFORE UPDATE ON mt_schedule
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================

-- 8. Tabel MAINTENANCE_REQUEST (Request Maintenance dari Teknisi)
CREATE TABLE IF NOT EXISTS maintenance_request (
    id BIGSERIAL PRIMARY KEY,
    aset_id BIGINT REFERENCES assets(id) ON DELETE CASCADE,
    petugas_id TEXT NOT NULL, -- ID user yang request
    jenis_request TEXT NOT NULL, -- breakdown, preventive, inspection
    deskripsi TEXT,
    prioritas TEXT DEFAULT 'medium', -- low, medium, high, critical
    status TEXT DEFAULT 'pending', -- pending, approved, in_progress, completed, rejected
    tanggal_request TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    tanggal_approved TIMESTAMP WITH TIME ZONE,
    approved_by TEXT,
    catatan_approval TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_maintenance_request_aset_id ON maintenance_request(aset_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_request_status ON maintenance_request(status);
CREATE INDEX IF NOT EXISTS idx_maintenance_request_prioritas ON maintenance_request(prioritas);

CREATE TRIGGER update_maintenance_request_updated_at
    BEFORE UPDATE ON maintenance_request
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================

-- 9. Tabel NOTIFIKASI (Notifikasi untuk User)
CREATE TABLE IF NOT EXISTS notifikasi (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL, -- ID user yang menerima notifikasi
    judul TEXT NOT NULL,
    pesan TEXT NOT NULL,
    tipe TEXT DEFAULT 'info', -- info, warning, alert, maintenance_reminder
    related_table TEXT, -- assets, mt_schedule, maintenance_request, dll
    related_id BIGINT, -- ID dari tabel terkait
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifikasi_user_id ON notifikasi(user_id);
CREATE INDEX IF NOT EXISTS idx_notifikasi_is_read ON notifikasi(is_read);
CREATE INDEX IF NOT EXISTS idx_notifikasi_created_at ON notifikasi(created_at);

-- ============================================

-- 10. Tabel USER_ASSETS (Relasi User dengan Asset)
-- Untuk assign asset ke teknisi/kepala teknisi tertentu
CREATE TABLE IF NOT EXISTS user_assets (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    aset_id BIGINT NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'teknisi', -- teknisi, kepala_teknisi
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_assets_user_id ON user_assets(user_id);
CREATE INDEX IF NOT EXISTS idx_user_assets_aset_id ON user_assets(aset_id);

-- Unique constraint untuk prevent duplicate assignment
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_user_asset ON user_assets(user_id, aset_id);

-- ============================================

-- Sample Data untuk Testing (Opsional)
-- Uncomment jika ingin insert sample data

/*
-- Sample Assets
INSERT INTO assets (kode_aset, nama_aset, jenis_aset, status, maintenance_terakhir, maintenance_selanjutnya)
VALUES 
    ('MES-001', 'Creeper 1', 'Mesin Produksi', 'Active', '2024-01-15', '2024-02-15'),
    ('ALT-001', 'Excavator', 'Alat Berat', 'Active', '2024-01-10', '2024-02-10'),
    ('LIS-001', 'Generator Set', 'Listrik', 'Active', '2024-01-05', '2024-02-05');

-- Sample Bagian Mesin untuk Creeper 1 (aset_id = 1)
INSERT INTO bg_mesin (aset_id, nama_bagian, keterangan)
VALUES 
    (1, 'Roll Atas', 'Bagian roll atas mesin creeper'),
    (1, 'Roll Bawah', 'Bagian roll bawah mesin creeper');

-- Sample Komponen untuk Roll Atas (bagian_id = 1)
INSERT INTO komponen_assets (bagian_id, nama_komponen, spesifikasi)
VALUES 
    (1, 'Bearing', 'SKF 6205'),
    (1, 'Seal', 'Oil Seal 25x40x7'),
    (1, 'Shaft', 'Shaft Steel 40mm');

-- Sample Komponen untuk Roll Bawah (bagian_id = 2)
INSERT INTO komponen_assets (bagian_id, nama_komponen, spesifikasi)
VALUES 
    (2, 'Bearing', 'SKF 6206'),
    (2, 'Seal', 'Oil Seal 30x45x7'),
    (2, 'Shaft', 'Shaft Steel 45mm');
*/

-- ============================================
-- SELESAI
-- ============================================

-- Verifikasi tabel yang sudah dibuat:
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;
