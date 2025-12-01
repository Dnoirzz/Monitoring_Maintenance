# 🔧 Troubleshooting Build Error Android

## Error: "The requested operation cannot be performed on a file with a user-mapped section open"

Error ini terjadi ketika file build sedang digunakan oleh proses lain (biasanya antivirus atau file explorer).

### Solusi 1: Tutup Proses yang Menggunakan File

1. **Tutup File Explorer** yang membuka folder `android/app/build/`
2. **Tutup IDE/Editor** yang mungkin membuka file di folder build
3. **Tunggu beberapa detik** untuk memastikan file tidak lagi digunakan

### Solusi 2: Tambahkan Folder ke Exclusion Antivirus

Tambahkan folder berikut ke exclusion list Windows Defender atau antivirus Anda:

```
D:\POLNEP\Semester 5\Project Magang\Monitoring_Maintenance\apps\karyawan_mobile\android\app\build
```

**Cara menambahkan ke Windows Defender:**
1. Buka **Windows Security** → **Virus & threat protection**
2. Klik **Manage settings** di bawah "Virus & threat protection settings"
3. Scroll ke bawah ke **Exclusions**
4. Klik **Add or remove exclusions**
5. Klik **Add an exclusion** → **Folder**
6. Pilih folder `android/app/build`

### Solusi 3: Clean Build dan Coba Lagi

Jalankan perintah berikut di terminal:

```powershell
# Masuk ke folder project
cd "D:\POLNEP\Semester 5\Project Magang\Monitoring_Maintenance\apps\karyawan_mobile"

# Clean Flutter
flutter clean

# Clean Gradle
cd android
.\gradlew clean
cd ..

# Get dependencies
flutter pub get

# Coba build lagi
flutter run
```

### Solusi 4: Restart Komputer

Jika semua solusi di atas tidak berhasil, restart komputer untuk memastikan semua proses yang mem-lock file sudah ditutup.

### Solusi 5: Build dengan Flag Tambahan

Coba build dengan flag `--no-tree-shake-icons`:

```powershell
flutter build apk --debug --no-tree-shake-icons
```

Atau coba build untuk device tertentu:

```powershell
flutter build apk --debug --target-platform android-arm64
```

---

## Tips Pencegahan

1. **Jangan buka folder build di File Explorer** saat sedang build
2. **Tambahkan folder build ke .gitignore** (sudah ada)
3. **Gunakan antivirus yang tidak terlalu agresif** untuk folder development
4. **Tutup aplikasi yang tidak perlu** saat build

---

## Jika Masih Bermasalah

1. Cek apakah ada proses Java/Gradle yang masih running:
   ```powershell
   tasklist | findstr java
   tasklist | findstr gradle
   ```

2. Kill proses yang masih running:
   ```powershell
   taskkill /F /IM java.exe
   taskkill /F /IM gradle.exe
   ```

3. Coba build lagi

---

**Catatan:** Error ini adalah masalah Windows yang umum saat build Android. Biasanya akan teratasi setelah clean build atau restart komputer.


