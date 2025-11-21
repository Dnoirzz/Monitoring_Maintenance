import '../model/asset_model.dart';

class AssetController {
  List<AssetModel> _assets = [];

  // Initialize with sample data
  void initializeSampleData() {
    _assets = [
      // Creeper 1 - Roll Atas
      AssetModel(
        namaAset: "Creeper 1",
        jenisAset: "Mesin Produksi",
        maintenanceTerakhir: "15 Januari 2024",
        maintenanceSelanjutnya: "18 Januari 2024",
        bagianAset: "Roll Atas",
        komponenAset: "Bearing",
        produkYangDigunakan: "SKF 6205",
      ),
      AssetModel(
        namaAset: "Creeper 1",
        jenisAset: "Mesin Produksi",
        maintenanceTerakhir: "15 Januari 2024",
        maintenanceSelanjutnya: "18 Januari 2024",
        bagianAset: "Roll Atas",
        komponenAset: "Seal",
        produkYangDigunakan: "Oil Seal 25x40x7",
      ),
      AssetModel(
        namaAset: "Creeper 1",
        jenisAset: "Mesin Produksi",
        maintenanceTerakhir: "15 Januari 2024",
        maintenanceSelanjutnya: "18 Januari 2024",
        bagianAset: "Roll Atas",
        komponenAset: "Shaft",
        produkYangDigunakan: "Shaft Steel 40mm",
      ),
      // Creeper 1 - Roll Bawah
      AssetModel(
        namaAset: "Creeper 1",
        jenisAset: "Mesin Produksi",
        maintenanceTerakhir: "15 Januari 2024",
        maintenanceSelanjutnya: "18 Januari 2024",
        bagianAset: "Roll Bawah",
        komponenAset: "Bearing",
        produkYangDigunakan: "SKF 6206",
      ),
      AssetModel(
        namaAset: "Creeper 1",
        jenisAset: "Mesin Produksi",
        maintenanceTerakhir: "15 Januari 2024",
        maintenanceSelanjutnya: "18 Januari 2024",
        bagianAset: "Roll Bawah",
        komponenAset: "Seal",
        produkYangDigunakan: "Oil Seal 30x45x7",
      ),
      AssetModel(
        namaAset: "Creeper 1",
        jenisAset: "Mesin Produksi",
        maintenanceTerakhir: "15 Januari 2024",
        maintenanceSelanjutnya: "18 Januari 2024",
        bagianAset: "Roll Bawah",
        komponenAset: "Shaft",
        produkYangDigunakan: "Shaft Steel 45mm",
      ),
      AssetModel(
        namaAset: "Creeper 1",
        jenisAset: "Mesin Produksi",
        maintenanceTerakhir: "15 Januari 2024",
        maintenanceSelanjutnya: "18 Januari 2024",
        bagianAset: "Roll Bawah",
        komponenAset: "Pulley",
        produkYangDigunakan: "Pulley V-Belt 8PK",
      ),
      // Excavator
      AssetModel(
        namaAset: "Excavator",
        jenisAset: "Alat Berat",
        maintenanceTerakhir: "10 Januari 2024",
        maintenanceSelanjutnya: "10 Februari 2024",
        bagianAset: "Hydraulic System",
        komponenAset: "Hydraulic Pump",
        produkYangDigunakan: "Hydraulic Oil AW46",
      ),
      AssetModel(
        namaAset: "Excavator",
        jenisAset: "Alat Berat",
        maintenanceTerakhir: "10 Januari 2024",
        maintenanceSelanjutnya: "10 Februari 2024",
        bagianAset: "Hydraulic System",
        komponenAset: "Cylinder",
        produkYangDigunakan: "Seal Kit Cylinder",
      ),
      AssetModel(
        namaAset: "Excavator",
        jenisAset: "Alat Berat",
        maintenanceTerakhir: "10 Januari 2024",
        maintenanceSelanjutnya: "10 Februari 2024",
        bagianAset: "Hydraulic System",
        komponenAset: "Hose",
        produkYangDigunakan: "Hydraulic Hose 1/2 inch",
      ),
      // Generator Set
      AssetModel(
        namaAset: "Generator Set",
        jenisAset: "Listrik",
        maintenanceTerakhir: "5 Januari 2024",
        maintenanceSelanjutnya: "5 Februari 2024",
        bagianAset: "Engine",
        komponenAset: "Alternator",
        produkYangDigunakan: "Alternator 12V 100A",
      ),
      AssetModel(
        namaAset: "Generator Set",
        jenisAset: "Listrik",
        maintenanceTerakhir: "5 Januari 2024",
        maintenanceSelanjutnya: "5 Februari 2024",
        bagianAset: "Engine",
        komponenAset: "Battery",
        produkYangDigunakan: "Battery Dry 12V 100Ah",
      ),
      AssetModel(
        namaAset: "Generator Set",
        jenisAset: "Listrik",
        maintenanceTerakhir: "5 Januari 2024",
        maintenanceSelanjutnya: "5 Februari 2024",
        bagianAset: "Engine",
        komponenAset: "Fuel System",
        produkYangDigunakan: "Fuel Filter Element",
      ),
      // Mixing Machine
      AssetModel(
        namaAset: "Mixing Machine",
        jenisAset: "Mesin Produksi",
        maintenanceTerakhir: "20 Januari 2024",
        maintenanceSelanjutnya: "20 Februari 2024",
        bagianAset: "Gearbox",
        komponenAset: "Gear",
        produkYangDigunakan: "Gear Oil EP90",
      ),
      AssetModel(
        namaAset: "Mixing Machine",
        jenisAset: "Mesin Produksi",
        maintenanceTerakhir: "20 Januari 2024",
        maintenanceSelanjutnya: "20 Februari 2024",
        bagianAset: "Gearbox",
        komponenAset: "Oli",
        produkYangDigunakan: "Gear Oil EP90 5L",
      ),
      AssetModel(
        namaAset: "Mixing Machine",
        jenisAset: "Mesin Produksi",
        maintenanceTerakhir: "20 Januari 2024",
        maintenanceSelanjutnya: "20 Februari 2024",
        bagianAset: "Gearbox",
        komponenAset: "Seal",
        produkYangDigunakan: "Oil Seal 50x70x8",
      ),
    ];
  }

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
      filtered = filtered
          .where((asset) => asset.jenisAset == jenisAset)
          .toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((asset) {
        return asset.namaAset.toLowerCase().contains(query) ||
            asset.jenisAset.toLowerCase().contains(query) ||
            asset.bagianAset.toLowerCase().contains(query) ||
            asset.komponenAset.toLowerCase().contains(query) ||
            asset.produkYangDigunakan.toLowerCase().contains(query) ||
            (asset.maintenanceTerakhir?.toLowerCase().contains(query) ?? false) ||
            (asset.maintenanceSelanjutnya?.toLowerCase().contains(query) ?? false);
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
        _assets.add(AssetModel(
          namaAset: namaAset,
          jenisAset: jenisAset,
          bagianAset: namaBagian,
          komponenAset: komponen['namaKomponen'] as String,
          produkYangDigunakan: komponen['spesifikasi'] as String,
          gambarAset: gambarPath,
        ));
      }
    }
  }

  void deleteAsset({
    required String namaAset,
    required String bagianAset,
    required String komponenAset,
  }) {
    _assets.removeWhere((asset) =>
        asset.namaAset == namaAset &&
        asset.bagianAset == bagianAset &&
        asset.komponenAset == komponenAset);
  }
}

