class AssetModelSupabase {
  final String? id;
  final String namaAssets;
  final String? kodeAssets;
  final String? jenisAssets;
  final String? foto;
  final String status;
  final String? mtPriority;

  AssetModelSupabase({
    this.id,
    required this.namaAssets,
    this.kodeAssets,
    this.jenisAssets,
    this.foto,
    this.status = 'Aktif',
    this.mtPriority,
  });

  Map<String, dynamic> toJson() {
    return {
      // Jangan kirim ID jika null (biar Supabase generate)
      if (id != null) 'id': id,
      'nama_assets': namaAssets,
      'kode_assets': kodeAssets,
      'jenis_assets': jenisAssets,
      'foto': foto,
      'status': status,
      'mt_priority': mtPriority,
    };
  }
}

class BagianMesinModelSupabase {
  final String? id;
  final String? assetsId;
  final String namaBagian;

  BagianMesinModelSupabase({this.id, this.assetsId, required this.namaBagian});

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'assets_id': assetsId,
      'nama_bagian': namaBagian,
    };
  }
}

class KomponenAssetModelSupabase {
  final String? id;
  final String? assetsId;
  final String? bgMesinId;
  final String namaBagian; // Di tabel komponen_assets nama kolomnya nama_bagian
  final String? spesifikasi; // Menambahkan field spesifikasi

  KomponenAssetModelSupabase({
    this.id,
    this.assetsId,
    this.bgMesinId,
    required this.namaBagian,
    this.spesifikasi,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'assets_id': assetsId,
      'bg_mesin_id': bgMesinId,
      'nama_bagian': namaBagian,
      'spesifikasi': spesifikasi, // Kirim ke database
    };
  }
}
