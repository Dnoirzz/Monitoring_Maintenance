import 'package:flutter/foundation.dart';

/// API Configuration
/// Base URL untuk backend API
class ApiConfig {
  // ============================================
  // KONFIGURASI OTOMATIS (Web vs Android vs iOS)
  // ============================================

  static String get baseUrl {
    if (kIsWeb) {
      // Jika dijalankan di Web Browser -> pakai localhost
      return 'http://localhost:3000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Jika dijalankan di Android Emulator -> pakai 10.0.2.2
      return 'http://10.0.2.2:3000';
    } else {
      // iOS / Desktop / Lainnya -> pakai localhost
      return 'http://localhost:3000';
    }
  }

  // Endpoint untuk login
  static String get loginEndpoint => '$baseUrl/api/auth/login';
}
