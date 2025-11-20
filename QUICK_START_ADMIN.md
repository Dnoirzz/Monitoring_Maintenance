# 🚀 Quick Start Guide - Tambah Asset Admin

## Langkah-langkah Setup Awal

### 1️⃣ Setup Supabase Credentials

**Sebelum menjalankan aplikasi**, Anda HARUS setup credentials Supabase terlebih dahulu:

1. Buka file: `lib/config/supabase_config.dart`
2. Ganti `YOUR_SUPABASE_ANON_KEY_HERE` dengan **Anon Key** dari Supabase Dashboard Anda

**Cara mendapatkan Anon Key:**
- Login ke [Supabase Dashboard](https://app.supabase.com)
- Pilih project: `dxzkxvczjdviuvmgwsft`
- Klik **Project Settings** (icon gear) → **API**
- Copy **anon** **public** key
- Paste ke `supabaseAnonKey` di file config

```dart
// File: lib/config/supabase_config.dart
static const String supabaseAnonKey = 'PASTE_KEY_ANDA_DISINI';
```

### 2️⃣ Install Dependencies

Buka terminal di folder project dan jalankan:

```powershell
flutter pub get
```

### 3️⃣ Jalankan Aplikasi

```powershell
flutter run
```

---

## 📱 Cara Menggunakan Fitur Tambah Asset

### Step 1: Login sebagai Admin
- Aplikasi akan membuka halaman login
- Masukkan credentials admin (sesuai yang ada di database Supabase)
- Atau gunakan tombol demo untuk langsung masuk

### Step 2: Navigasi ke Data Mesin
- Setelah login, klik menu **"Data Mesin"** di sidebar
- Anda akan melihat halaman list data assets

### Step 3: Tambah Asset Baru
1. Klik tombol **"Tambah"** (hijau dengan icon +)
2. Halaman form akan terbuka

### Step 4: Isi Form Asset

#### A. Informasi Asset (Section Atas)
- **Kode Asset**: Opsional, misal: `AST-001`, `MES-CRPR-001`
- **Nama Asset**: **WAJIB**, misal: `Creeper 1`, `Excavator`, `Generator Set`
- **Jenis Asset**: Pilih dari dropdown
  - Mesin Produksi
  - Alat Berat
  - Listrik
  - Kendaraan
  - Peralatan
  - Lainnya
- **Status**: Pilih status asset
  - Active
  - Breakdown
  - Perlu Maintenance
  - Maintenance
  - Non-Active
- **Lokasi ID**: Opsional, misal: `Lantai 1`, `Gudang A`
- **Maintenance Terakhir**: Klik icon edit untuk pilih tanggal
- **Maintenance Selanjutnya**: Klik icon edit untuk pilih tanggal
- **Pilih Gambar**: Klik untuk upload gambar asset (opsional)

#### B. Bagian Asset (Section Bawah)

**Contoh struktur:**
```
Asset: Creeper 1
  ├── Bagian 1: Roll Atas
  │   ├── Komponen: Bearing → Spesifikasi: SKF 6205
  │   ├── Komponen: Seal → Spesifikasi: Oil Seal 25x40x7
  │   └── Komponen: Shaft → Spesifikasi: Shaft Steel 40mm
  └── Bagian 2: Roll Bawah
      ├── Komponen: Bearing → Spesifikasi: SKF 6206
      └── Komponen: Seal → Spesifikasi: Oil Seal 30x45x7
```

**Cara mengisi:**

1. **Bagian 1** (sudah ada by default)
   - **Nama Bagian**: Misal `Roll Atas`, `Engine`, `Hydraulic System`
   - **Keterangan**: Opsional, deskripsi bagian

2. **Komponen** (minimal 1 per bagian)
   - **Nama Komponen**: Misal `Bearing`, `Seal`, `Shaft`, `Pulley`
   - **Spesifikasi**: Misal `SKF 6205`, `Oil Seal 25x40x7`
   
3. **Tambah Komponen**
   - Klik **"+ Tambah Komponen"** untuk menambah komponen baru di bagian yang sama
   - Klik icon **🗑️ merah** untuk hapus komponen

4. **Tambah Bagian Baru**
   - Klik tombol **"Tambah Bagian"** (hijau, di atas) untuk menambah bagian asset baru
   - Klik icon **🗑️ merah** di pojok kanan card untuk hapus bagian

### Step 5: Simpan
- Setelah semua data diisi, klik tombol **"SIMPAN ASSET"**
- Loading indicator akan muncul
- Jika berhasil:
  - Muncul snackbar hijau: "Asset berhasil ditambahkan!"
  - Otomatis kembali ke halaman Data Mesin
- Jika gagal:
  - Muncul dialog error dengan pesan kesalahan

---

## ✅ Contoh Pengisian Form

### Contoh 1: Creeper 1 (Mesin Produksi)

**Informasi Asset:**
- Nama Asset: `Creeper 1`
- Jenis Asset: `Mesin Produksi`
- Status: `Active`
- Maintenance Terakhir: `15 Januari 2024`
- Maintenance Selanjutnya: `15 Februari 2024`

**Bagian 1: Roll Atas**
- Komponen 1: `Bearing` → `SKF 6205`
- Komponen 2: `Seal` → `Oil Seal 25x40x7`
- Komponen 3: `Shaft` → `Shaft Steel 40mm`

**Bagian 2: Roll Bawah**
- Komponen 1: `Bearing` → `SKF 6206`
- Komponen 2: `Seal` → `Oil Seal 30x45x7`
- Komponen 3: `Shaft` → `Shaft Steel 45mm`

### Contoh 2: Generator Set

**Informasi Asset:**
- Nama Asset: `Generator Set 100KVA`
- Jenis Asset: `Listrik`
- Status: `Active`

**Bagian 1: Engine**
- Komponen 1: `Alternator` → `Alternator 12V 100A`
- Komponen 2: `Battery` → `Battery Dry 12V 100Ah`
- Komponen 3: `Fuel Filter` → `Fuel Filter Element`

---

## 🐛 Troubleshooting

### ❌ Error: "Supabase client not initialized"
**Solusi:** Pastikan Anda sudah setup `supabaseAnonKey` di `lib/config/supabase_config.dart`

### ❌ Error: "Failed to create asset"
**Kemungkinan penyebab:**
1. Anon Key salah atau tidak valid
2. Tidak ada koneksi internet
3. Tabel di Supabase belum dibuat
4. Struktur tabel tidak sesuai dengan model

**Solusi:**
- Cek koneksi internet
- Cek Supabase Dashboard → **Table Editor** untuk memastikan tabel `assets`, `bg_mesin`, `komponen_assets` sudah ada
- Cek **Supabase Dashboard → Logs** untuk melihat detail error

### ❌ Form tidak bisa submit
**Solusi:**
- Pastikan field **Nama Asset** sudah diisi (required)
- Pastikan minimal satu **Bagian** memiliki nama

---

## 📊 Struktur Data yang Tersimpan

Ketika Anda klik "SIMPAN ASSET", data akan tersimpan di 3 tabel Supabase:

1. **Tabel `assets`**: Data utama asset
2. **Tabel `bg_mesin`**: Data bagian-bagian asset (1 asset = N bagian)
3. **Tabel `komponen_assets`**: Data komponen per bagian (1 bagian = N komponen)

**Relasi:**
```
assets (1) ──┬── bg_mesin (N) ──┬── komponen_assets (N)
             │                   │
             │                   └── komponen_assets
             │
             └── bg_mesin ──┬── komponen_assets
                            └── komponen_assets
```

---

## 📝 Tips & Best Practices

✅ **DO:**
- Gunakan kode asset yang konsisten (misal: `MES-001`, `ALT-002`)
- Isi spesifikasi komponen selengkap mungkin untuk memudahkan maintenance
- Set tanggal maintenance selanjutnya untuk reminder otomatis
- Gunakan nama bagian yang deskriptif (`Roll Atas` lebih baik dari `Bagian 1`)

❌ **DON'T:**
- Jangan biarkan nama asset kosong
- Jangan membuat bagian tanpa komponen (minimal 1 komponen per bagian)
- Jangan lupa pilih jenis asset dan status

---

## 🔄 Next Steps

Setelah asset berhasil ditambahkan:
1. ✅ Data akan muncul di halaman **Data Mesin**
2. ⏳ (TODO) Admin bisa edit/delete asset
3. ⏳ (TODO) Teknisi bisa melihat jadwal maintenance
4. ⏳ (TODO) Sistem akan kirim notifikasi H-7 sebelum maintenance

---

**Jika ada pertanyaan atau masalah, silakan cek file `SUPABASE_SETUP.md` untuk dokumentasi lengkap!**
