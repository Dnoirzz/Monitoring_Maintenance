import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// Repository untuk mengelola relasi karyawan dengan assets (mesin)
class UserAssetsRepository {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Update assets yang di-assign ke karyawan (replace semua)
  Future<void> updateKaryawanAssets({
    required String karyawanId,
    required List<String> assetIds,
  }) async {
    try {
      // Hapus semua relasi lama
      await _client
          .from('user_assets')
          .delete()
          .eq('karyawan_id', karyawanId);

      // Insert relasi baru
      if (assetIds.isNotEmpty) {
        final now = DateTime.now().toIso8601String();
        final inserts = assetIds.map((assetId) => {
          'karyawan_id': karyawanId,
          'assets_id': assetId,
          'assigned_at': now,
        }).toList();

        await _client.from('user_assets').insert(inserts);
      }
    } catch (e) {
      throw Exception('Gagal update assets karyawan: $e');
    }
  }

  /// Get nama-nama assets sebagai string (untuk display)
  Future<List<String>> getAssetNamesByKaryawanId(String karyawanId) async {
    try {
      final response = await _client
          .from('user_assets')
          .select('''
            assets (
              nama_assets
            )
          ''')
          .eq('karyawan_id', karyawanId);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) {
            final asset = item['assets'] as Map<String, dynamic>?;
            return asset?['nama_assets'] as String? ?? '';
          })
          .where((name) => name.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil nama assets: $e');
    }
  }
}

