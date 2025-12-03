-- ============================================
-- DUMMY DATA UNTUK TESTING CHECKSHEET
-- ============================================
-- Jalankan script ini setelah membuat tabel cek_sheet_results
-- Script ini akan membuat:
-- 1. Asset (Mesin CNC-01)
-- 2. Komponen Asset
-- 3. Template Checksheet dengan berbagai item pemeriksaan
-- 4. Schedule Checksheet yang bisa diisi

-- ============================================
-- 1. INSERT ASSET (MESIN)
-- ============================================
INSERT INTO public.assets (id, nama_assets, kode_assets, jenis_assets, status, mt_priority)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Mesin CNC-01', 'CNC-001', 'Mesin Produksi', 'Aktif', 'High'),
  ('22222222-2222-2222-2222-222222222222', 'Mesin Bubut-03', 'BBT-003', 'Mesin Produksi', 'Aktif', 'Medium'),
  ('33333333-3333-3333-3333-333333333333', 'Generator Listrik-01', 'GEN-001', 'Listrik', 'Aktif', 'High')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 2. INSERT KOMPONEN ASSETS
-- ============================================
INSERT INTO public.komponen_assets (id, assets_id, nama_bagian, spesifikasi)
VALUES 
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Spindle Motor', 'Motor utama CNC 5.5KW'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'Chuck', 'Chuck 3-jaw 250mm'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '33333333-3333-3333-3333-333333333333', 'Generator Set', 'Genset 100KVA')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 3. INSERT CEK SHEET TEMPLATE
-- ============================================
-- Template untuk Mesin CNC-01
INSERT INTO public.cek_sheet_template (id, komponen_assets_id, jenis_pekerjaan, std_prwtn, alat_bahan, periode, interval_periode)
VALUES 
  -- Item 1
  ('t1111111-1111-1111-1111-111111111111', 
   'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
   'Pemeriksaan Level Oli Hidrolik',
   'Level oli harus berada di antara garis MIN dan MAX pada sight glass',
   'Lap bersih, Catatan level',
   'Harian',
   1),
  
  -- Item 2
  ('t1111111-1111-1111-1111-111111111112',
   'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
   'Pengecekan Suhu Bearing Spindle',
   'Suhu bearing tidak boleh melebihi 60°C saat operasi normal',
   'Thermometer infrared, Catatan suhu',
   'Harian',
   1),
  
  -- Item 3
  ('t1111111-1111-1111-1111-111111111113',
   'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
   'Pemeriksaan Kebersihan Chip Conveyor',
   'Chip conveyor harus bersih dari serpihan logam berlebih',
   'Sapu, Lap, Vacuum cleaner',
   'Harian',
   1),
  
  -- Item 4
  ('t1111111-1111-1111-1111-111111111114',
   'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
   'Pengecekan Tekanan Udara Kompresor',
   'Tekanan udara harus 6-8 bar',
   'Pressure gauge',
   'Harian',
   1),
  
  -- Item 5
  ('t1111111-1111-1111-1111-111111111115',
   'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
   'Pemeriksaan Kondisi Coolant',
   'Coolant harus bersih, tidak berbau, dan level mencukupi',
   'Refractometer, pH meter, Catatan kualitas',
   'Harian',
   1),
  
  -- Item 6
  ('t1111111-1111-1111-1111-111111111116',
   'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
   'Pengecekan Getaran Abnormal',
   'Tidak ada getaran yang tidak normal saat mesin beroperasi',
   'Vibration meter (opsional)',
   'Harian',
   1),
  
  -- Item 7
  ('t1111111-1111-1111-1111-111111111117',
   'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
   'Pemeriksaan Kondisi Kabel dan Koneksi',
   'Semua kabel dan koneksi listrik dalam kondisi baik, tidak ada yang terkelupas',
   'Visual inspection',
   'Harian',
   1)

ON CONFLICT (id) DO NOTHING;

