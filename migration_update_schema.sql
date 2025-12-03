-- ============================================
-- MIGRATION SCRIPT: UPDATE CEK_SHEET_SCHEDULE
-- ============================================
-- Jalankan script ini di Supabase SQL Editor

-- 1. Hapus Foreign Key lama (template_id)
ALTER TABLE public.cek_sheet_schedule
DROP CONSTRAINT IF EXISTS cek_sheet_schedule_template_id_fkey;

-- 2. Hapus kolom template_id
ALTER TABLE public.cek_sheet_schedule
DROP COLUMN IF EXISTS template_id;

-- 3. Tambah kolom assets_id baru
ALTER TABLE public.cek_sheet_schedule
ADD COLUMN assets_id uuid;

-- 4. Tambah Foreign Key baru ke tabel assets
ALTER TABLE public.cek_sheet_schedule
ADD CONSTRAINT cek_sheet_schedule_assets_id_fkey 
FOREIGN KEY (assets_id) REFERENCES public.assets(id);

-- 5. Hapus kolom foto yang tidak diperlukan (karena sudah ada di cek_sheet_results)
ALTER TABLE public.cek_sheet_schedule
DROP COLUMN IF EXISTS foto_sblm,
DROP COLUMN IF EXISTS foto_sesudah;

-- 6. Pastikan tabel cek_sheet_results sudah dibuat (jika belum)
CREATE TABLE IF NOT EXISTS public.cek_sheet_results (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  schedule_id uuid NOT NULL,
  template_id uuid NOT NULL,
  status character varying NOT NULL,
  notes text,
  photo character varying,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT cek_sheet_results_pkey PRIMARY KEY (id),
  CONSTRAINT cek_sheet_results_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.cek_sheet_schedule(id) ON DELETE CASCADE,
  CONSTRAINT cek_sheet_results_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.cek_sheet_template(id),
  CONSTRAINT cek_sheet_results_status_check CHECK (status IN ('good', 'repair', 'replace'))
);

-- 7. Indexing untuk performa
CREATE INDEX IF NOT EXISTS idx_cek_sheet_schedule_assets_id ON public.cek_sheet_schedule(assets_id);
CREATE INDEX IF NOT EXISTS idx_cek_sheet_results_schedule_id ON public.cek_sheet_results(schedule_id);
