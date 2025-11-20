import '../model/asset_model.dart';
import 'supabase_service.dart';

class AssetService {
  final _client = SupabaseService.client;

  // ============ ASSETS ============
  Future<List<AssetModel>> getAllAssets() async {
    try {
      final response = await _client.from('assets').select();
      // Debug: print format enum yang ada di database
      if (response.isNotEmpty) {
        final firstItem = Map<String, dynamic>.from(response.first);
        print('Sample asset from DB - jenis_assets: ${firstItem['jenis_assets']}');
      }
      return (response as List<dynamic>)
          .map((item) => AssetModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting assets: $e');
      return [];
    }
  }

  Future<AssetModel?> getAssetById(String id) async {
    try {
      final response = await _client.from('assets').select().eq('id', id).single();
      return AssetModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error getting asset by id: $e');
      return null;
    }
  }

  Future<AssetModel?> createAsset(AssetModel asset) async {
    final data = asset.toMap();
    try {
      // Debug: print data yang akan dikirim
      print('Creating asset with data: $data');
      final response = await _client.from('assets').insert(data).select().single();
      return AssetModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error creating asset: $e');
      return null;
    }
  }

  Future<AssetModel?> updateAsset(AssetModel asset) async {
    try {
      if (asset.id == null) return null;
      final response = await _client
          .from('assets')
          .update(asset.toMap())
          .eq('id', asset.id!)
          .select()
          .single();
      return AssetModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error updating asset: $e');
      return null;
    }
  }

  Future<bool> deleteAsset(String id) async {
    try {
      await _client.from('assets').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting asset: $e');
      return false;
    }
  }

  // ============ BG MESIN ============
  Future<List<BgMesinModel>> getBgMesinByAssetId(String assetsId) async {
    try {
      final response = await _client.from('bg_mesin').select().eq('assets_id', assetsId);
      return (response as List<dynamic>)
          .map((item) => BgMesinModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting bg_mesin: $e');
      return [];
    }
  }

  Future<BgMesinModel?> createBgMesin(BgMesinModel bgMesin) async {
    try {
      final response =
          await _client.from('bg_mesin').insert(bgMesin.toMap()).select().single();
      return BgMesinModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error creating bg_mesin: $e');
      return null;
    }
  }

  // ============ KOMPONEN ASSETS ============
  Future<List<KomponenAssetsModel>> getKomponenByAssetId(String assetsId) async {
    try {
      final response =
          await _client.from('komponen_assets').select().eq('assets_id', assetsId);
      return (response as List<dynamic>)
          .map((item) => KomponenAssetsModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting komponen_assets: $e');
      return [];
    }
  }

  Future<KomponenAssetsModel?> createKomponenAssets(KomponenAssetsModel komponen) async {
    try {
      final response = await _client
          .from('komponen_assets')
          .insert(komponen.toMap())
          .select()
          .single();
      return KomponenAssetsModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error creating komponen_assets: $e');
      return null;
    }
  }

  // ============ PRODUK ============
  Future<List<ProdukModel>> getAllProduk() async {
    try {
      final response = await _client.from('produk').select();
      return (response as List<dynamic>)
          .map((item) => ProdukModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting produk: $e');
      return [];
    }
  }

  Future<ProdukModel?> getProdukById(String id) async {
    try {
      final response = await _client.from('produk').select().eq('id', id).single();
      return ProdukModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error getting produk by id: $e');
      return null;
    }
  }

  Future<ProdukModel?> createProduk(ProdukModel produk) async {
    try {
      final response = await _client.from('produk').insert(produk.toMap()).select().single();
      return ProdukModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error creating produk: $e');
      return null;
    }
  }
}

