class AssetModel {
  final String namaAset;
  final String jenisAset;
  final String? maintenanceTerakhir;
  final String? maintenanceSelanjutnya;
  final String bagianAset;
  final String komponenAset;
  final String produkYangDigunakan;
  final String? gambarAset;

  AssetModel({
    required this.namaAset,
    required this.jenisAset,
    this.maintenanceTerakhir,
    this.maintenanceSelanjutnya,
    required this.bagianAset,
    required this.komponenAset,
    required this.produkYangDigunakan,
    this.gambarAset,
  });

  Map<String, dynamic> toMap() {
    return {
      "nama_aset": namaAset,
      "jenis_aset": jenisAset,
      "maintenance_terakhir": maintenanceTerakhir,
      "maintenance_selanjutnya": maintenanceSelanjutnya,
      "bagian_aset": bagianAset,
      "komponen_aset": komponenAset,
      "produk_yang_digunakan": produkYangDigunakan,
      "gambar_aset": gambarAset,
    };
  }

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      namaAset: map["nama_aset"] ?? "",
      jenisAset: map["jenis_aset"] ?? "",
      maintenanceTerakhir: map["maintenance_terakhir"],
      maintenanceSelanjutnya: map["maintenance_selanjutnya"],
      bagianAset: map["bagian_aset"] ?? "",
      komponenAset: map["komponen_aset"] ?? "",
      produkYangDigunakan: map["produk_yang_digunakan"] ?? "",
      gambarAset: map["gambar_aset"],
    );
  }
}

