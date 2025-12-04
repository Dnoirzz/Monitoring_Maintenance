-- ============================================
-- SCRIPT DUMMY DATA CHECKSHEET (DYNAMIC)
-- ============================================
-- Script ini akan mencari asset yang ada dan membuatkan dummy data checksheet
-- Jalankan script ini di Supabase SQL Editor

DO $$
DECLARE
    v_asset_id uuid;
    v_asset_name text;
    v_schedule_pending_id uuid;
    v_schedule_completed_id uuid;
    v_template_record RECORD;
    v_user_id uuid;
BEGIN
    -- 1. Ambil satu asset sembarang yang memiliki template checksheet
    SELECT a.id, a.nama_assets INTO v_asset_id, v_asset_name
    FROM assets a
    JOIN komponen_assets ka ON a.id = ka.assets_id
    JOIN cek_sheet_template cst ON ka.id = cst.komponen_assets_id
    LIMIT 1;

    IF v_asset_id IS NULL THEN
        RAISE NOTICE 'Tidak ditemukan asset yang memiliki template checksheet. Harap buat asset dan template terlebih dahulu.';
        RETURN;
    END IF;

    RAISE NOTICE 'Membuat dummy data untuk Asset: % (ID: %)', v_asset_name, v_asset_id;

    -- 2. Ambil user ID sembarang untuk completed_by (jika ada)
    SELECT id INTO v_user_id FROM karyawan LIMIT 1;

    -- 3. Buat Schedule PENDING (Hari ini)
    v_schedule_pending_id := gen_random_uuid();
    
    INSERT INTO cek_sheet_schedule (id, assets_id, tgl_jadwal, tgl_selesai, catatan)
    VALUES (
        v_schedule_pending_id,
        v_asset_id,
        CURRENT_DATE,
        NULL,
        NULL
    );
    
    RAISE NOTICE 'Created Pending Schedule ID: %', v_schedule_pending_id;

    -- 4. Buat Schedule COMPLETED (Kemarin)
    v_schedule_completed_id := gen_random_uuid();
    
    INSERT INTO cek_sheet_schedule (id, assets_id, tgl_jadwal, tgl_selesai, completed_by, catatan)
    VALUES (
        v_schedule_completed_id,
        v_asset_id,
        CURRENT_DATE - 1,
        CURRENT_DATE - 1,
        v_user_id,
        'Pemeriksaan rutin selesai, kondisi mesin baik.'
    );

    RAISE NOTICE 'Created Completed Schedule ID: %', v_schedule_completed_id;

    -- 5. Isi hasil pemeriksaan untuk Schedule Completed
    FOR v_template_record IN 
        SELECT cst.id 
        FROM cek_sheet_template cst
        JOIN komponen_assets ka ON cst.komponen_assets_id = ka.id
        WHERE ka.assets_id = v_asset_id
    LOOP
        -- Insert result dengan status random (mostly good)
        INSERT INTO cek_sheet_results (schedule_id, template_id, status, notes)
        VALUES (
            v_schedule_completed_id,
            v_template_record.id,
            CASE 
                WHEN random() < 0.8 THEN 'good'
                WHEN random() < 0.9 THEN 'repair'
                ELSE 'replace'
            END,
            CASE 
                WHEN random() < 0.8 THEN 'Kondisi normal'
                ELSE 'Perlu perhatian khusus'
            END
        );
    END LOOP;

    RAISE NOTICE 'Dummy data berhasil dibuat!';
END $$;
