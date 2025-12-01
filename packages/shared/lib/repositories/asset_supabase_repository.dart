import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/asset_supabase_models.dart';
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
  /// Akan menghapus semua data terkait sebelum menghapus asset
  /// Urutan penghapusan mengikuti foreign key dependencies
  Future<void> deleteAsset(String assetId) async {
    try {
      // 1. Hapus maintenance_request yang terkait dengan asset ini (langsung ke assets)
      await _client.from('maintenance_request').delete().eq('assets_id', assetId);

      // 2. Hapus mt_schedule yang terkait dengan asset ini (langsung ke assets)
      await _client.from('mt_schedule').delete().eq('assets_id', assetId);

      // 3. Hapus user_assets yang terkait dengan asset ini (langsung ke assets)
      await _client.from('user_assets').delete().eq('assets_id', assetId);

      // 4. Ambil semua bg_mesin yang terkait untuk menghapus mt_template
      final bgMesinList = await _client
          .from('bg_mesin')
          .select('id')
          .eq('assets_id', assetId);

      // 5. Hapus mt_template yang terkait dengan bg_mesin
      for (var bgMesin in bgMesinList) {
        final bgMesinId = bgMesin['id'] as String;
        await _client
            .from('mt_template')
            .delete()
            .eq('bg_mesin_id', bgMesinId);
      }

      // 6. Ambil semua komponen_assets yang terkait untuk menghapus cek_sheet_template
      final komponenList = await _client
          .from('komponen_assets')
          .select('id')
          .eq('assets_id', assetId);

      // 7. Hapus cek_sheet_schedule dan notifikasi yang terkait dengan cek_sheet_template
      //    (notifikasi -> cek_sheet_schedule -> cek_sheet_template -> komponen_assets)
      for (var komponen in komponenList) {
        final komponenId = komponen['id'] as String;
        
        // Ambil semua cek_sheet_template yang terkait
        final cekSheetTemplateList = await _client
            .from('cek_sheet_template')
            .select('id')
            .eq('komponen_assets_id', komponenId);

        // Hapus cek_sheet_schedule dan notifikasi yang terkait dengan template
        for (var template in cekSheetTemplateList) {
          final templateId = template['id'] as String;
          
          // Ambil semua cek_sheet_schedule yang terkait dengan template
          final cekSheetScheduleList = await _client
              .from('cek_sheet_schedule')
              .select('id')
              .eq('template_id', templateId);
          
          // Hapus notifikasi yang terkait dengan cek_sheet_schedule
          for (var schedule in cekSheetScheduleList) {
            final scheduleId = schedule['id'] as String;
            await _client
                .from('notifikasi')
                .delete()
                .eq('jadwal_id', scheduleId);
          }
          
          // Hapus cek_sheet_schedule
          await _client
              .from('cek_sheet_schedule')
              .delete()
              .eq('template_id', templateId);
        }

        // Hapus cek_sheet_template
        await _client
            .from('cek_sheet_template')
            .delete()
            .eq('komponen_assets_id', komponenId);
      }

      // 8. Hapus komponen_assets
      await _client.from('komponen_assets').delete().eq('assets_id', assetId);

      // 9. Hapus bagian mesin
      await _client.from('bg_mesin').delete().eq('assets_id', assetId);

      // 10. Hapus asset (harus terakhir)
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
    String? kodeAssets,
    String? mtPriority,
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

      // 2. Update data asset (nama, jenis, foto, kode_assets, mt_priority)
      final Map<String, dynamic> updateAssetData = {
        'nama_assets': namaAssetBaru,
        'jenis_assets': jenisAsset,
      };
      if (foto != null) updateAssetData['foto'] = foto;
      // Handle kode_assets: jika null atau empty string, set ke null
      if (kodeAssets != null && kodeAssets.trim().isNotEmpty) {
        updateAssetData['kode_assets'] = kodeAssets.trim();
      } else {
        updateAssetData['kode_assets'] = null; // Set ke null jika empty
      }
      // Handle mt_priority: bisa null (optional)
      updateAssetData['mt_priority'] = mtPriority;

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
