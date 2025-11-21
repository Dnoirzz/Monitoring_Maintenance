/// Bagian Mesin Model
/// Represents the structure of the 'bg_mesin' table in Supabase
class BagianMesin {
  final int? id;
  final int? asetId;
  final String namaBagian;
  final String? keterangan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BagianMesin({
    this.id,
    this.asetId,
    required this.namaBagian,
    this.keterangan,
    this.createdAt,
    this.updatedAt,
  });

  factory BagianMesin.fromJson(Map<String, dynamic> json) {
    return BagianMesin(
      id: json['id'] as int?,
      asetId: json['aset_id'] as int?,
      namaBagian: json['nama_bagian'] as String,
      keterangan: json['keterangan'] as String?,
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
      if (asetId != null) 'aset_id': asetId,
      'nama_bagian': namaBagian,
      if (keterangan != null) 'keterangan': keterangan,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

