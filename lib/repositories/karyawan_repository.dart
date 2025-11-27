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
  /// Hanya menghitung karyawan yang aktif (is_active = true)
  Future<int> getTotalMaintenanceUsers() async {
    try {
      // Ambil ID aplikasi MT terlebih dahulu
      final aplikasiResponse = await _client
          .from('aplikasi')
          .select('id')
          .eq('kode_aplikasi', 'MT')
          .maybeSingle();

      if (aplikasiResponse == null) {
        // Jika aplikasi MT tidak ditemukan, return 0
        return 0;
      }

      final aplikasiMtId = aplikasiResponse['id'] as String;

      // Query semua karyawan yang aktif dengan akses aplikasi mereka
      final karyawanList = await _client
          .from('karyawan')
          .select('''
            id,
            is_active,
            karyawan_aplikasi(
              aplikasi_id,
              aplikasi:aplikasi_id(
                kode_aplikasi
              )
            )
          ''')
          .eq('is_active', true);

      // Filter dan hitung yang punya akses ke aplikasi MT
      int count = 0;
      for (var karyawan in karyawanList) {
        final isActive = karyawan['is_active'] as bool? ?? false;
        if (!isActive) continue;

        final karyawanAplikasi = karyawan['karyawan_aplikasi'] as List<dynamic>? ?? [];
        final hasMTAccess = karyawanAplikasi.any((ka) {
          final aplikasi = ka['aplikasi'] as Map<String, dynamic>?;
          final kodeAplikasi = aplikasi?['kode_aplikasi'] as String?;
          final aplikasiId = ka['aplikasi_id'] as String?;
          // Cek apakah aplikasi_id sama dengan MT atau kode_aplikasi adalah MT
          return aplikasiId == aplikasiMtId || kodeAplikasi == 'MT';
        });

        if (hasMTAccess) {
          count++;
        }
      }

      return count;
    } catch (e) {
      throw Exception('Gagal menghitung total karyawan maintenance: $e');
    }
  }
}

