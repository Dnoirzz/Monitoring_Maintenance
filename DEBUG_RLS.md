# 🐛 Debugging "User Tidak Ditemukan"

Backend melaporkan "User tidak ditemukan" padahal user ada di database.

**Penyebab Kemungkinan:**
Row Level Security (RLS) di Supabase aktif dan memblokir akses baca menggunakan `ANON_KEY`.

## 🛠️ Langkah Perbaikan

### 1. Update `server.js` (Sudah dilakukan)
Saya sudah update server untuk menampilkan detail error dan list user lain jika user target tidak ditemukan.

**Restart backend Anda sekarang:**
1. Tekan Ctrl+C di terminal backend
2. Jalankan `start-backend.bat` lagi

### 2. Cek Log Backend
Coba login lagi dari Flutter app. Lihat output di terminal backend.

**Jika muncul "Users in DB: []" (Kosong)**
Berarti RLS memblokir akses. Anda punya 2 pilihan:

**Pilihan A: Matikan RLS (Paling Cepat)**
1. Buka Supabase Dashboard → Table Editor
2. Buka tabel `karyawan`
3. Klik "RLS" di toolbar atas
4. Matikan "Enable Row Level Security"
5. Lakukan hal yang sama untuk tabel `karyawan_aplikasi` dan `aplikasi`

**Pilihan B: Gunakan Service Role Key (Lebih Aman)**
1. Buka Supabase Dashboard → Project Settings → API
2. Copy `service_role` key (secret)
3. Update `backend/.env`:
   Ganti `SUPABASE_ANON_KEY` dengan service role key yang baru dicopy.
4. Restart backend.

## 🚀 Rekomendasi
Coba **Pilihan A (Matikan RLS)** dulu untuk memastikan koneksi dan logika benar. Nanti bisa diaktifkan lagi dengan policy yang benar.


