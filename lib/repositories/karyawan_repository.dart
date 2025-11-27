import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'user_assets_repository.dart';
import 'asset_supabase_repository.dart';

/// Repository untuk CRUD karyawan dengan integrasi user_assets
class KaryawanRepository {
  final SupabaseClient _client = SupabaseService.instance.client;
  final UserAssetsRepository _userAssetsRepo = UserAssetsRepository();
  final AssetSupabaseRepository _assetRepo = AssetSupabaseRepository();

  /// Get semua karyawan dengan assets mereka (hanya department Maintenance)
  Future<List<Map<String, dynamic>>> getAllKaryawan() async {
    try {
      final response = await _client
          .from('karyawan')
          .select('''
            *,
            user_assets (
              assets (
                id,
                nama_assets,
                kode_assets
              )
            )
          ''')
          .eq('department', 'Maintenance')
          .order('created_at', ascending: false);

      return (response as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data karyawan: $e');
    }
  }

  /// Get karyawan by ID dengan assets
  Future<Map<String, dynamic>?> getKaryawanById(String id) async {
    try {
      final response = await _client
          .from('karyawan')
          .select('''
            *,
            user_assets (
              assets (
                id,
                nama_assets,
                kode_assets
              )
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      return response as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Gagal mengambil data karyawan: $e');
    }
  }

  /// Create karyawan baru dengan assets
  Future<Map<String, dynamic>> createKaryawan({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    List<String>? assetIds, // List asset IDs untuk multi-select
    String? department,
    String? jabatan,
  }) async {
    try {
      // Simpan password plain text (tanpa hashing untuk kemudahan admin)

      // Insert karyawan
      final karyawanResponse = await _client
          .from('karyawan')
          .insert({
            'email': email,
            'password_hash': password, // Simpan password asli (plain text)
            'full_name': fullName,
            'phone': phone,
            'department': department,
            'jabatan': jabatan,
            'is_active': true,
          })
          .select()
          .single();

      final karyawanId = karyawanResponse['id'] as String;

      // Berikan akses ke aplikasi MT secara otomatis
      // Ambil ID aplikasi MT
      final aplikasiResponse = await _client
          .from('aplikasi')
          .select('id')
          .eq('kode_aplikasi', 'MT')
          .maybeSingle();

      if (aplikasiResponse != null) {
        final aplikasiMtId = aplikasiResponse['id'] as String;
        // Tentukan role berdasarkan jabatan (default: Teknisi)
        final role = jabatan ?? 'Teknisi';
        
        // Insert ke karyawan_aplikasi untuk memberikan akses MT
        await _client
            .from('karyawan_aplikasi')
            .insert({
              'karyawan_id': karyawanId,
              'aplikasi_id': aplikasiMtId,
              'role': role,
            });
      }

      // Assign assets jika ada
      if (assetIds != null && assetIds.isNotEmpty) {
        await _userAssetsRepo.updateKaryawanAssets(
          karyawanId: karyawanId,
          assetIds: assetIds,
        );
      }

      // Return karyawan dengan assets
      return await getKaryawanById(karyawanId) ?? karyawanResponse;
    } catch (e) {
      throw Exception('Gagal membuat karyawan: $e');
    }
  }

  /// Update karyawan dengan assets
  Future<Map<String, dynamic>> updateKaryawan({
    required String id,
    String? email,
    String? password,
    String? fullName,
    String? phone,
    List<String>? assetIds, // List asset IDs untuk multi-select
    String? department,
    String? jabatan,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (email != null) updateData['email'] = email;
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (department != null) updateData['department'] = department;
      if (jabatan != null) updateData['jabatan'] = jabatan;
      
      // Simpan password plain text jika ada
      if (password != null && password.isNotEmpty) {
        updateData['password_hash'] = password; // Simpan password asli (plain text)
      }

      // Update karyawan
      if (updateData.isNotEmpty) {
        await _client
            .from('karyawan')
            .update(updateData)
            .eq('id', id);
      }

      // Update assets jika ada
      if (assetIds != null) {
        await _userAssetsRepo.updateKaryawanAssets(
          karyawanId: id,
          assetIds: assetIds,
        );
      }

      // Return updated karyawan dengan assets
      return await getKaryawanById(id) ?? {};
    } catch (e) {
      throw Exception('Gagal mengupdate karyawan: $e');
    }
  }

  /// Delete karyawan (hard delete)
  Future<void> deleteKaryawan(String id) async {
    try {
      // Hard delete: hapus dari user_assets dulu (cascade)
      await _client
          .from('user_assets')
          .delete()
          .eq('karyawan_id', id);
      
      // Hapus karyawan
      await _client
          .from('karyawan')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus karyawan: $e');
    }
  }

  /// Get nama-nama assets sebagai string (untuk display di UI)
  /// Format: "Mesin 1, Mesin 2, Mesin 3"
  String getAssetNamesString(Map<String, dynamic> karyawan) {
    final userAssets = karyawan['user_assets'] as List<dynamic>? ?? [];
    if (userAssets.isEmpty) return '-';
    
    final assetNames = userAssets
        .map((ua) {
          final asset = ua['assets'] as Map<String, dynamic>?;
          return asset?['nama_assets'] as String? ?? '';
        })
        .where((name) => name.isNotEmpty)
        .toList();
    
    return assetNames.join(', ');
  }

  /// Get list asset IDs dari karyawan
  List<String> getAssetIds(Map<String, dynamic> karyawan) {
    final userAssets = karyawan['user_assets'] as List<dynamic>? ?? [];
    return userAssets
        .map((ua) {
          final asset = ua['assets'] as Map<String, dynamic>?;
          return asset?['id']?.toString() ?? '';
        })
        .where((id) => id.isNotEmpty)
        .toList();
  }

  /// Hitung total karyawan yang memiliki akses ke aplikasi sistem maintenance (MT)
  /// Hanya menghitung karyawan dengan department = 'Maintenance' agar konsisten dengan daftar karyawan
  Future<int> getTotalMaintenanceUsers() async {
    try {
      // Hitung karyawan dengan department = 'Maintenance' (konsisten dengan getAllKaryawan)
      final karyawanList = await _client
          .from('karyawan')
          .select('id')
          .eq('department', 'Maintenance');

      return karyawanList.length;
    } catch (e) {
      throw Exception('Gagal menghitung total karyawan maintenance: $e');
    }
  }
}

