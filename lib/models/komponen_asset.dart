/// Komponen Asset Model
/// Represents the structure of the 'komponen_assets' table in Supabase
class KomponenAsset {
  final int? id;
  final int? bagianId;
  final String namaKomponen;
  final String? spesifikasi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KomponenAsset({
    this.id,
    this.bagianId,
    required this.namaKomponen,
    this.spesifikasi,
    this.createdAt,
    this.updatedAt,
  });

  factory KomponenAsset.fromJson(Map<String, dynamic> json) {
    return KomponenAsset(
      id: json['id'] as int?,
      bagianId: json['bagian_id'] as int?,
      namaKomponen: json['nama_komponen'] as String,
      spesifikasi: json['spesifikasi'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (bagianId != null) 'bagian_id': bagianId,
      'nama_komponen': namaKomponen,
      if (spesifikasi != null) 'spesifikasi': spesifikasi,
    };
  }
}
