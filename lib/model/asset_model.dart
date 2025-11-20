// Enums untuk Assets
enum JenisAssets {
  mesinProduksi,
  alatBerat,
  listrik,
  kendaraan,
  lainnya,
}

enum StatusAssets {
  aktif,
  tidakAktif,
  maintenance,
}

enum MtPriority {
  low,
  medium,
  high,
  urgent,
}

// Model Assets sesuai database schema
class AssetModel {
  final String? id;
  final String namaAssets;
  final String? kodeAssets;
  final JenisAssets? jenisAssets;
  final String? foto;
  final StatusAssets? status;
  final MtPriority? mtPriority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AssetModel({
    this.id,
    required this.namaAssets,
    this.kodeAssets,
    this.jenisAssets,
    this.foto,
    this.status,
    this.mtPriority,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    // Helper function to convert enum to database format
    // Database enum values: "Mesin Produksi", "Alat Berat", "Listrik" (exact match required)
    String? jenisAssetsToDb(JenisAssets? jenis) {
      if (jenis == null) return null;
      switch (jenis) {
        case JenisAssets.mesinProduksi:
          return 'Mesin Produksi'; // Exact format from database
        case JenisAssets.alatBerat:
          return 'Alat Berat'; // Exact format from database
        case JenisAssets.listrik:
          return 'Listrik'; // Exact format from database
        case JenisAssets.kendaraan:
          // Fallback ke Listrik karena kendaraan tidak ada di database
          return 'Listrik';
        case JenisAssets.lainnya:
          // Fallback ke Listrik karena lainnya tidak ada di database
          return 'Listrik';
      }
    }

    String? statusToDb(StatusAssets? status) {
      if (status == null) return null;
      switch (status) {
        case StatusAssets.aktif:
          return 'Aktif'; // Format dengan huruf kapital (sesuai database)
        case StatusAssets.tidakAktif:
          return 'Tidak Aktif'; // Format dengan huruf kapital
        case StatusAssets.maintenance:
          return 'Maintenance'; // Format dengan huruf kapital
      }
    }

    return {
      "id": id,
      "nama_assets": namaAssets,
      "kode_assets": kodeAssets,
      "jenis_assets": jenisAssetsToDb(jenisAssets),
      "foto": foto,
      "status": statusToDb(status),
      "mt_priority": mtPriority?.name,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    // Helper function to parse enum from string (database format)
    // Database enum values: "Mesin Produksi", "Alat Berat", "Listrik" (exact match)
    JenisAssets? parseJenisAssets(dynamic value) {
      if (value == null) return null;
      final str = value.toString();
      try {
        // Map database format to enum (exact match)
        if (str == 'Mesin Produksi') {
          return JenisAssets.mesinProduksi;
        } else if (str == 'Alat Berat') {
          return JenisAssets.alatBerat;
        } else if (str == 'Listrik') {
          return JenisAssets.listrik;
        } else {
          // Fallback: try case-insensitive match
          final lowerStr = str.toLowerCase();
          if (lowerStr.contains('mesin') && lowerStr.contains('produksi')) {
            return JenisAssets.mesinProduksi;
          } else if (lowerStr.contains('alat') && lowerStr.contains('berat')) {
            return JenisAssets.alatBerat;
          } else if (lowerStr.contains('listrik')) {
            return JenisAssets.listrik;
          }
          // Final fallback
          return JenisAssets.listrik;
        }
      } catch (e) {
        return JenisAssets.listrik;
      }
    }

    StatusAssets? parseStatusAssets(dynamic value) {
      if (value == null) return null;
      final str = value.toString();
      try {
        // Map database format to enum (exact match first, then case-insensitive)
        if (str == 'Aktif') {
          return StatusAssets.aktif;
        } else if (str == 'Tidak Aktif') {
          return StatusAssets.tidakAktif;
        } else if (str == 'Maintenance') {
          return StatusAssets.maintenance;
        } else {
          // Fallback: try case-insensitive match
          final lowerStr = str.toLowerCase();
          if (lowerStr == 'aktif') {
            return StatusAssets.aktif;
          } else if (lowerStr == 'tidak aktif' || lowerStr == 'tidak_aktif') {
            return StatusAssets.tidakAktif;
          } else if (lowerStr == 'maintenance') {
            return StatusAssets.maintenance;
          }
          // Final fallback
          return StatusAssets.aktif;
        }
      } catch (e) {
        return StatusAssets.aktif;
      }
    }

    MtPriority? parseMtPriority(dynamic value) {
      if (value == null) return null;
      final str = value.toString().toLowerCase();
      try {
        return MtPriority.values.firstWhere(
          (e) => e.name == str,
          orElse: () => MtPriority.medium,
        );
      } catch (e) {
        return MtPriority.medium;
      }
    }

    return AssetModel(
      id: map["id"]?.toString(),
      namaAssets: map["nama_assets"] ?? "",
      kodeAssets: map["kode_assets"],
      jenisAssets: parseJenisAssets(map["jenis_assets"]),
      foto: map["foto"],
      status: parseStatusAssets(map["status"]),
      mtPriority: parseMtPriority(map["mt_priority"]),
      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : null,
      updatedAt: map["updated_at"] != null
          ? DateTime.parse(map["updated_at"])
          : null,
    );
  }
}

// Model BgMesin (Bagian Mesin)
class BgMesinModel {
  final String? id;
  final String? assetsId;
  final String namaBagian;

  BgMesinModel({
    this.id,
    this.assetsId,
    required this.namaBagian,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "assets_id": assetsId,
      "nama_bagian": namaBagian,
    };
  }

  factory BgMesinModel.fromMap(Map<String, dynamic> map) {
    return BgMesinModel(
      id: map["id"]?.toString(),
      assetsId: map["assets_id"]?.toString(),
      namaBagian: map["nama_bagian"] ?? "",
    );
  }
}

// Model Produk
enum JenisProduk {
  bearing,
  seal,
  oli,
  sparePart,
  lainnya,
}

class ProdukModel {
  final String? id;
  final String? namaPrdk;
  final JenisProduk? jnsPrdk;
  final DateTime? createdAt;

  ProdukModel({
    this.id,
    this.namaPrdk,
    this.jnsPrdk,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nama_prdk": namaPrdk,
      "jns_prdk": jnsPrdk?.name,
      "created_at": createdAt?.toIso8601String(),
    };
  }

  factory ProdukModel.fromMap(Map<String, dynamic> map) {
    return ProdukModel(
      id: map["id"]?.toString(),
      namaPrdk: map["nama_prdk"],
      jnsPrdk: map["jns_prdk"] != null
          ? JenisProduk.values.firstWhere(
              (e) => e.name == map["jns_prdk"],
              orElse: () => JenisProduk.lainnya,
            )
          : null,
      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : null,
    );
  }
}

// Model Komponen Assets
class KomponenAssetsModel {
  final String? id;
  final String? assetsId;
  final String? bgMesinId;
  final String? namaBagian;
  final String? produkId;
  final DateTime? createdAt;

  KomponenAssetsModel({
    this.id,
    this.assetsId,
    this.bgMesinId,
    this.namaBagian,
    this.produkId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "assets_id": assetsId,
      "bg_mesin_id": bgMesinId,
      "nama_bagian": namaBagian,
      "produk_id": produkId,
      "created_at": createdAt?.toIso8601String(),
    };
  }

  factory KomponenAssetsModel.fromMap(Map<String, dynamic> map) {
    return KomponenAssetsModel(
      id: map["id"]?.toString(),
      assetsId: map["assets_id"]?.toString(),
      bgMesinId: map["bg_mesin_id"]?.toString(),
      namaBagian: map["nama_bagian"],
      produkId: map["produk_id"]?.toString(),
      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : null,
    );
  }
}
