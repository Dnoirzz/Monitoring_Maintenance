# monitoring_maintenance

🏭 Aplikasi Monitoring Maintenance Mesin Pabrik Karet
📌 Deskripsi Singkat

Aplikasi ini dibuat untuk membantu proses monitoring jadwal maintenance mesin di pabrik karet.
Dengan sistem ini, pihak teknisi dan kepala teknisi dapat memantau status mesin, mencatat kegiatan perawatan, serta menerima notifikasi otomatis H-7 sebelum jadwal maintenance berikutnya.
Tujuan utamanya adalah meminimalkan keterlambatan perawatan dan mengurangi risiko kerusakan mendadak (breakdown). Di bagian dashboard digunakan untuk menampilkan daftar mesin yang perlu dimaintenance (yang terjadwal memiliki status "perlu dimaintenance" secara otomatis mengikuti jadwal maintenance dan yang tidak terjadwal memiliki status "breakdown" yang diatur sendiri oleh teknisi dan kepala teknisi)

🚀 Fitur Utama
1. Manajemen User
a. Tiga jenis role: Teknisi, Kepala Teknisi, Admin
b. Login, autentikasi, dan hak akses berdasarkan peran

2. Data Mesin
a. Menyimpan informasi mesin, kode aset, dan status (Active, Breakdown, Perlu Maintenance)
b. Jadwal Maintenance
c. Mencatat jadwal perawatan terakhir dan berikutnya
d. Cek harian mesin yg menampilkan nama mesin, bagian mesin berupa dropdown, jenis pekerjaan text input, catatan, tanggal, bukti foto, dan nama petugas.

3. Notifikasi Otomatis
a. Mengingatkan user 7 hari sebelum tanggal maintenance berikutnya
b. Ditampilkan di halaman dashboard dan memunculkan popup dari luar aplikasi

4. Menu Riwayat
a. Menampilkan riwayat maintenance mesin berdasarkan periode waktu atau status

5. Multi-Lokasi
a. Setiap user dan mesin terhubung ke lokasi tertentu di pabrik

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
