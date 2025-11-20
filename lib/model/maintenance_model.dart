// Enums untuk Maintenance
enum Periode {
  harian,
  mingguan,
  bulanan,
  triwulan,
  semesteran,
  tahunan,
}

enum MtSchedStatus {
  perluMaintenance,
  dalamProses,
  selesai,
  ditunda,
}

// Model MtTemplate (Maintenance Template)
class MtTemplateModel {
  final String? id;
  final String? bgMesinId;
  final Periode? periode;
  final int? intervalPeriode;
  final DateTime? startDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MtTemplateModel({
    this.id,
    this.bgMesinId,
    this.periode,
    this.intervalPeriode,
    this.startDate,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "bg_mesin_id": bgMesinId,
      "periode": periode?.name,
      "interval_periode": intervalPeriode,
      "start_date": startDate?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }

  factory MtTemplateModel.fromMap(Map<String, dynamic> map) {
    return MtTemplateModel(
      id: map["id"]?.toString(),
      bgMesinId: map["bg_mesin_id"]?.toString(),
      periode: map["periode"] != null
          ? Periode.values.firstWhere(
              (e) => e.name == map["periode"],
              orElse: () => Periode.bulanan,
            )
          : null,
      intervalPeriode: map["interval_periode"],
      startDate: map["start_date"] != null
          ? DateTime.parse(map["start_date"])
          : null,
      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : null,
      updatedAt: map["updated_at"] != null
          ? DateTime.parse(map["updated_at"])
          : null,
    );
  }
}

// Model MtSchedule (Maintenance Schedule)
class MtScheduleModel {
  final String? id;
  final String? templateId;
  final String? assetsId;
  final DateTime? tglJadwal;
  final DateTime? tglSelesai;
  final MtSchedStatus? status;
  final String? fotoSblm;
  final String? fotoSesudah;
  final String? catatan;
  final String? completedBy;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MtScheduleModel({
    this.id,
    this.templateId,
    this.assetsId,
    this.tglJadwal,
    this.tglSelesai,
    this.status,
    this.fotoSblm,
    this.fotoSesudah,
    this.catatan,
    this.completedBy,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "template_id": templateId,
      "assets_id": assetsId,
      "tgl_jadwal": tglJadwal?.toIso8601String(),
      "tgl_selesai": tglSelesai?.toIso8601String(),
      "status": status?.name,
      "foto_sblm": fotoSblm,
      "foto_sesudah": fotoSesudah,
      "catatan": catatan,
      "completed_by": completedBy,
      "created_by": createdBy,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }

  factory MtScheduleModel.fromMap(Map<String, dynamic> map) {
    return MtScheduleModel(
      id: map["id"]?.toString(),
      templateId: map["template_id"]?.toString(),
      assetsId: map["assets_id"]?.toString(),
      tglJadwal: map["tgl_jadwal"] != null
          ? DateTime.parse(map["tgl_jadwal"])
          : null,
      tglSelesai: map["tgl_selesai"] != null
          ? DateTime.parse(map["tgl_selesai"])
          : null,
      status: map["status"] != null
          ? MtSchedStatus.values.firstWhere(
              (e) => e.name == map["status"],
              orElse: () => MtSchedStatus.perluMaintenance,
            )
          : null,
      fotoSblm: map["foto_sblm"],
      fotoSesudah: map["foto_sesudah"],
      catatan: map["catatan"],
      completedBy: map["completed_by"]?.toString(),
      createdBy: map["created_by"]?.toString(),
      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : null,
      updatedAt: map["updated_at"] != null
          ? DateTime.parse(map["updated_at"])
          : null,
    );
  }
}

// Model MaintenanceRequest
enum RequestType {
  breakdown,
  preventive,
  corrective,
  upgrade,
  cleaning,
}

enum ReqPriority {
  low,
  medium,
  high,
  urgent,
}

enum ReqStatus {
  pending,
  approved,
  rejected,
  inProgress,
  completed,
  cancelled,
}

class MaintenanceRequestModel {
  final String? id;
  final String? requesterId;
  final String? assetsId;
  final String? judul;
  final RequestType? requestType;
  final ReqPriority? priority;
  final String? keterangan;
  final ReqStatus? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MaintenanceRequestModel({
    this.id,
    this.requesterId,
    this.assetsId,
    this.judul,
    this.requestType,
    this.priority,
    this.keterangan,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "requester_id": requesterId,
      "assets_id": assetsId,
      "judul": judul,
      "request_type": requestType?.name,
      "priority": priority?.name,
      "keterangan": keterangan,
      "status": status?.name,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }

  factory MaintenanceRequestModel.fromMap(Map<String, dynamic> map) {
    return MaintenanceRequestModel(
      id: map["id"]?.toString(),
      requesterId: map["requester_id"]?.toString(),
      assetsId: map["assets_id"]?.toString(),
      judul: map["judul"],
      requestType: map["request_type"] != null
          ? RequestType.values.firstWhere(
              (e) => e.name == map["request_type"],
              orElse: () => RequestType.preventive,
            )
          : null,
      priority: map["priority"] != null
          ? ReqPriority.values.firstWhere(
              (e) => e.name == map["priority"],
              orElse: () => ReqPriority.medium,
            )
          : null,
      keterangan: map["keterangan"],
      status: map["status"] != null
          ? ReqStatus.values.firstWhere(
              (e) => e.name == map["status"],
              orElse: () => ReqStatus.pending,
            )
          : null,
      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : null,
      updatedAt: map["updated_at"] != null
          ? DateTime.parse(map["updated_at"])
          : null,
    );
  }
}

