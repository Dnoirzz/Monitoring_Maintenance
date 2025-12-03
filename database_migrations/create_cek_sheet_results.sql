-- Migration: Create cek_sheet_results table
-- Purpose: Store individual inspection results for each checksheet template item
-- Date: 2025-12-03

-- Create enum type for inspection status
DO $$ BEGIN
    CREATE TYPE cek_status_enum AS ENUM ('good', 'repair', 'replace');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create cek_sheet_results table
CREATE TABLE IF NOT EXISTS public.cek_sheet_results (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  schedule_id uuid NOT NULL,
  template_id uuid NOT NULL,
  status cek_status_enum NOT NULL,
  notes text,
  photo character varying,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT cek_sheet_results_pkey PRIMARY KEY (id),
  CONSTRAINT cek_sheet_results_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.cek_sheet_schedule(id) ON DELETE CASCADE,
  CONSTRAINT cek_sheet_results_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.cek_sheet_template(id) ON DELETE CASCADE
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_cek_sheet_results_schedule_id ON public.cek_sheet_results(schedule_id);
CREATE INDEX IF NOT EXISTS idx_cek_sheet_results_template_id ON public.cek_sheet_results(template_id);

-- Add comment for documentation
COMMENT ON TABLE public.cek_sheet_results IS 'Stores individual inspection results for checksheet items';
COMMENT ON COLUMN public.cek_sheet_results.status IS 'Inspection status: good, repair, or replace';
COMMENT ON COLUMN public.cek_sheet_results.notes IS 'Additional notes for this specific inspection item';
COMMENT ON COLUMN public.cek_sheet_results.photo IS 'Photo URL/path for evidence';
