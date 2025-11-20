import 'maintenance_model.dart'; // Untuk enum Periode

// Model CekSheetTemplate
class CekSheetTemplateModel {
  final String? id;
  final String? komponenAssetsId;
  final Periode? periode;
  final String? jenisPekerjaan;
  final String? stdPrwtn;
  final String? alatBahan;
  final int? intervalPeriode;
  final DateTime? createdAt;

  CekSheetTemplateModel({
    this.id,
    this.komponenAssetsId,
    this.periode,
    this.jenisPekerjaan,
    this.stdPrwtn,
    this.alatBahan,
    this.intervalPeriode,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "komponen_assets_id": komponenAssetsId,
      "periode": periode?.name,
      "jenis_pekerjaan": jenisPekerjaan,
      "std_prwtn": stdPrwtn,
      "alat_bahan": alatBahan,
      "interval_periode": intervalPeriode,
      "created_at": createdAt?.toIso8601String(),
    };
  }

  factory CekSheetTemplateModel.fromMap(Map<String, dynamic> map) {
    return CekSheetTemplateModel(
      id: map["id"]?.toString(),
      komponenAssetsId: map["komponen_assets_id"]?.toString(),
      periode: map["periode"] != null
          ? Periode.values.firstWhere(
              (e) => e.name == map["periode"],
              orElse: () => Periode.bulanan,
            )
          : null,
      jenisPekerjaan: map["jenis_pekerjaan"],
      stdPrwtn: map["std_prwtn"],
      alatBahan: map["alat_bahan"],
      intervalPeriode: map["interval_periode"],
      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : null,
    );
  }
}

// Model CekSheetSchedule
class CekSheetScheduleModel {
  final String? id;
  final String? templateId;
  final DateTime? tglJadwal;
  final DateTime? tglSelesai;
  final String? fotoSblm;
  final String? fotoSesudah;
  final String? catatan;
  final DateTime? createdAt;
  final String? completedBy;

  CekSheetScheduleModel({
    this.id,
    this.templateId,
    this.tglJadwal,
    this.tglSelesai,
    this.fotoSblm,
    this.fotoSesudah,
    this.catatan,
    this.createdAt,
    this.completedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "template_id": templateId,
      "tgl_jadwal": tglJadwal?.toIso8601String(),
      "tgl_selesai": tglSelesai?.toIso8601String(),
      "foto_sblm": fotoSblm,
      "foto_sesudah": fotoSesudah,
      "catatan": catatan,
      "created_at": createdAt?.toIso8601String(),
      "completed_by": completedBy,
    };
  }

  factory CekSheetScheduleModel.fromMap(Map<String, dynamic> map) {
    return CekSheetScheduleModel(
      id: map["id"]?.toString(),
      templateId: map["template_id"]?.toString(),
      tglJadwal: map["tgl_jadwal"] != null
          ? DateTime.parse(map["tgl_jadwal"])
          : null,
      tglSelesai: map["tgl_selesai"] != null
          ? DateTime.parse(map["tgl_selesai"])
          : null,
      fotoSblm: map["foto_sblm"],
      fotoSesudah: map["foto_sesudah"],
      catatan: map["catatan"],
      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : null,
      completedBy: map["completed_by"]?.toString(),
    );
  }
}

