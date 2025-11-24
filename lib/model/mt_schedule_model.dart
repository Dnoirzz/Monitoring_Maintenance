import 'mt_template_model.dart';

/// MT Schedule Model
/// Represents the structure of the 'mt_schedule' table in Supabase
class MtSchedule {
  final String? id; // uuid
  final String? templateId; // uuid
  final String? assetsId; // uuid (bukan aset_id)
  final DateTime? tglJadwal; // date (bukan tanggal_maintenance)
  final DateTime? tglSelesai; // date
  final String status; // enum: 'Perlu Maintenance', dll
  final String? fotoSebelum;
  final String? fotoSesudah;
  final String? catatan;
  final String? completedBy; // uuid (bukan petugas_id)
  final String? createdBy; // uuid
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined data (optional, loaded separately)
  final MtTemplate? template;
  final Map<String, dynamic>? asset; // assets table data

  MtSchedule({
    this.id,
    this.templateId,
    this.assetsId,
    this.tglJadwal,
    this.tglSelesai,
    this.status = 'Perlu Maintenance',
    this.fotoSebelum,
    this.fotoSesudah,
    this.catatan,
    this.completedBy,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.template,
    this.asset,
  });

  /// Create MtSchedule from JSON (from Supabase)
  factory MtSchedule.fromJson(Map<String, dynamic> json) {
    return MtSchedule(
      id: json['id'] as String?,
      templateId: json['template_id'] as String?,
      assetsId: json['assets_id'] as String?,
      tglJadwal: json['tgl_jadwal'] != null
          ? DateTime.parse(json['tgl_jadwal'] as String)
          : null,
      tglSelesai: json['tgl_selesai'] != null
          ? DateTime.parse(json['tgl_selesai'] as String)
          : null,
      status: json['status'] as String? ?? 'Perlu Maintenance',
      fotoSebelum: json['foto_sblm'] as String?,
      fotoSesudah: json['foto_sesudah'] as String?,
      catatan: json['catatan'] as String?,
      completedBy: json['completed_by'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      template: json['mt_template'] != null
          ? MtTemplate.fromJson(json['mt_template'] as Map<String, dynamic>)
          : null,
      asset: json['assets'] as Map<String, dynamic>?,
    );
  }

  /// Convert MtSchedule to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (assetsId != null) 'assets_id': assetsId,
      if (tglJadwal != null) 'tgl_jadwal': tglJadwal!.toIso8601String().split('T')[0],
      if (tglSelesai != null) 'tgl_selesai': tglSelesai!.toIso8601String().split('T')[0],
      'status': status,
      if (fotoSebelum != null) 'foto_sblm': fotoSebelum,
      if (fotoSesudah != null) 'foto_sesudah': fotoSesudah,
      if (catatan != null) 'catatan': catatan,
      if (completedBy != null) 'completed_by': completedBy,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  MtSchedule copyWith({
    String? id,
    String? templateId,
    String? assetsId,
    DateTime? tglJadwal,
    DateTime? tglSelesai,
    String? status,
    String? fotoSebelum,
    String? fotoSesudah,
    String? catatan,
    String? completedBy,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    MtTemplate? template,
    Map<String, dynamic>? asset,
  }) {
    return MtSchedule(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      assetsId: assetsId ?? this.assetsId,
      tglJadwal: tglJadwal ?? this.tglJadwal,
      tglSelesai: tglSelesai ?? this.tglSelesai,
      status: status ?? this.status,
      fotoSebelum: fotoSebelum ?? this.fotoSebelum,
      fotoSesudah: fotoSesudah ?? this.fotoSesudah,
      catatan: catatan ?? this.catatan,
      completedBy: completedBy ?? this.completedBy,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      template: template ?? this.template,
      asset: asset ?? this.asset,
    );
  }

  /// Get asset name from joined data
  String? get assetName {
    return asset?['nama_assets'] as String?;
  }
}
