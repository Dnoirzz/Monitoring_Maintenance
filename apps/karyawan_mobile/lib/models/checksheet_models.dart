// Checksheet data models for Flutter app

class ChecksheetSchedule {
  final String id;
  final String date;
  final String? completedDate;
  final String status;
  final String machineName;
  final String machineCode;
  final String? notes;

  ChecksheetSchedule({
    required this.id,
    required this.date,
    this.completedDate,
    required this.status,
    required this.machineName,
    required this.machineCode,
    this.notes,
  });

  factory ChecksheetSchedule.fromJson(Map<String, dynamic> json) {
    return ChecksheetSchedule(
      id: json['id'],
      date: json['date'],
      completedDate: json['completed_date'],
      status: json['status'],
      machineName: json['machine_name'] ?? 'Unknown',
      machineCode: json['machine_code'] ?? '-',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'completed_date': completedDate,
      'status': status,
      'machine_name': machineName,
      'machine_code': machineCode,
      'notes': notes,
    };
  }
}

class ChecksheetScheduleDetail {
  final ScheduleInfo schedule;
  final List<ChecksheetTemplate> templates;

  ChecksheetScheduleDetail({required this.schedule, required this.templates});

  factory ChecksheetScheduleDetail.fromJson(Map<String, dynamic> json) {
    return ChecksheetScheduleDetail(
      schedule: ScheduleInfo.fromJson(json['schedule']),
      templates:
          (json['templates'] as List)
              .map((e) => ChecksheetTemplate.fromJson(e))
              .toList(),
    );
  }
}

class ScheduleInfo {
  final String id;
  final String tglJadwal;
  final String? tglSelesai;
  final String catatan;
  final String assetName;
  final String assetCode;

  ScheduleInfo({
    required this.id,
    required this.tglJadwal,
    this.tglSelesai,
    required this.catatan,
    required this.assetName,
    required this.assetCode,
  });

  factory ScheduleInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleInfo(
      id: json['id'],
      tglJadwal: json['tgl_jadwal'],
      tglSelesai: json['tgl_selesai'],
      catatan: json['catatan'] ?? '',
      assetName: json['asset_name'] ?? 'Unknown',
      assetCode: json['asset_code'] ?? '-',
    );
  }
}

class ChecksheetTemplate {
  final String id;
  final String jenisPekerjaan;
  final String stdPrwtn;
  final String alatBahan;
  String? status; // 'good', 'repair', 'replace', or null
  String? notes;
  String? photo;

  ChecksheetTemplate({
    required this.id,
    required this.jenisPekerjaan,
    required this.stdPrwtn,
    required this.alatBahan,
    this.status,
    this.notes,
    this.photo,
  });

  factory ChecksheetTemplate.fromJson(Map<String, dynamic> json) {
    return ChecksheetTemplate(
      id: json['id'],
      jenisPekerjaan: json['jenis_pekerjaan'] ?? '',
      stdPrwtn: json['std_prwtn'] ?? '',
      alatBahan: json['alat_bahan'] ?? '-',
      status: json['status'],
      notes: json['notes'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template_id': id,
      'status': status,
      'notes': notes,
      'photo': photo,
    };
  }
}

class ChecksheetSubmitRequest {
  final String scheduleId;
  final List<ChecksheetTemplate> results;
  final String generalNotes;

  ChecksheetSubmitRequest({
    required this.scheduleId,
    required this.results,
    required this.generalNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'schedule_id': scheduleId,
      'results': results.map((r) => r.toJson()).toList(),
      'general_notes': generalNotes,
    };
  }
}
