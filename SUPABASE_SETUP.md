# Setup Supabase untuk Aplikasi Monitoring Maintenance

## 📋 Langkah Setup

### 1. Dapatkan Credentials Supabase

1. Buka [Supabase Dashboard](https://app.supabase.com)
2. Pilih project Anda atau buat project baru
3. Di sidebar, klik **Project Settings** → **API**
4. Salin:
   - **Project URL**: `https://dxzkxvczjdviuvmgwsft.supabase.co`
   - **Anon Key** (public): Key yang digunakan untuk Flutter app

### 2. Konfigurasi di Aplikasi

Buka file `lib/config/supabase_config.dart` dan update:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://dxzkxvczjdviuvmgwsft.supabase.co';
  static const String supabaseAnonKey = 'PASTE_YOUR_ANON_KEY_HERE';
}
```

⚠️ **PENTING**: Jangan commit/push file ini dengan API key yang sesungguhnya ke repository public!

### 3. Install Dependencies

Jalankan perintah berikut di terminal:

```powershell
flutter pub get
```

## 🗄️ Struktur Database

Aplikasi ini menggunakan tabel-tabel berikut di Supabase:

### Tabel Utama untuk Asset Management:

1. **`assets`** - Data master asset/mesin
   - `id` (int, PK, auto-increment)
   - `kode_aset` (text, nullable)
   - `nama_aset` (text, required)
   - `jenis_aset` (text, nullable)
   - `lokasi_id` (text, nullable)
   - `status` (text, nullable) - Active, Breakdown, Perlu Maintenance, dll
   - `maintenance_terakhir` (timestamp, nullable)
   - `maintenance_selanjutnya` (timestamp, nullable)
   - `gambar_aset` (text, nullable) - URL/path gambar
   - `created_at` (timestamp, auto)
   - `updated_at` (timestamp, auto)

2. **`bg_mesin`** - Bagian dari mesin/asset
   - `id` (int, PK, auto-increment)
   - `aset_id` (int, FK → assets.id)
   - `nama_bagian` (text, required) - Roll Atas, Roll Bawah, Engine, dll
   - `keterangan` (text, nullable)
   - `created_at` (timestamp, auto)
   - `updated_at` (timestamp, auto)

3. **`komponen_assets`** - Komponen detail dari bagian mesin
   - `id` (int, PK, auto-increment)
   - `bagian_id` (int, FK → bg_mesin.id)
   - `nama_komponen` (text, required) - Bearing, Seal, Shaft, dll
   - `spesifikasi` (text, nullable) - SKF 6205, Oil Seal 25x40x7, dll
   - `created_at` (timestamp, auto)
   - `updated_at` (timestamp, auto)

### Tabel Lainnya (untuk fitur selanjutnya):
- `cek_sheet_schedule`
- `cek_sheet_template`
- `maintenance_request`
- `mt_schedule`
- `mt_template`
- `notifikasi`
- `user_assets`

## 🚀 Cara Menjalankan

### 1. Pastikan Supabase sudah dikonfigurasi dengan benar

### 2. Jalankan aplikasi:

```powershell
flutter run
```

### 3. Login sebagai Admin

- Gunakan halaman login admin untuk masuk
- Setelah login, akses menu **Data Mesin** di sidebar

### 4. Tambah Asset Baru

1. Klik tombol **"Tambah"** di halaman Data Mesin
2. Isi form dengan informasi asset:
   - **Informasi Asset**: Nama, kode, jenis, status, lokasi, tanggal maintenance
   - **Bagian Asset**: Tambahkan satu atau lebih bagian mesin (misal: Roll Atas, Roll Bawah)
   - **Komponen**: Untuk setiap bagian, tambahkan komponen-komponen (misal: Bearing, Seal, Shaft dengan spesifikasinya)
3. Klik **"SIMPAN ASSET"**
4. Data akan tersimpan ke Supabase dan muncul di tabel Data Mesin

## 📁 Struktur Kode

```
lib/
├── config/
│   └── supabase_config.dart          # Konfigurasi Supabase URL & Key
├── model/
│   ├── asset.dart                     # Model untuk tabel assets
│   ├── bagian_mesin.dart              # Model untuk tabel bg_mesin
│   └── komponen_asset.dart            # Model untuk tabel komponen_assets
├── services/
│   └── supabase_service.dart          # Service singleton untuk Supabase client
├── repositories/
│   └── asset_repository.dart          # Repository untuk CRUD operations assets
└── screen/admin/pages/
    ├── add_asset_page.dart            # Form tambah asset baru
    └── data_assets_page.dart          # Halaman list data assets
```

## 🔧 Fitur yang Sudah Diimplementasikan

✅ Inisialisasi Supabase di aplikasi
✅ Model data untuk `assets`, `bg_mesin`, `komponen_assets`
✅ Repository layer untuk operasi database
✅ Form tambah asset dengan nested bagian dan komponen
✅ Validasi form
✅ Insert data ke Supabase (asset → bagian → komponen)
✅ Loading state dan error handling

## 📝 TODO / Fitur Selanjutnya

- [ ] Load data dari Supabase ke halaman Data Mesin (replace hardcoded data)
- [ ] Edit asset yang sudah ada
- [ ] Delete asset
- [ ] Upload gambar asset ke Supabase Storage
- [ ] Filter dan search data dari database
- [ ] Implementasi autentikasi Supabase untuk login admin
- [ ] Integrasi tabel lainnya (maintenance schedule, notifikasi, dll)
- [ ] Row Level Security (RLS) di Supabase untuk keamanan data

## 🛠️ Troubleshooting

### Error: "Supabase client not initialized"
- Pastikan `SupabaseService.initialize()` dipanggil di `main()` sebelum `runApp()`

### Error: "Failed to create asset"
- Cek apakah anon key sudah benar di `supabase_config.dart`
- Cek koneksi internet
- Cek di Supabase Dashboard → Table Editor apakah tabel `assets`, `bg_mesin`, `komponen_assets` sudah ada
- Cek Supabase Logs untuk detail error

### Error saat insert data
- Pastikan struktur tabel di Supabase sesuai dengan model di aplikasi
- Cek apakah field yang required di database sudah diisi di form

## 📖 Referensi

- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart/introduction)
- [Supabase Database Documentation](https://supabase.com/docs/guides/database)

---

**Catatan**: File ini akan terus diupdate seiring pengembangan fitur baru.