-- Template untuk Mesin Bubut-03
INSERT INTO public.cek_sheet_template (id, komponen_assets_id, jenis_pekerjaan, std_prwtn, alat_bahan, periode, interval_periode)
VALUES 
  ('t2222222-2222-2222-2222-222222222221',
   'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
   'Pemeriksaan Kondisi Chuck',
   'Chuck harus bersih dan grip kuat, tidak ada bagian yang longgar',
   'Lap, Grease, Kunci chuck',
   'Harian',
   1),
  
  ('t2222222-2222-2222-2222-222222222222',
   'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
   'Pengecekan Level Oli Gearbox',
   'Level oli harus pada posisi normal sesuai indikator',
   'Dipstick, Oli SAE 90',
   'Harian',
   1),
  
  ('t2222222-2222-2222-2222-222222222223',
   'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
   'Pemeriksaan Belt Drive',
   'Belt harus dalam kondisi baik, tidak kendor atau retak',
   'Visual inspection',
   'Harian',
   1)

ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 4. INSERT CEK SHEET SCHEDULE
-- ============================================
-- Schedule untuk hari ini (pending - belum dikerjakan)
INSERT INTO public.cek_sheet_schedule (id, template_id, tgl_jadwal, tgl_selesai, completed_by)
VALUES 
  -- Schedule 1: Mesin CNC-01 - Pending
  ('s1111111-1111-1111-1111-111111111111',
   't1111111-1111-1111-1111-111111111111',
   CURRENT_DATE,
   NULL,
   NULL),
  
  -- Schedule 2: Mesin Bubut-03 - Pending
  ('s2222222-2222-2222-2222-222222222222',
   't2222222-2222-2222-2222-222222222221',
   CURRENT_DATE,
   NULL,
   NULL),
  
  -- Schedule 3: Mesin CNC-01 - Completed (contoh yang sudah selesai)
  ('s1111111-1111-1111-1111-111111111112',
   't1111111-1111-1111-1111-111111111111',
   CURRENT_DATE - INTERVAL '1 day',
   CURRENT_DATE - INTERVAL '1 day',
   NULL)

ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 5. CONTOH DATA HASIL CHECKSHEET (OPTIONAL)
-- ============================================
-- Ini contoh hasil checksheet yang sudah diisi (untuk schedule yang completed)
-- Anda bisa skip bagian ini jika ingin mengisi manual dari aplikasi

INSERT INTO public.cek_sheet_results (schedule_id, template_id, status, notes, photo)
VALUES 
  -- Hasil untuk schedule yang sudah completed
  ('s1111111-1111-1111-1111-111111111112', 't1111111-1111-1111-1111-111111111111', 'good', 'Level oli normal', NULL),
  ('s1111111-1111-1111-1111-111111111112', 't1111111-1111-1111-1111-111111111112', 'good', 'Suhu 45°C, normal', NULL),
  ('s1111111-1111-1111-1111-111111111112', 't1111111-1111-1111-1111-111111111113', 'repair', 'Ada penumpukan chip, sudah dibersihkan', NULL),
  ('s1111111-1111-1111-1111-111111111112', 't1111111-1111-1111-1111-111111111114', 'good', 'Tekanan 7 bar', NULL),
  ('s1111111-1111-1111-1111-111111111112', 't1111111-1111-1111-1111-111111111115', 'replace', 'Coolant keruh, perlu diganti', NULL),
  ('s1111111-1111-1111-1111-111111111112', 't1111111-1111-1111-1111-111111111116', 'good', 'Tidak ada getaran abnormal', NULL),
  ('s1111111-1111-1111-1111-111111111112', 't1111111-1111-1111-1111-111111111117', 'good', 'Semua kabel dalam kondisi baik', NULL)

ON CONFLICT DO NOTHING;

-- ============================================
-- QUERY UNTUK VERIFIKASI DATA
-- ============================================
-- Jalankan query ini untuk memastikan data sudah masuk

-- Cek jumlah schedule pending
SELECT 
  COUNT(*) as total_pending_schedules,
  'Schedule yang bisa diisi dari aplikasi' as keterangan
FROM cek_sheet_schedule 
WHERE tgl_selesai IS NULL;

-- Cek detail schedule dengan template items
SELECT 
  css.id as schedule_id,
  css.tgl_jadwal,
  a.nama_assets as mesin,
  COUNT(cst.id) as jumlah_item_pemeriksaan
FROM cek_sheet_schedule css
JOIN cek_sheet_template cst_main ON css.template_id = cst_main.id
JOIN komponen_assets ka ON cst_main.komponen_assets_id = ka.id
JOIN assets a ON ka.assets_id = a.id
JOIN cek_sheet_template cst ON cst.komponen_assets_id = ka.id
WHERE css.tgl_selesai IS NULL
GROUP BY css.id, css.tgl_jadwal, a.nama_assets
ORDER BY css.tgl_jadwal DESC;

-- ============================================
-- CATATAN PENTING
-- ============================================
/*
Setelah menjalankan script ini, Anda akan memiliki:

1. 3 Mesin (CNC-01, Bubut-03, Generator-01)
2. 2 Schedule PENDING yang bisa diisi:
   - Mesin CNC-01 dengan 7 item pemeriksaan
   - Mesin Bubut-03 dengan 3 item pemeriksaan
3. 1 Schedule COMPLETED sebagai referensi

Untuk testing aplikasi:
- Buka aplikasi (main_test.dart)
- Pilih schedule pending
- Isi semua item dengan Good/Repair/Replace
- Submit

Schedule ID untuk testing langsung ke ChecksheetPage:
- 's1111111-1111-1111-1111-111111111111' (CNC-01, 7 items)
- 's2222222-2222-2222-2222-222222222222' (Bubut-03, 3 items)
*/
