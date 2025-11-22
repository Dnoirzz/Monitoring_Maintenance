import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/asset_supabase_models.dart';
import '../services/supabase_service.dart';

class AssetSupabaseRepository {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Insert Data Asset, Bagian Mesin, dan Komponen secara berjenjang
  Future<void> insertCompleteAsset({
    required AssetModelSupabase asset,
    required List<Map<String, dynamic>> bagianList,
  }) async {
    try {
      // 1. Insert Asset
      final assetResponse =
          await _client.from('assets').insert(asset.toJson()).select().single();

      final String assetId = assetResponse['id'];

      // 2. Loop Bagian Mesin
      for (var bagian in bagianList) {
        final String namaBagian = bagian['namaBagian'];
        final List<Map<String, dynamic>> komponenList =
            List<Map<String, dynamic>>.from(bagian['komponen']);

        // Insert Bagian Mesin
        final bagianModel = BagianMesinModelSupabase(
          assetsId: assetId,
          namaBagian: namaBagian,
        );

        final bagianResponse =
            await _client
                .from('bg_mesin')
                .insert(bagianModel.toJson())
                .select()
                .single();

        final String bagianId = bagianResponse['id'];

        // 3. Loop Komponen
        for (var komponen in komponenList) {
          final String namaKomponen = komponen['namaKomponen'];
          final String spesifikasi = komponen['spesifikasi'];

          final komponenModel = KomponenAssetModelSupabase(
            assetsId: assetId,
            bgMesinId: bagianId,
            namaBagian: namaKomponen,
            spesifikasi: spesifikasi,
          );

          await _client.from('komponen_assets').insert(komponenModel.toJson());
        }
      }
    } catch (e) {
      throw Exception('Gagal menyimpan data asset: $e');
    }
  }

  /// Mengambil semua data asset beserta bagian dan komponennya
  Future<List<Map<String, dynamic>>> getAllAssets() async {
    try {
      // Select assets, join bg_mesin, join komponen_assets
      final response = await _client.from('assets').select('''
        *,
        bg_mesin (
          *,
          komponen_assets (*)
        )
      ''');

      // Konversi ke List<Map> standar
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data asset: $e');
    }
  }

  /// Delete asset berdasarkan ID
  /// Akan otomatis menghapus bg_mesin dan komponen_assets (cascade delete)
  Future<void> deleteAsset(String assetId) async {
    try {
      // Hapus komponen terlebih dahulu
      await _client.from('komponen_assets').delete().eq('assets_id', assetId);

      // Hapus bagian mesin
      await _client.from('bg_mesin').delete().eq('assets_id', assetId);

      // Hapus asset
      await _client.from('assets').delete().eq('id', assetId);

      print('✅ Asset berhasil dihapus: $assetId');
    } catch (e) {
      print('❌ Error deleting asset: $e');
      throw Exception('Gagal menghapus asset: $e');
    }
  }

  /// Delete asset berdasarkan nama (jika tidak punya ID)
  Future<void> deleteAssetByName(String namaAsset) async {
    try {
      // Cari asset berdasarkan nama
      final assetResponse =
          await _client
              .from('assets')
              .select('id')
              .eq('nama_assets', namaAsset)
              .maybeSingle();

      if (assetResponse == null) {
        throw Exception('Asset dengan nama "$namaAsset" tidak ditemukan');
      }

      final String assetId = assetResponse['id'];
      await deleteAsset(assetId);
    } catch (e) {
      print('❌ Error deleting asset by name: $e');
      throw Exception('Gagal menghapus asset: $e');
    }
  }

  /// Update data asset (nama dan jenis)
  Future<void> updateAsset({
    required String assetId,
    String? namaAssets,
    String? jenisAssets,
    String? foto,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (namaAssets != null) updateData['nama_assets'] = namaAssets;
      if (jenisAssets != null) updateData['jenis_assets'] = jenisAssets;
      if (foto != null) updateData['foto'] = foto;

      if (updateData.isEmpty) {
        throw Exception('Tidak ada data yang diupdate');
      }

      await _client.from('assets').update(updateData).eq('id', assetId);

      print('✅ Asset berhasil diupdate: $assetId');
    } catch (e) {
      print('❌ Error updating asset: $e');
      throw Exception('Gagal mengupdate asset: $e');
    }
  }

  /// Update complete asset (asset, bagian, dan komponen)
  /// Strategi: hapus semua bagian dan komponen lama, insert yang baru
  Future<void> updateCompleteAsset({
    required String namaAssetLama,
    required String namaAssetBaru,
    required String jenisAsset,
    String? foto,
    required List<Map<String, dynamic>> bagianList,
  }) async {
    try {
      // 1. Cari asset berdasarkan nama lama
      final assetResponse =
          await _client
              .from('assets')
              .select('id')
              .eq('nama_assets', namaAssetLama)
              .maybeSingle();

      if (assetResponse == null) {
        throw Exception('Asset "$namaAssetLama" tidak ditemukan');
      }

      final String assetId = assetResponse['id'];

      // 2. Update data asset (nama, jenis, foto)
      final Map<String, dynamic> updateAssetData = {
        'nama_assets': namaAssetBaru,
        'jenis_assets': jenisAsset,
      };
      if (foto != null) updateAssetData['foto'] = foto;

      await _client.from('assets').update(updateAssetData).eq('id', assetId);

      // 3. Hapus semua komponen lama
      await _client.from('komponen_assets').delete().eq('assets_id', assetId);

      // 4. Hapus semua bagian lama
      await _client.from('bg_mesin').delete().eq('assets_id', assetId);

      // 5. Insert bagian dan komponen baru
      for (var bagian in bagianList) {
        final String namaBagian = bagian['namaBagian'];
        final List<Map<String, dynamic>> komponenList =
            List<Map<String, dynamic>>.from(bagian['komponen']);

        // Insert Bagian Mesin baru
        final bagianModel = BagianMesinModelSupabase(
          assetsId: assetId,
          namaBagian: namaBagian,
        );

        final bagianResponse =
            await _client
                .from('bg_mesin')
                .insert(bagianModel.toJson())
                .select()
                .single();

        final String bagianId = bagianResponse['id'];

        // Insert Komponen baru
        for (var komponen in komponenList) {
          final String namaKomponen = komponen['namaKomponen'];
          final String spesifikasi = komponen['spesifikasi'];

          final komponenModel = KomponenAssetModelSupabase(
            assetsId: assetId,
            bgMesinId: bagianId,
            namaBagian: namaKomponen,
            spesifikasi: spesifikasi,
          );

          await _client.from('komponen_assets').insert(komponenModel.toJson());
        }
      }

      print('✅ Asset berhasil diupdate lengkap: $assetId');
    } catch (e) {
      print('❌ Error updating complete asset: $e');
      throw Exception('Gagal mengupdate asset lengkap: $e');
    }
  }
}
