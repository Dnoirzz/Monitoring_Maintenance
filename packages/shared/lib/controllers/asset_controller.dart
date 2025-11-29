import '../models/asset_model.dart';

class AssetController {
  List<AssetModel> _assets = [];

  List<AssetModel> getAllAssets() {
    return List.unmodifiable(_assets);
  }

  List<AssetModel> filterAssets({
    String? jenisAset,
    String? searchQuery,
    String? sortColumn,
    bool sortAscending = true,
  }) {
    List<AssetModel> filtered = List.from(_assets);

    // Filter by jenis aset
    if (jenisAset != null && jenisAset.isNotEmpty) {
      filtered =
          filtered.where((asset) => asset.jenisAset == jenisAset).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered =
          filtered.where((asset) {
            return asset.namaAset.toLowerCase().contains(query) ||
                asset.jenisAset.toLowerCase().contains(query) ||
                asset.bagianAset.toLowerCase().contains(query) ||
                asset.komponenAset.toLowerCase().contains(query) ||
                asset.produkYangDigunakan.toLowerCase().contains(query) ||
                (asset.maintenanceTerakhir?.toLowerCase().contains(query) ??
                    false) ||
                (asset.maintenanceSelanjutnya?.toLowerCase().contains(query) ??
                    false);
          }).toList();
    }

    // Sort
    if (sortColumn != null) {
      filtered.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (sortColumn) {
          case "nama_aset":
            aValue = a.namaAset;
            bValue = b.namaAset;
            break;
          case "jenis_aset":
            aValue = a.jenisAset;
            bValue = b.jenisAset;
            break;
          case "maintenance_terakhir":
            aValue = a.maintenanceTerakhir ?? "";
            bValue = b.maintenanceTerakhir ?? "";
            break;
          case "maintenance_selanjutnya":
            aValue = a.maintenanceSelanjutnya ?? "";
            bValue = b.maintenanceSelanjutnya ?? "";
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
      jenisSet.add(asset.jenisAset);
    }
    return jenisSet.toList()..sort();
  }

  Map<String, List<AssetModel>> groupByAset(List<AssetModel> assets) {
    Map<String, List<AssetModel>> grouped = {};
    for (var asset in assets) {
      if (!grouped.containsKey(asset.namaAset)) {
        grouped[asset.namaAset] = [];
      }
      grouped[asset.namaAset]!.add(asset);
    }
    return grouped;
  }

  Map<String, List<AssetModel>> groupByBagian(List<AssetModel> assets) {
    Map<String, List<AssetModel>> grouped = {};
    for (var asset in assets) {
      if (!grouped.containsKey(asset.bagianAset)) {
        grouped[asset.bagianAset] = [];
      }
      grouped[asset.bagianAset]!.add(asset);
    }
    return grouped;
  }

  void addAsset(AssetModel asset) {
    _assets.add(asset);
  }

  void addAssetsFromForm({
    required String namaAset,
    required String jenisAset,
    required List<Map<String, dynamic>> bagianAsetList,
    String? gambarPath,
  }) {
    for (var bagian in bagianAsetList) {
      String namaBagian = bagian['namaBagian'] as String;
      List<Map<String, dynamic>> komponenList =
          bagian['komponen'] as List<Map<String, dynamic>>;
      for (var komponen in komponenList) {
        _assets.add(
          AssetModel(
            namaAset: namaAset,
            jenisAset: jenisAset,
            bagianAset: namaBagian,
            komponenAset: komponen['namaKomponen'] as String,
            produkYangDigunakan: komponen['spesifikasi'] as String,
            gambarAset: gambarPath,
          ),
        );
      }
    }
  }

  void deleteAsset({
    required String namaAset,
    required String bagianAset,
    required String komponenAset,
  }) {
    _assets.removeWhere(
      (asset) =>
          asset.namaAset == namaAset &&
          asset.bagianAset == bagianAset &&
          asset.komponenAset == komponenAset,
    );
  }
}
