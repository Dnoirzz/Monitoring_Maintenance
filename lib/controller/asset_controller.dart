import '../model/asset_model.dart';
import '../service/asset_service.dart';

class AssetController {
  final AssetService _assetService = AssetService();
  List<AssetModel> _assets = [];
  List<BgMesinModel> _bgMesin = [];
  List<KomponenAssetsModel> _komponenAssets = [];
  List<ProdukModel> _produk = [];

  // Load data from Supabase
  Future<void> loadAssets() async {
    _assets = await _assetService.getAllAssets();
  }

  Future<void> loadBgMesin() async {
    // Load bg_mesin for all assets
    for (var asset in _assets) {
      if (asset.id != null) {
        final bgMesinList = await _assetService.getBgMesinByAssetId(asset.id!);
        _bgMesin.addAll(bgMesinList);
      }
    }
  }

  Future<void> loadKomponenAssets() async {
    // Load komponen_assets for all assets
    for (var asset in _assets) {
      if (asset.id != null) {
        final komponenList = await _assetService.getKomponenByAssetId(asset.id!);
        _komponenAssets.addAll(komponenList);
      }
    }
  }

  Future<void> loadProduk() async {
    _produk = await _assetService.getAllProduk();
  }

  // Initialize with data from Supabase
  Future<void> initialize() async {
    await loadAssets();
    await loadBgMesin();
    await loadKomponenAssets();
    await loadProduk();
  }

  // Initialize with sample data (for backward compatibility)
  void initializeSampleData() {
    // Keep this for fallback, but prefer using initialize() instead
    _assets = [
      AssetModel(
        namaAssets: "Creeper 1",
        jenisAssets: JenisAssets.mesinProduksi,
        status: StatusAssets.aktif,
        foto: null,
      ),
      AssetModel(
        namaAssets: "Excavator",
        jenisAssets: JenisAssets.alatBerat,
        status: StatusAssets.aktif,
        foto: null,
      ),
      AssetModel(
        namaAssets: "Generator Set",
        jenisAssets: JenisAssets.listrik,
        status: StatusAssets.aktif,
        foto: null,
      ),
      AssetModel(
        namaAssets: "Mixing Machine",
        jenisAssets: JenisAssets.mesinProduksi,
        status: StatusAssets.aktif,
        foto: null,
      ),
    ];
  }

  // ============ ASSETS METHODS ============
  List<AssetModel> getAllAssets() {
    return List.unmodifiable(_assets);
  }

