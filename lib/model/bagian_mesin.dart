/// Bagian Mesin Model
/// Represents the structure of the 'bg_mesin' table in Supabase
/// Note: bg_mesin table does NOT have created_at or updated_at columns
class BagianMesin {
  final String? id;
  final String? asetId;
  final String namaBagian;
  final String? keterangan;

  BagianMesin({
    this.id,
    this.asetId,
    required this.namaBagian,
    this.keterangan,
  });

  factory BagianMesin.fromJson(Map<String, dynamic> json) {
    return BagianMesin(
      id: json['id']?.toString(),
      asetId: json['assets_id']?.toString() ?? json['aset_id']?.toString(),
      namaBagian: json['nama_bagian'] as String,
      keterangan: json['keterangan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (asetId != null) 'assets_id': asetId,
      'nama_bagian': namaBagian,
      if (keterangan != null) 'keterangan': keterangan,
    };
  }
}

