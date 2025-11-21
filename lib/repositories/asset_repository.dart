import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/asset.dart';
import '../models/bagian_mesin.dart';
import '../models/komponen_asset.dart';
import '../services/supabase_service.dart';

/// Asset Repository
/// Handles all database operations related to assets, bagian_mesin, and komponen_assets
class AssetRepository {
  final SupabaseClient _client = SupabaseService.instance.client;

  // ==================== ASSETS OPERATIONS ====================

  /// Get all assets
  Future<List<Asset>> getAllAssets() async {
    try {
      final response = await _client
          .from('assets')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Asset.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch assets: $e');
    }
  }

  /// Get asset by ID
  Future<Asset?> getAssetById(int id) async {
    try {
      final response =
          await _client.from('assets').select().eq('id', id).single();

      return Asset.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch asset: $e');
    }
  }

  /// Create new asset
  Future<Asset> createAsset(Asset asset) async {
    try {
      final response =
          await _client.from('assets').insert(asset.toJson()).select().single();

      return Asset.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create asset: $e');
    }
  }

  /// Update existing asset
  Future<Asset> updateAsset(int id, Asset asset) async {
    try {
      final response =
          await _client
              .from('assets')
              .update(asset.toJson())
              .eq('id', id)
              .select()
              .single();

      return Asset.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update asset: $e');
    }
  }

  /// Delete asset
  Future<void> deleteAsset(int id) async {
    try {
      await _client.from('assets').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete asset: $e');
    }
  }

  // ==================== BAGIAN MESIN OPERATIONS ====================

  /// Get all bagian mesin for a specific asset
  Future<List<BagianMesin>> getBagianByAssetId(int assetId) async {
    try {
      final response = await _client
          .from('bg_mesin')
          .select()
          .eq('aset_id', assetId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => BagianMesin.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bagian mesin: $e');
    }
  }

  /// Create new bagian mesin
  Future<BagianMesin> createBagianMesin(BagianMesin bagian) async {
    try {
      final response =
          await _client
              .from('bg_mesin')
              .insert(bagian.toJson())
              .select()
              .single();

      return BagianMesin.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create bagian mesin: $e');
    }
  }

  /// Update bagian mesin
  Future<BagianMesin> updateBagianMesin(int id, BagianMesin bagian) async {
    try {
      final response =
          await _client
              .from('bg_mesin')
              .update(bagian.toJson())
              .eq('id', id)
              .select()
              .single();

      return BagianMesin.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update bagian mesin: $e');
    }
  }

  /// Delete bagian mesin
  Future<void> deleteBagianMesin(int id) async {
    try {
      await _client.from('bg_mesin').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete bagian mesin: $e');
    }
  }

  // ==================== KOMPONEN ASSETS OPERATIONS ====================

  /// Get all komponen for a specific bagian
  Future<List<KomponenAsset>> getKomponenByBagianId(int bagianId) async {
    try {
      final response = await _client
          .from('komponen_assets')
          .select()
          .eq('bagian_id', bagianId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => KomponenAsset.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch komponen assets: $e');
    }
  }

  /// Create new komponen asset
  Future<KomponenAsset> createKomponenAsset(KomponenAsset komponen) async {
    try {
      final response =
          await _client
              .from('komponen_assets')
              .insert(komponen.toJson())
              .select()
              .single();

      return KomponenAsset.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create komponen asset: $e');
    }
  }

  /// Update komponen asset
  Future<KomponenAsset> updateKomponenAsset(
    int id,
    KomponenAsset komponen,
  ) async {
    try {
      final response =
          await _client
              .from('komponen_assets')
              .update(komponen.toJson())
              .eq('id', id)
              .select()
              .single();

      return KomponenAsset.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update komponen asset: $e');
    }
  }

  /// Delete komponen asset
  Future<void> deleteKomponenAsset(int id) async {
    try {
      await _client.from('komponen_assets').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete komponen asset: $e');
    }
  }

  // ==================== COMPLEX OPERATIONS ====================

  /// Create asset with bagian and komponen in a single transaction-like operation
  Future<Map<String, dynamic>> createAssetComplete({
    required Asset asset,
    required List<Map<String, dynamic>>
    bagianList, // {namaBagian, komponen: [{namaKomponen, spesifikasi}]}
  }) async {
    try {
      // Step 1: Create asset
      final createdAsset = await createAsset(asset);
      final assetId = createdAsset.id!;

      List<BagianMesin> createdBagianList = [];
      Map<int, List<KomponenAsset>> komponenMap = {};

      // Step 2: Create bagian mesin for this asset
      for (var bagianData in bagianList) {
        final bagian = BagianMesin(
          asetId: assetId,
          namaBagian: bagianData['namaBagian'] as String,
          keterangan: bagianData['keterangan'] as String?,
        );

        final createdBagian = await createBagianMesin(bagian);
        createdBagianList.add(createdBagian);

        final bagianId = createdBagian.id!;
        komponenMap[bagianId] = [];

        // Step 3: Create komponen for this bagian
        final komponenList =
            bagianData['komponen'] as List<Map<String, dynamic>>? ?? [];
        for (var komponenData in komponenList) {
          final komponen = KomponenAsset(
            bagianId: bagianId,
            namaKomponen: komponenData['namaKomponen'] as String,
            spesifikasi: komponenData['spesifikasi'] as String?,
          );

          final createdKomponen = await createKomponenAsset(komponen);
          komponenMap[bagianId]!.add(createdKomponen);
        }
      }

      return {
        'asset': createdAsset,
        'bagian_list': createdBagianList,
        'komponen_map': komponenMap,
      };
    } catch (e) {
      throw Exception('Failed to create complete asset: $e');
    }
  }

  /// Get asset with all bagian and komponen (nested structure)
  Future<Map<String, dynamic>> getAssetComplete(int assetId) async {
    try {
      final asset = await getAssetById(assetId);
      if (asset == null) {
        throw Exception('Asset not found');
      }

      final bagianList = await getBagianByAssetId(assetId);

      Map<int, List<KomponenAsset>> komponenMap = {};
      for (var bagian in bagianList) {
        final komponenList = await getKomponenByBagianId(bagian.id!);
        komponenMap[bagian.id!] = komponenList;
      }

      return {
        'asset': asset,
        'bagian_list': bagianList,
        'komponen_map': komponenMap,
      };
    } catch (e) {
      throw Exception('Failed to fetch complete asset: $e');
    }
  }
}
