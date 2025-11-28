/// Komponen Asset Model
/// Represents the structure of the 'komponen_assets' table in Supabase
class KomponenAsset {
  final String? id;
  final String bagianId;
  final String namaKomponen;
  final String? spesifikasi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KomponenAsset({
    this.id,
    required this.bagianId,
    required this.namaKomponen,
    this.spesifikasi,
    this.createdAt,
    this.updatedAt,
  });

  factory KomponenAsset.fromJson(Map<String, dynamic> json) {
    return KomponenAsset(
      id: json['id']?.toString(),
      bagianId: json['bg_mesin_id']?.toString() ?? json['bagian_id']?.toString() ?? '',
      namaKomponen: json['nama_komponen'] as String? ?? json['nama_bagian'] as String? ?? '',
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
      'bg_mesin_id': bagianId,
      'nama_bagian': namaKomponen,
      if (spesifikasi != null) 'spesifikasi': spesifikasi,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

