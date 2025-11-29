class CekSheetSchedule {
  final String? id;
  final String? templateId;
  final DateTime? tglJadwal;
  final DateTime? tglSelesai;
  final String? fotoSblm;
  final String? fotoSesudah;
  final String? catatan;
  final String? completedBy;
  final DateTime? createdAt;

  // Joined data
  final Map<String, dynamic>? template;

  CekSheetSchedule({
    this.id,
    this.templateId,
    this.tglJadwal,
    this.tglSelesai,
    this.fotoSblm,
    this.fotoSesudah,
    this.catatan,
    this.completedBy,
    this.createdAt,
    this.template,
  });

  factory CekSheetSchedule.fromJson(Map<String, dynamic> json) {
    return CekSheetSchedule(
      id: json['id'] as String?,
      templateId: json['template_id'] as String?,
      tglJadwal:
          json['tgl_jadwal'] != null
              ? DateTime.parse(json['tgl_jadwal'] as String)
              : null,
      tglSelesai:
          json['tgl_selesai'] != null
              ? DateTime.parse(json['tgl_selesai'] as String)
              : null,
      fotoSblm: json['foto_sblm'] as String?,
      fotoSesudah: json['foto_sesudah'] as String?,
      catatan: json['catatan'] as String?,
      completedBy: json['completed_by'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      template: json['cek_sheet_template'] as Map<String, dynamic>?,
    );
  }

  // Helper to get title/description from template
  String? get title {
    return template?['jenis_pekerjaan'] as String? ?? 'Check Sheet Task';
  }
}
