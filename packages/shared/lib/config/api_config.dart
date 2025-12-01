import 'package:flutter/foundation.dart';

/// API Configuration
/// Base URL untuk backend API
class ApiConfig {
  // ============================================
  // KONFIGURASI OTOMATIS (Web vs Android vs iOS)
  // ============================================

  // ============================================
  // PILIHAN KONFIGURASI:
  // ============================================
  // Opsi 1: USB Debugging dengan ADB Port Forwarding (MUDAH!)
  //   - Tidak perlu WiFi yang sama
  //   - Gunakan 'localhost' atau '127.0.0.1'
  //   - Jalankan: adb reverse tcp:3000 tcp:3000
  //
  // Opsi 2: WiFi (Perlu WiFi yang sama)
  //   - HP dan komputer harus di WiFi yang sama
  //   - Gunakan IP komputer (dapatkan dengan: ipconfig / ifconfig)
  //   - Contoh: '192.168.1.100'
  // ============================================

  // Untuk USB Debugging dengan ADB Port Forwarding:
  // Set ke true jika menggunakan ADB reverse port forwarding
  // Jalankan: adb reverse tcp:3000 tcp:3000
  static const bool useAdbPortForwarding =
      false; // ⚠️ Set false untuk menggunakan WiFi

  // Untuk WiFi (jika useAdbPortForwarding = false):
  // GANTI DENGAN IP ADDRESS KOMPUTER ANDA di WiFi yang sama dengan HP
  // Cara mendapatkan IP:
  // Windows: buka CMD, ketik: ipconfig (cari IPv4 Address di WiFi adapter)
  // Mac/Linux: buka Terminal, ketik: ifconfig (cari inet)
  //
  // IP yang terdeteksi di komputer Anda:
  // - 192.168.83.188 (kemungkinan WiFi utama)
  // - 192.168.56.1 (VirtualBox, abaikan)
  // - 10.5.0.2 (VPN/network lain, abaikan)
  //
  // Gunakan IP WiFi yang sama dengan HP Anda!
  static const String localNetworkIp =
      '192.168.83.188'; // ⚠️ GANTI INI dengan IP WiFi Anda!

  static String get baseUrl {
    if (kIsWeb) {
      // Jika dijalankan di Web Browser -> pakai localhost
      return 'http://localhost:3000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Untuk Android:
      if (useAdbPortForwarding) {
        // Opsi 1: USB Debugging dengan ADB Port Forwarding
        // ADB akan forward port 3000 dari HP ke komputer
        // HP akan mengakses localhost:3000 yang di-forward ke komputer
        return 'http://localhost:3000';
      } else {
        // Opsi 2: WiFi (HP dan komputer di network yang sama)
        // Gunakan IP komputer di network yang sama
        return 'http://$localNetworkIp:3000';
      }
    } else {
      // iOS / Desktop / Lainnya -> pakai localhost
      return 'http://localhost:3000';
    }
  }

  // Endpoint untuk login
  static String get loginEndpoint => '$baseUrl/api/auth/login';
}
