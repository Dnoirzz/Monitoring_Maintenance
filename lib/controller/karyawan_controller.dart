import '../repositories/karyawan_repository.dart';
import '../repositories/asset_supabase_repository.dart';

class KaryawanController {
  final KaryawanRepository _repository = KaryawanRepository();
  final AssetSupabaseRepository _assetRepo = AssetSupabaseRepository();
  
  List<Map<String, dynamic>> _karyawan = [];
  bool _isLoading = false;

  /// Load semua karyawan dari Supabase
  Future<void> loadKaryawan() async {
    try {
      _isLoading = true;
      _karyawan = await _repository.getAllKaryawan();
      print('✅ Loaded ${_karyawan.length} karyawan from Supabase');
    } catch (e) {
      print('❌ Error loading karyawan: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Get semua karyawan (untuk kompatibilitas dengan UI)
  List<Map<String, String>> getAllKaryawan() {
    return _karyawan.map((k) {
      // Convert ke format yang diharapkan UI
      return {
        "id": k['id']?.toString() ?? '',
        "nama": k['full_name'] as String? ?? '',
        "mesin": _repository.getAssetNamesString(k), // Multi mesin dipisah koma
        "telp": k['phone'] as String? ?? '',
        "email": k['email'] as String? ?? '',
        "password": k['password_hash'] as String? ?? '', // Password hash ditampilkan
        "department": k['department'] as String? ?? '-',
        "jabatan": k['jabatan'] as String? ?? '-',
      };
    }).toList();
  }

  /// Filter karyawan
  List<Map<String, String>> filterKaryawan({
    String? mesin,
    String? searchQuery,
  }) {
    List<Map<String, String>> filtered = getAllKaryawan();

    // Filter by mesin
    if (mesin != null && mesin.isNotEmpty) {
      filtered = filtered.where((k) {
        final mesinStr = k["mesin"] ?? '';
        return mesinStr.contains(mesin);
      }).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((k) {
        return (k["nama"] ?? '').toLowerCase().contains(query) ||
            (k["mesin"] ?? '').toLowerCase().contains(query) ||
            (k["telp"] ?? '').toLowerCase().contains(query) ||
            (k["email"] ?? '').toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  /// Get list mesin untuk filter (dari semua assets)
  Future<List<String>> getMesinList() async {
    try {
      final assets = await _assetRepo.getAllAssets();
      return assets
          .map((asset) => asset['nama_assets'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList()
        ..sort();
    } catch (e) {
      print('Error getting mesin list: $e');
      return [];
    }
  }

  /// Get semua assets untuk dropdown
  Future<List<Map<String, dynamic>>> getAllAssets() async {
    try {
      return await _assetRepo.getAllAssets();
    } catch (e) {
      print('Error getting assets: $e');
      return [];
    }
  }

  /// Create karyawan baru
  Future<void> createKaryawan({
    required String nama,
    required String email,
    required String password,
    required String telp,
    required List<String> assetIds, // Multi-select asset IDs
    String? department,
    String? jabatan,
  }) async {
    try {
      await _repository.createKaryawan(
        email: email,
        password: password,
        fullName: nama,
        phone: telp,
        assetIds: assetIds,
        department: department,
        jabatan: jabatan,
      );
      
      // Reload data
      await loadKaryawan();
    } catch (e) {
      print('Error creating karyawan: $e');
      rethrow;
    }
  }

  /// Update karyawan
  Future<void> updateKaryawan({
    required String id,
    String? nama,
    String? email,
    String? password,
    String? telp,
    List<String>? assetIds, // Multi-select asset IDs
    String? department,
    String? jabatan,
  }) async {
    try {
      await _repository.updateKaryawan(
        id: id,
        email: email,
        password: password,
        fullName: nama,
        phone: telp,
        assetIds: assetIds,
        department: department,
        jabatan: jabatan,
      );
      
      // Reload data
      await loadKaryawan();
    } catch (e) {
      print('Error updating karyawan: $e');
      rethrow;
    }
  }

  /// Delete karyawan
  Future<void> deleteKaryawan(String id) async {
    try {
      await _repository.deleteKaryawan(id);
      
      // Reload data
      await loadKaryawan();
    } catch (e) {
      print('Error deleting karyawan: $e');
      rethrow;
    }
  }

  /// Get asset IDs dari karyawan
  List<String> getAssetIds(Map<String, dynamic> karyawan) {
    return _repository.getAssetIds(karyawan);
  }

  /// Get karyawan data dengan assets by ID
  Future<Map<String, dynamic>?> getKaryawanWithAssets(String id) async {
    try {
      return await _repository.getKaryawanById(id);
    } catch (e) {
      print('Error getting karyawan with assets: $e');
      return null;
    }
  }

  bool get isLoading => _isLoading;
}
