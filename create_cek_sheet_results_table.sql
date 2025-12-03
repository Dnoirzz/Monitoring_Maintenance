-- Create table for storing individual checksheet inspection results

CREATE TABLE public.cek_sheet_results (
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

-- Create index for faster queries
CREATE INDEX idx_cek_sheet_results_schedule_id ON public.cek_sheet_results(schedule_id);
CREATE INDEX idx_cek_sheet_results_template_id ON public.cek_sheet_results(template_id);

-- Add comment
COMMENT ON TABLE public.cek_sheet_results IS 'Stores individual inspection results for each checksheet item';
