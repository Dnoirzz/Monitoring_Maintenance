-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.activity_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  karyawan_id uuid,
  aplikasi_id uuid,
  action character varying,
  entity_type character varying,
  entity_id uuid,
  description text,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT activity_logs_pkey PRIMARY KEY (id),
  CONSTRAINT activity_logs_karyawan_id_fkey FOREIGN KEY (karyawan_id) REFERENCES public.karyawan(id),
  CONSTRAINT activity_logs_aplikasi_id_fkey FOREIGN KEY (aplikasi_id) REFERENCES public.aplikasi(id)
);
CREATE TABLE public.aplikasi (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nama_aplikasi character varying NOT NULL UNIQUE,
  kode_aplikasi character varying NOT NULL UNIQUE,
  deskripsi text,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT aplikasi_pkey PRIMARY KEY (id)
);
CREATE TABLE public.assets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nama_assets character varying,
  kode_assets character varying,
  jenis_assets USER-DEFINED,
  foto character varying,
  status USER-DEFINED DEFAULT 'Aktif'::status_assets_enum,
  mt_priority USER-DEFINED,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT assets_pkey PRIMARY KEY (id)
);
CREATE TABLE public.bg_mesin (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  assets_id uuid,
  nama_bagian character varying,
  CONSTRAINT bg_mesin_pkey PRIMARY KEY (id),
  CONSTRAINT bg_mesin_assets_id_fkey FOREIGN KEY (assets_id) REFERENCES public.assets(id)
);
CREATE TABLE public.cek_sheet_schedule (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  template_id uuid,
  tgl_jadwal date,
  tgl_selesai date,
  foto_sblm character varying,
  foto_sesudah character varying,
  catatan text,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  completed_by uuid,
  CONSTRAINT cek_sheet_schedule_pkey PRIMARY KEY (id),
  CONSTRAINT cek_sheet_schedule_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.cek_sheet_template(id),
  CONSTRAINT cek_sheet_schedule_completed_by_fkey FOREIGN KEY (completed_by) REFERENCES public.karyawan(id)
);
CREATE TABLE public.cek_sheet_template (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  komponen_assets_id uuid,
  periode USER-DEFINED,
  jenis_pekerjaan text,
  std_prwtn text,
  alat_bahan text,
  interval_periode integer,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT cek_sheet_template_pkey PRIMARY KEY (id),
  CONSTRAINT cek_sheet_template_komponen_assets_id_fkey FOREIGN KEY (komponen_assets_id) REFERENCES public.komponen_assets(id)
);
CREATE TABLE public.karyawan (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email character varying NOT NULL UNIQUE,
  password_hash character varying NOT NULL,
  full_name character varying,
  profile_picture character varying,
  phone character varying,
  jabatan character varying,
  department character varying,
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT karyawan_pkey PRIMARY KEY (id)
);
CREATE TABLE public.karyawan_aplikasi (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  karyawan_id uuid NOT NULL,
  aplikasi_id uuid NOT NULL,
  role character varying NOT NULL,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT karyawan_aplikasi_pkey PRIMARY KEY (id),
  CONSTRAINT karyawan_aplikasi_karyawan_id_fkey FOREIGN KEY (karyawan_id) REFERENCES public.karyawan(id),
  CONSTRAINT karyawan_aplikasi_aplikasi_id_fkey FOREIGN KEY (aplikasi_id) REFERENCES public.aplikasi(id)
);
CREATE TABLE public.komponen_assets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  assets_id uuid,
  bg_mesin_id uuid,
  nama_bagian character varying,
  produk_id uuid,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  spesifikasi character varying,
  CONSTRAINT komponen_assets_pkey PRIMARY KEY (id),
  CONSTRAINT komponen_assets_assets_id_fkey FOREIGN KEY (assets_id) REFERENCES public.assets(id),
  CONSTRAINT komponen_assets_bg_mesin_id_fkey FOREIGN KEY (bg_mesin_id) REFERENCES public.bg_mesin(id),
  CONSTRAINT komponen_assets_produk_id_fkey FOREIGN KEY (produk_id) REFERENCES public.produk(id)
);
CREATE TABLE public.maintenance_request (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  requester_id uuid,
  assets_id uuid,
  judul character varying,
  request_type USER-DEFINED,
  priority USER-DEFINED DEFAULT 'Medium'::req_priority_enum,
  keterangan text,
  status USER-DEFINED DEFAULT 'Pending'::req_status_enum,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT maintenance_request_pkey PRIMARY KEY (id),
  CONSTRAINT maintenance_request_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.karyawan(id),
  CONSTRAINT maintenance_request_assets_id_fkey FOREIGN KEY (assets_id) REFERENCES public.assets(id)
);
CREATE TABLE public.mt_schedule (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  template_id uuid,
  assets_id uuid,
  tgl_jadwal date,
  tgl_selesai date,
  status USER-DEFINED DEFAULT 'Perlu Maintenance'::mt_sched_status_enum,
  foto_sblm character varying,
  foto_sesudah character varying,
  catatan text,
  completed_by uuid,
  created_by uuid,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT mt_schedule_pkey PRIMARY KEY (id),
  CONSTRAINT mt_schedule_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.mt_template(id),
  CONSTRAINT mt_schedule_assets_id_fkey FOREIGN KEY (assets_id) REFERENCES public.assets(id),
  CONSTRAINT mt_schedule_completed_by_fkey FOREIGN KEY (completed_by) REFERENCES public.karyawan(id),
  CONSTRAINT mt_schedule_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.karyawan(id)
);
CREATE TABLE public.mt_template (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  bg_mesin_id uuid,
  periode USER-DEFINED,
  interval_periode integer,
  start_date date,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT mt_template_pkey PRIMARY KEY (id),
  CONSTRAINT mt_template_bg_mesin_id_fkey FOREIGN KEY (bg_mesin_id) REFERENCES public.bg_mesin(id)
);
CREATE TABLE public.notifikasi (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  jadwal_id uuid,
  karyawan_id uuid,
  pesan character varying,
  status USER-DEFINED DEFAULT 'Belum'::notif_status_enum,
  sent_at timestamp without time zone,
  CONSTRAINT notifikasi_pkey PRIMARY KEY (id),
  CONSTRAINT notifikasi_jadwal_id_fkey FOREIGN KEY (jadwal_id) REFERENCES public.cek_sheet_schedule(id),
  CONSTRAINT notifikasi_karyawan_id_fkey FOREIGN KEY (karyawan_id) REFERENCES public.karyawan(id)
);
CREATE TABLE public.produk (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nama_prdk character varying,
  jns_prdk USER-DEFINED,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT produk_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user_assets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  karyawan_id uuid,
  assets_id uuid,
  assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT user_assets_pkey PRIMARY KEY (id),
  CONSTRAINT user_assets_karyawan_id_fkey FOREIGN KEY (karyawan_id) REFERENCES public.karyawan(id),
  CONSTRAINT user_assets_assets_id_fkey FOREIGN KEY (assets_id) REFERENCES public.assets(id)
);