  AssetModel? getAssetById(String id) {
    try {
      return _assets.firstWhere((asset) => asset.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addAsset(AssetModel asset) async {
    final created = await _assetService.createAsset(asset);
    if (created != null) {
      _assets.add(created);
    }
  }

  Future<void> updateAsset(AssetModel asset) async {
    final updated = await _assetService.updateAsset(asset);
    if (updated != null) {
      final index = _assets.indexWhere((a) => a.id == asset.id);
      if (index != -1) {
        _assets[index] = updated;
      }
    }
  }

  Future<void> deleteAsset(String id) async {
    final success = await _assetService.deleteAsset(id);
    if (success) {
      _assets.removeWhere((asset) => asset.id == id);
      // Also delete related bg_mesin and komponen_assets
      _bgMesin.removeWhere((bg) => bg.assetsId == id);
      _komponenAssets.removeWhere((ka) => ka.assetsId == id);
    }
  }

  // ============ FILTER & SEARCH METHODS ============
  List<AssetModel> filterAssets({
    String? jenisAset,
    String? searchQuery,
    String? sortColumn,
    bool sortAscending = true,
  }) {
    List<AssetModel> filtered = List.from(_assets);

    // Filter by jenis aset
    if (jenisAset != null && jenisAset.isNotEmpty) {
      final enumName = _parseJenisAsetName(jenisAset);
      filtered = filtered.where((asset) {
        if (asset.jenisAssets == null) return false;
        return asset.jenisAssets!.name == enumName;
      }).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((asset) {
        return asset.namaAssets.toLowerCase().contains(query) ||
            (asset.kodeAssets?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort
    if (sortColumn != null) {
      filtered.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (sortColumn) {
          case "nama_aset":
            aValue = a.namaAssets;
            bValue = b.namaAssets;
            break;
          case "jenis_aset":
            aValue = a.jenisAssets?.name ?? "";
            bValue = b.jenisAssets?.name ?? "";
            break;
          default:
            return 0;
        }

        int comparison = aValue.toString().compareTo(bValue.toString());
        return sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  List<String> getJenisAsetList() {
    Set<String> jenisSet = {};
    for (var asset in _assets) {
      if (asset.jenisAssets != null) {
        jenisSet.add(_formatJenisAsetName(asset.jenisAssets!.name));
      }
    }
    return jenisSet.toList()..sort();
  }

  String _formatJenisAsetName(String enumName) {
    // Convert enum name to readable format
    // Database hanya memiliki 3 jenis: mesin_produksi, alat_berat, listrik
    switch (enumName) {
      case 'mesinproduksi':
      case 'mesin_produksi':
        return 'Mesin Produksi';
      case 'alatberat':
      case 'alat_berat':
        return 'Alat Berat';
      case 'listrik':
        return 'Listrik';
      default:
        return 'Listrik'; // Fallback ke Listrik
    }
  }

  String _parseJenisAsetName(String displayName) {
    // Convert display name back to enum name
    // Database hanya memiliki 3 jenis: mesin_produksi, alat_berat, listrik
    switch (displayName) {
      case 'Mesin Produksi':
        return 'mesinproduksi';
      case 'Alat Berat':
        return 'alatberat';
      case 'Listrik':
        return 'listrik';
      default:
        return 'listrik'; // Fallback ke listrik
    }
  }

  // ============ BACKWARD COMPATIBILITY METHODS ============
  // Method untuk kompatibilitas dengan UI yang ada
  // Menggabungkan data dari Assets, BgMesin, KomponenAssets, dan Produk
  Map<String, List<Map<String, dynamic>>> groupByAset(List<AssetModel> assets) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (var asset in assets) {
      String namaAset = asset.namaAssets;
      if (!grouped.containsKey(namaAset)) {
        grouped[namaAset] = [];
      }

      // Get all komponen for this asset
      List<KomponenAssetsModel> komponenList = _komponenAssets
          .where((ka) => ka.assetsId == asset.id)
          .toList();

      if (komponenList.isEmpty) {
        // If no komponen, add asset info only
        grouped[namaAset]!.add({
          "nama_aset": asset.namaAssets,
          "jenis_aset": asset.jenisAssets?.name ?? "",
          "maintenance_terakhir": null,
          "maintenance_selanjutnya": null,
          "bagian_aset": "",
          "komponen_aset": "",
          "produk_yang_digunakan": "",
          "gambar_aset": asset.foto,
        });
      } else {
        for (var komponen in komponenList) {
          BgMesinModel? bgMesin = _bgMesin.firstWhere(
            (bg) => bg.id == komponen.bgMesinId,
            orElse: () => BgMesinModel(namaBagian: komponen.namaBagian ?? ""),
          );
          ProdukModel? produk = _produk.firstWhere(
            (p) => p.id == komponen.produkId,
            orElse: () => ProdukModel(namaPrdk: ""),
          );

          grouped[namaAset]!.add({
            "nama_aset": asset.namaAssets,
            "jenis_aset": asset.jenisAssets?.name ?? "",
            "maintenance_terakhir": null,
            "maintenance_selanjutnya": null,
            "bagian_aset": bgMesin.namaBagian,
            "komponen_aset": komponen.namaBagian ?? "",
            "produk_yang_digunakan": produk.namaPrdk ?? "",
            "gambar_aset": asset.foto,
          });
        }
      }
    }
    
    return grouped;
  }

  Map<String, List<Map<String, dynamic>>> groupByBagian(List<Map<String, dynamic>> items) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in items) {
      String bagian = item["bagian_aset"] ?? "";
      if (!grouped.containsKey(bagian)) {
        grouped[bagian] = [];
      }
      grouped[bagian]!.add(item);
    }
    return grouped;
  }

  // Method untuk menambah asset dari form (backward compatibility)
  Future<String?> addAssetsFromForm({
    required String namaAset,
    required String jenisAset,
    required List<Map<String, dynamic>> bagianAsetList,
    String? gambarPath,
  }) async {
    try {
      // Convert jenisAset string to enum menggunakan helper method
      final enumName = _parseJenisAsetName(jenisAset);
      JenisAssets? jenisAssetsEnum;
      try {
        jenisAssetsEnum = JenisAssets.values.firstWhere(
          (e) => e.name == enumName,
          orElse: () => JenisAssets.lainnya,
        );
      } catch (e) {
        jenisAssetsEnum = JenisAssets.lainnya;
      }

      // Create new asset
      final newAsset = AssetModel(
        namaAssets: namaAset.trim(),
        jenisAssets: jenisAssetsEnum,
        foto: gambarPath,
        status: StatusAssets.aktif,
      );
      
      final created = await _assetService.createAsset(newAsset);
      if (created == null) {
        return 'Gagal membuat asset. Silakan coba lagi.';
      }

      _assets.add(created);

      // Create bg_mesin and komponen_assets
      for (var bagian in bagianAsetList) {
        String namaBagian = (bagian['namaBagian'] as String?)?.trim() ?? '';
        
        if (namaBagian.isEmpty) continue;
        
        // Create BgMesin
        final bgMesin = BgMesinModel(
          assetsId: created.id,
          namaBagian: namaBagian,
        );
        final createdBgMesin = await _assetService.createBgMesin(bgMesin);
        if (createdBgMesin == null) {
          print('Warning: Gagal membuat bg_mesin untuk bagian: $namaBagian');
          continue;
        }
        
        _bgMesin.add(createdBgMesin);

        List<Map<String, dynamic>> komponenList =
            bagian['komponen'] as List<Map<String, dynamic>>? ?? [];
        
        for (var komponen in komponenList) {
          String namaKomponen = (komponen['namaKomponen'] as String?)?.trim() ?? '';
          String spesifikasi = (komponen['spesifikasi'] as String?)?.trim() ?? '';

          if (namaKomponen.isEmpty || spesifikasi.isEmpty) continue;

          // Create or find Produk
          ProdukModel? produk;
          try {
            produk = _produk.firstWhere(
              (p) => p.namaPrdk?.toLowerCase() == spesifikasi.toLowerCase(),
            );
          } catch (e) {
            // Produk tidak ditemukan, buat baru
            produk = ProdukModel(
              namaPrdk: spesifikasi,
              jnsPrdk: JenisProduk.lainnya,
            );
          }

          // If produk doesn't have ID, create it in database
          if (produk.id == null) {
            final createdProduk = await _assetService.createProduk(produk);
            if (createdProduk != null) {
              final produkNama = produk.namaPrdk;
              final index = _produk.indexWhere((p) => p.namaPrdk == produkNama);
              if (index != -1) {
                _produk[index] = createdProduk;
              } else {
                _produk.add(createdProduk);
              }
              produk = createdProduk;
            } else {
              print('Warning: Gagal membuat produk: $spesifikasi');
              continue;
            }
          }

          // Create KomponenAssets
          final komponenAssets = KomponenAssetsModel(
            assetsId: created.id,
            bgMesinId: createdBgMesin.id,
            namaBagian: namaKomponen,
            produkId: produk.id,
          );
          final createdKomponen = await _assetService.createKomponenAssets(komponenAssets);
          if (createdKomponen != null) {
            _komponenAssets.add(createdKomponen);
          } else {
            print('Warning: Gagal membuat komponen_assets: $namaKomponen');
          }
        }
      }

      return null; // Success
    } catch (e) {
      print('Error in addAssetsFromForm: $e');
      return 'Terjadi kesalahan: ${e.toString()}';
    }
  }

  // ============ BG MESIN METHODS ============
  List<BgMesinModel> getBgMesinByAssetId(String assetsId) {
    return _bgMesin.where((bg) => bg.assetsId == assetsId).toList();
  }

  // ============ KOMPONEN ASSETS METHODS ============
  List<KomponenAssetsModel> getKomponenByAssetId(String assetsId) {
    return _komponenAssets.where((ka) => ka.assetsId == assetsId).toList();
  }

  // ============ PRODUK METHODS ============
  List<ProdukModel> getAllProduk() {
    return List.unmodifiable(_produk);
  }

  ProdukModel? getProdukById(String id) {
    try {
      return _produk.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
