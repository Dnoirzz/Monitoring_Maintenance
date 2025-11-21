/// Asset Model
/// Represents the structure of the 'assets' table in Supabase
class Asset {
  final int? id;
  final String? kodeAset;
  final String namaAset;
  final String? jenisAset;
  final String? lokasiId;
  final String? status;
  final DateTime? maintenanceTerakhir;
  final DateTime? maintenanceSelanjutnya;
  final String? gambarAset;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Asset({
    this.id,
    this.kodeAset,
    required this.namaAset,
    this.jenisAset,
    this.lokasiId,
    this.status,
    this.maintenanceTerakhir,
    this.maintenanceSelanjutnya,
    this.gambarAset,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Asset from JSON (from Supabase)
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as int?,
      kodeAset: json['kode_aset'] as String?,
      namaAset: json['nama_aset'] as String,
      jenisAset: json['jenis_aset'] as String?,
      lokasiId: json['lokasi_id'] as String?,
      status: json['status'] as String?,
      maintenanceTerakhir:
          json['maintenance_terakhir'] != null
              ? DateTime.parse(json['maintenance_terakhir'])
              : null,
      maintenanceSelanjutnya:
          json['maintenance_selanjutnya'] != null
              ? DateTime.parse(json['maintenance_selanjutnya'])
              : null,
      gambarAset: json['gambar_aset'] as String?,
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

  /// Convert Asset to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (kodeAset != null) 'kode_aset': kodeAset,
      'nama_aset': namaAset,
      if (jenisAset != null) 'jenis_aset': jenisAset,
      if (lokasiId != null) 'lokasi_id': lokasiId,
      if (status != null) 'status': status,
      if (maintenanceTerakhir != null)
        'maintenance_terakhir': maintenanceTerakhir!.toIso8601String(),
      if (maintenanceSelanjutnya != null)
        'maintenance_selanjutnya': maintenanceSelanjutnya!.toIso8601String(),
      if (gambarAset != null) 'gambar_aset': gambarAset,
    };
  }

  Asset copyWith({
    int? id,
    String? kodeAset,
    String? namaAset,
    String? jenisAset,
    String? lokasiId,
    String? status,
    DateTime? maintenanceTerakhir,
    DateTime? maintenanceSelanjutnya,
    String? gambarAset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id ?? this.id,
      kodeAset: kodeAset ?? this.kodeAset,
      namaAset: namaAset ?? this.namaAset,
      jenisAset: jenisAset ?? this.jenisAset,
      lokasiId: lokasiId ?? this.lokasiId,
      status: status ?? this.status,
      maintenanceTerakhir: maintenanceTerakhir ?? this.maintenanceTerakhir,
      maintenanceSelanjutnya:
          maintenanceSelanjutnya ?? this.maintenanceSelanjutnya,
      gambarAset: gambarAset ?? this.gambarAset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

