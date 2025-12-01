# 📱 Setup untuk Akses dari Device Fisik (HP)

Panduan untuk mengakses backend dari HP Android/iOS yang terhubung ke WiFi yang sama dengan komputer.

---

## 🔧 Langkah 1: Update Backend Server

Backend sudah diupdate untuk listen di `0.0.0.0` (semua network interface), jadi tidak perlu diubah lagi.

**Pastikan backend running:**
```powershell
# Jalankan start-backend.bat atau:
cd backend
node server.js
```

Backend akan listen di `0.0.0.0:3000` yang berarti bisa diakses dari device lain di network yang sama.

---

## 📍 Langkah 2: Dapatkan IP Address Komputer Anda

### Windows:
1. Buka **Command Prompt** (CMD) atau **PowerShell**
2. Ketik: `ipconfig`
3. Cari **IPv4 Address** di bagian adapter WiFi/Ethernet Anda
4. Contoh: `192.168.1.100` atau `192.168.0.50`

**Contoh output:**
```
Wireless LAN adapter Wi-Fi:
   IPv4 Address. . . . . . . . . . . : 192.168.1.100
```

### Mac:
1. Buka **Terminal**
2. Ketik: `ifconfig | grep "inet "`
3. Cari IP yang dimulai dengan `192.168.` atau `10.0.`

### Linux:
1. Buka **Terminal**
2. Ketik: `ip addr show` atau `ifconfig`
3. Cari IP di bagian `wlan0` atau `eth0`

---

## ⚙️ Langkah 3: Update Konfigurasi API di Aplikasi

Buka file: `packages/shared/lib/config/api_config.dart`

Cari baris ini:
```dart
static const String localNetworkIp = '192.168.1.100'; // ⚠️ GANTI INI!
```

**Ganti dengan IP komputer Anda**, contoh:
```dart
static const String localNetworkIp = '192.168.1.100'; // IP komputer Anda
```

**PENTING:** 
- Jangan tambahkan `http://` di depan IP
- Hanya IP address saja, contoh: `'192.168.1.100'`
- Pastikan HP dan komputer terhubung ke **WiFi yang sama**

---

## ✅ Langkah 4: Test Koneksi

### Test dari Browser HP:
1. Pastikan HP terhubung ke WiFi yang sama dengan komputer
2. Buka browser di HP
3. Akses: `http://<IP_KOMPUTER>:3000/api/health`
   - Contoh: `http://192.168.1.100:3000/api/health`
4. Harusnya muncul JSON response:
   ```json
   {
     "status": "OK",
     "message": "Backend API is running",
     "timestamp": "..."
   }
   ```

### Test dari Aplikasi:
1. Restart aplikasi Flutter (hot restart tidak cukup, perlu full restart)
2. Coba login
3. Jika masih error, cek:
   - IP address sudah benar di `api_config.dart`
   - Backend sedang running
   - HP dan komputer di WiFi yang sama
   - Firewall tidak memblokir port 3000

---

## 🔥 Langkah 5: Buka Firewall (Jika Perlu)

Jika masih tidak bisa akses, mungkin firewall memblokir port 3000.

### Windows:
1. Buka **Windows Defender Firewall**
2. Klik **Advanced settings**
3. Klik **Inbound Rules** → **New Rule**
4. Pilih **Port** → **Next**
5. Pilih **TCP** → **Specific local ports**: `3000` → **Next**
6. Pilih **Allow the connection** → **Next**
7. Centang semua (Domain, Private, Public) → **Next**
8. Nama: "Backend API Port 3000" → **Finish**

Atau via PowerShell (Run as Administrator):
```powershell
New-NetFirewallRule -DisplayName "Backend API Port 3000" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

---

## 🐛 Troubleshooting

### Error: "Tidak ada koneksi internet atau server tidak dapat dijangkau"

**Kemungkinan penyebab:**
1. ❌ IP address salah di `api_config.dart`
2. ❌ HP dan komputer tidak di WiFi yang sama
3. ❌ Backend tidak running
4. ❌ Firewall memblokir port 3000
5. ❌ IP komputer berubah (dynamic IP)

**Solusi:**
1. ✅ Cek IP komputer lagi: `ipconfig` (Windows) atau `ifconfig` (Mac/Linux)
2. ✅ Pastikan HP dan komputer di WiFi yang sama
3. ✅ Pastikan backend running: `node server.js` di folder `backend/`
4. ✅ Test dari browser HP: `http://<IP>:3000/api/health`
5. ✅ Buka firewall untuk port 3000
6. ✅ Restart aplikasi Flutter (bukan hot reload)

### IP Address Berubah Setiap Kali

Jika IP komputer berubah setiap kali restart (dynamic IP), ada beberapa solusi:

**Opsi 1: Set Static IP (Recommended)**
- Set IP static di router atau di Windows Network Settings
- Lihat panduan: https://www.windowscentral.com/how-set-static-ip-address-windows-10

**Opsi 2: Gunakan Hostname (Advanced)**
- Install mDNS/Bonjour di komputer
- Gunakan hostname seperti `http://your-computer-name.local:3000`
- Perlu konfigurasi tambahan

**Opsi 3: Update IP Setiap Kali**
- Setiap kali IP berubah, update di `api_config.dart`
- Restart aplikasi

---

## 📝 Catatan Penting

1. **WiFi yang Sama**: HP dan komputer HARUS di WiFi yang sama
2. **IP Address**: IP bisa berubah jika menggunakan dynamic IP
3. **Firewall**: Pastikan firewall tidak memblokir port 3000
4. **Backend Running**: Pastikan backend selalu running saat test
5. **Hot Restart**: Perlu full restart aplikasi, bukan hot reload

---

## 🚀 Quick Checklist

- [ ] Backend running di `0.0.0.0:3000`
- [ ] Dapatkan IP komputer dengan `ipconfig` (Windows) atau `ifconfig` (Mac/Linux)
- [ ] Update `localNetworkIp` di `packages/shared/lib/config/api_config.dart`
- [ ] HP dan komputer di WiFi yang sama
- [ ] Test dari browser HP: `http://<IP>:3000/api/health`
- [ ] Buka firewall untuk port 3000 (jika perlu)
- [ ] Restart aplikasi Flutter
- [ ] Coba login dari aplikasi

---

**Selamat! Sekarang aplikasi bisa diakses dari HP Anda! 🎉**

