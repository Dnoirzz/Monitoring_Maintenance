/// Helper class untuk routing berdasarkan role user
class RouteHelper {
  /// Cek apakah role memiliki akses admin
  static bool isAdminRole(String? role) {
    if (role == null) return false;
    return role != 'Teknisi';
  }

  /// Cek apakah role adalah teknisi atau kasie teknisi
  static bool isTeknisiRole(String? role) {
    if (role == null) return false;
    return role == 'Teknisi' || role == 'KASIE Teknisi';
  }
}
