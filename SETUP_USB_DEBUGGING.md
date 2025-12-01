# 📱 Setup USB Debugging dengan ADB Port Forwarding

Panduan untuk mengakses backend dari HP Android melalui USB debugging **TANPA perlu WiFi yang sama**.

---

## ✅ Keuntungan Menggunakan ADB Port Forwarding

1. ✅ **Tidak perlu WiFi yang sama** - HP dan komputer bisa di network berbeda
2. ✅ **Lebih stabil** - Koneksi melalui USB lebih reliable
3. ✅ **Lebih mudah** - Tidak perlu cari IP address
4. ✅ **Lebih aman** - Koneksi langsung melalui USB

---

## 🔧 Langkah 1: Pastikan USB Debugging Aktif

1. Di HP Android, buka **Settings** → **About phone**
2. Tap **Build number** 7 kali sampai muncul "You are now a developer"
3. Kembali ke **Settings** → **Developer options**
4. Aktifkan **USB debugging**
5. Hubungkan HP ke komputer via USB
6. Di HP, akan muncul popup "Allow USB debugging?" → Pilih **Allow**

---

## 🔧 Langkah 2: Setup ADB Port Forwarding

### Windows:

1. Buka **Command Prompt** (CMD) atau **PowerShell**
2. Pastikan ADB sudah terinstall (biasanya sudah ada jika sudah install Android Studio)
3. Jalankan perintah:

```cmd
adb reverse tcp:3000 tcp:3000
```

**Penjelasan:**
- `adb reverse` = forward port dari HP ke komputer
- `tcp:3000` = port di HP
- `tcp:3000` = port di komputer (backend)

4. Cek apakah berhasil:
```cmd
adb reverse --list
```

Harusnya muncul:
```
tcp:3000 tcp:3000
```

### Mac/Linux:

```bash
adb reverse tcp:3000 tcp:3000
```

---

## ⚙️ Langkah 3: Update Konfigurasi Aplikasi

Buka file: `packages/shared/lib/config/api_config.dart`

Pastikan konfigurasi seperti ini:

```dart
// Set true untuk USB debugging dengan ADB port forwarding
static const bool useAdbPortForwarding = true;
```

Jika sudah `true`, aplikasi akan otomatis menggunakan `localhost:3000` yang sudah di-forward oleh ADB.

---

## 🚀 Langkah 4: Jalankan Backend

Jalankan backend seperti biasa:

```powershell
# Double-click start-backend.bat atau:
cd backend
node server.js
```

Backend akan running di `localhost:3000` (atau `0.0.0.0:3000`).

---

## ✅ Langkah 5: Test

1. Pastikan:
   - ✅ HP terhubung via USB
   - ✅ USB debugging aktif
   - ✅ ADB port forwarding sudah dijalankan (`adb reverse tcp:3000 tcp:3000`)
   - ✅ Backend running
   - ✅ `useAdbPortForwarding = true` di `api_config.dart`

2. Jalankan aplikasi Flutter:
   ```powershell
   flutter run
   ```

3. Coba login dari aplikasi

---

## 🔄 Setiap Kali Menggunakan USB Debugging

**PENTING:** ADB port forwarding perlu dijalankan **setiap kali**:
- HP di-reconnect ke USB
- Komputer di-restart
- ADB daemon di-restart

Jalankan lagi:
```cmd
adb reverse tcp:3000 tcp:3000
```

**Tips:** Buat file batch untuk memudahkan:

**`setup-adb-port-forward.bat`** (buat di root project):
```batch
@echo off
echo Setting up ADB port forwarding...
adb reverse tcp:3000 tcp:3000
adb reverse --list
echo.
echo Done! Port forwarding aktif.
echo.
pause
```

Double-click file ini setiap kali sebelum run aplikasi.

---

## 🐛 Troubleshooting

### Error: "adb: command not found"

**Solusi:**
1. Install Android Studio (ADB termasuk di dalamnya)
2. Atau install Android SDK Platform Tools:
   - Download: https://developer.android.com/studio/releases/platform-tools
   - Extract dan tambahkan ke PATH

### Error: "device not found" atau "no devices/emulators found"

**Solusi:**
1. Pastikan HP terhubung via USB
2. Pastikan USB debugging aktif
3. Cek dengan: `adb devices`
4. Jika tidak muncul, install USB driver untuk HP Anda

### Error: "address already in use"

**Solusi:**
Port forwarding sudah aktif. Cek dengan:
```cmd
adb reverse --list
```

Jika sudah ada, tidak perlu jalankan lagi.

### Port Forwarding Hilang Setelah Reconnect

**Solusi:**
Ini normal. Jalankan lagi:
```cmd
adb reverse tcp:3000 tcp:3000
```

Atau buat script batch untuk otomatis (lihat di atas).

---

## 📊 Perbandingan: USB vs WiFi

| Fitur | USB Debugging (ADB) | WiFi |
|-------|---------------------|------|
| Perlu WiFi sama? | ❌ Tidak | ✅ Ya |
| Perlu cari IP? | ❌ Tidak | ✅ Ya |
| Stabilitas | ✅ Lebih stabil | ⚠️ Tergantung WiFi |
| Setup | ⚠️ Perlu ADB | ✅ Lebih mudah |
| Reconnect | ⚠️ Perlu setup ulang | ✅ Otomatis |

---

## 💡 Tips

1. **Buat script batch** untuk setup ADB port forwarding (lihat contoh di atas)
2. **Cek status** dengan `adb reverse --list`
3. **Gunakan WiFi** jika sering disconnect USB
4. **Gunakan USB** jika WiFi tidak stabil atau berbeda network

---

## ✅ Quick Checklist

- [ ] USB debugging aktif di HP
- [ ] HP terhubung via USB
- [ ] Jalankan: `adb reverse tcp:3000 tcp:3000`
- [ ] Cek: `adb reverse --list` (harus muncul `tcp:3000`)
- [ ] Set `useAdbPortForwarding = true` di `api_config.dart`
- [ ] Backend running
- [ ] Run aplikasi Flutter
- [ ] Test login

---

**Selamat! Sekarang aplikasi bisa diakses dari HP via USB tanpa perlu WiFi yang sama! 🎉**

