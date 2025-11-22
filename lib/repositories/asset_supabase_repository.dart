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
}
