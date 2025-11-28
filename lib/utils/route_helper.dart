import 'package:flutter/material.dart';
import 'package:monitoring_maintenance/screen/admin/dashboard_admin.dart';
import 'package:monitoring_maintenance/screen/teknisi/dashboard_page.dart';

/// Helper class untuk routing berdasarkan role user
class RouteHelper {
  /// Dapatkan dashboard widget berdasarkan role user
  /// 
  /// Role yang mengakses Admin Dashboard:
  /// - Superadmin
  /// - Manajer
  /// - Admin
  /// - KASIE Teknisi
  /// 
  /// Role yang mengakses Teknisi Dashboard:
  /// - Teknisi
  /// 
  /// Default: AdminTemplate jika role null atau tidak dikenal
  static Widget getDashboardByRole(String? role) {
    // Jika role adalah "Teknisi", redirect ke dashboard teknisi
    if (role == 'Teknisi') {
      return const TeknisiDashboardPage();
    }
    
    // Untuk role lain (Superadmin, Manajer, Admin, KASIE Teknisi), 
    // atau jika role null (fallback), redirect ke dashboard admin
    return const AdminTemplate();
  }

  /// Cek apakah role memiliki akses admin
  static bool isAdminRole(String? role) {
    return role != null && role != 'Teknisi';
  }

  /// Cek apakah role adalah teknisi
  static bool isTeknisiRole(String? role) {
    return role == 'Teknisi';
  }
}

