import '../model/karyawan_model.dart';
import '../service/karyawan_service.dart';

class KaryawanController {
  final KaryawanService _karyawanService = KaryawanService();
  List<KaryawanModel> _karyawan = [];

  // Load data from Supabase
  Future<void> loadKaryawan() async {
    _karyawan = await _karyawanService.getAllKaryawan();
  }

  // Initialize with data from Supabase
  Future<void> initialize() async {
    await loadKaryawan();
  }

  // Initialize with sample data (for backward compatibility)
  void initializeSampleData() {
    _karyawan = [
      KaryawanModel(
        email: "ramadhan@example.com",
        passwordHash: "hashed_password_1",
        fullName: "Ramadhan F",
        phone: "08123456789",
        jabatan: "Teknisi",
        department: "Maintenance",
        isActive: true,
      ),
      KaryawanModel(
        email: "adityo@example.com",
        passwordHash: "hashed_password_2",
        fullName: "Adityo Saputro",
        phone: "087812345678",
        jabatan: "Teknisi",
        department: "Maintenance",
        isActive: true,
      ),
      KaryawanModel(
        email: "rama@example.com",
        passwordHash: "hashed_password_3",
        fullName: "Rama Wijaya",
        phone: "085312345678",
        jabatan: "Supervisor",
        department: "Maintenance",
        isActive: true,
      ),
    ];
  }

  List<KaryawanModel> getAllKaryawan() {
    return List.unmodifiable(_karyawan);
  }

  KaryawanModel? getKaryawanById(String id) {
    try {
      return _karyawan.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }

  KaryawanModel? getKaryawanByEmail(String email) {
    try {
      return _karyawan.firstWhere((k) => k.email == email);
    } catch (e) {
      return null;
    }
  }

  List<KaryawanModel> filterKaryawan({
    String? mesin,
    String? searchQuery,
    String? department,
    String? jabatan,
  }) {
    List<KaryawanModel> filtered = List.from(_karyawan);

    // Filter by department
    if (department != null && department.isNotEmpty) {
      filtered = filtered.where((k) => k.department == department).toList();
    }

    // Filter by jabatan
    if (jabatan != null && jabatan.isNotEmpty) {
      filtered = filtered.where((k) => k.jabatan == jabatan).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((k) {
        return (k.fullName?.toLowerCase().contains(query) ?? false) ||
            k.email.toLowerCase().contains(query) ||
            (k.phone?.toLowerCase().contains(query) ?? false) ||
            (k.department?.toLowerCase().contains(query) ?? false) ||
            (k.jabatan?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  List<String> getMesinList() {
    // This would need to be connected to user_assets table
    // For now, return empty list or sample data
    return [];
  }

  List<String> getDepartmentList() {
    Set<String> deptSet = {};
    for (var karyawan in _karyawan) {
      if (karyawan.department != null) {
        deptSet.add(karyawan.department!);
      }
    }
    return deptSet.toList()..sort();
  }

  List<String> getJabatanList() {
    Set<String> jabatanSet = {};
    for (var karyawan in _karyawan) {
      if (karyawan.jabatan != null) {
        jabatanSet.add(karyawan.jabatan!);
      }
    }
    return jabatanSet.toList()..sort();
  }

  Future<void> addKaryawan(KaryawanModel karyawan) async {
    final created = await _karyawanService.createKaryawan(karyawan);
    if (created != null) {
      _karyawan.add(created);
    }
  }

  Future<void> updateKaryawan(KaryawanModel karyawan) async {
    final updated = await _karyawanService.updateKaryawan(karyawan);
    if (updated != null) {
      final index = _karyawan.indexWhere((k) => k.id == karyawan.id);
      if (index != -1) {
        _karyawan[index] = updated;
      }
    }
  }

  Future<void> deleteKaryawan(String idOrEmail) async {
    // Try to find by ID first, then by email
    KaryawanModel? karyawan = _karyawan
        .where((k) => k.id == idOrEmail || k.email == idOrEmail)
        .firstOrNull;

    if (karyawan == null) return;
    
    final karyawanId = karyawan.id;
    if (karyawanId != null) {
      final success = await _karyawanService.deleteKaryawan(karyawanId);
      if (success) {
        _karyawan.removeWhere((k) => k.id == karyawanId || k.email == idOrEmail);
      }
    }
  }

  Future<bool> authenticate(String email, String password) async {
    final karyawan = await _karyawanService.getKaryawanByEmail(email);
    if (karyawan == null) return false;
    
    // In real implementation, you would hash the password and compare
    // For now, just check if password is not empty
    return password.isNotEmpty;
  }
}
