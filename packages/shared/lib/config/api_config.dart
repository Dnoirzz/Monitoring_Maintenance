import 'package:flutter/foundation.dart';
import 'dart:io';

/// API Configuration
/// Base URL untuk backend API
class ApiConfig {
  // ============================================
  // KONFIGURASI OTOMATIS (Web vs Android vs iOS)
  // ============================================

  // ============================================
  // KONFIGURASI UNTUK ANDROID DEVICE FISIK (via WiFi):
  // ============================================
  // GANTI DENGAN IP ADDRESS KOMPUTER ANDA di WiFi yang sama dengan HP
  // Cara mendapatkan IP:
  // Windows: buka CMD, ketik: ipconfig (cari IPv4 Address di WiFi adapter)
  // Mac/Linux: buka Terminal, ketik: ifconfig (cari inet)
  //
  // Contoh: '192.168.1.100'
  // Hanya digunakan jika menggunakan Android device fisik via WiFi
  // ============================================
  static const String _hostIpForPhysicalDevice =
      '192.168.83.188'; // ⚠️ GANTI INI dengan IP WiFi Anda (hanya untuk device fisik via WiFi)

  /// Port backend server
  static const int _port = 3000;

  static String get baseUrl {
    if (kIsWeb) {
      // Jika dijalankan di Web Browser -> pakai localhost
      return 'http://localhost:$_port';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Untuk Android:
      // - Emulator: gunakan 10.0.2.2 (alias khusus untuk localhost host machine)
      // - Device Fisik via USB: gunakan 10.0.2.2 atau ADB port forwarding
      // - Device Fisik via WiFi: gunakan IP komputer di network yang sama
      
      // Deteksi apakah emulator atau device fisik
      // Untuk development, default anggap emulator (10.0.2.2)
      // Jika menggunakan device fisik via WiFi, set _hostIpForPhysicalDevice
      
      // Untuk emulator Android, selalu gunakan 10.0.2.2
      // Ini adalah alias khusus yang Android emulator sediakan untuk mengakses localhost host machine
      return 'http://10.0.2.2:$_port';
      
      // Jika menggunakan device fisik via WiFi (bukan emulator):
      // Uncomment baris di bawah dan comment baris di atas:
      // return 'http://$_hostIpForPhysicalDevice:$_port';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS Simulator -> pakai localhost
      // iOS Device Fisik -> pakai IP address komputer host
      // Untuk development, default anggap simulator
      return 'http://localhost:$_port';
      
      // Jika menggunakan iOS device fisik via WiFi:
      // return 'http://$_hostIpForPhysicalDevice:$_port';
    } else {
      // Desktop / Lainnya -> pakai localhost
      return 'http://localhost:$_port';
    }
  }

  // Endpoint untuk login
  static String get loginEndpoint => '$baseUrl/api/auth/login';
}
