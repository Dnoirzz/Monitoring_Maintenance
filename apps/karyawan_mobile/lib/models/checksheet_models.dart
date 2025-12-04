// Checksheet data models for Flutter app

class ChecksheetSchedule {
  final String id;
  final String date;
  final String? completedDate;
  final String status;
  final String machineName;
  final String machineCode;
  final String? notes;
  final int? jobItemsCount; // Count of job items in this checksheet

  ChecksheetSchedule({
    required this.id,
    required this.date,
    this.completedDate,
    required this.status,
    required this.machineName,
    required this.machineCode,
    this.notes,
    this.jobItemsCount,
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
      jobItemsCount: json['job_items_count'],
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
      'job_items_count': jobItemsCount,
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

// New models for history feature
class ChecksheetHistoryItem {
  final String id;
  final String scheduleDate;
  final String? completedDate;
  final String assetName;
  final String assetCode;
  final String? completedByName;
  final int totalItems;
  final int goodCount;
  final int repairCount;
  final int replaceCount;
  final String? notes;

  ChecksheetHistoryItem({
    required this.id,
    required this.scheduleDate,
    this.completedDate,
    required this.assetName,
    required this.assetCode,
    this.completedByName,
    required this.totalItems,
    required this.goodCount,
    required this.repairCount,
    required this.replaceCount,
    this.notes,
  });

  factory ChecksheetHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChecksheetHistoryItem(
      id: json['id'],
      scheduleDate: json['schedule_date'],
      completedDate: json['completed_date'],
      assetName: json['asset_name'] ?? 'Unknown',
      assetCode: json['asset_code'] ?? '-',
      completedByName: json['completed_by_name'],
      totalItems: json['total_items'] ?? 0,
      goodCount: json['good_count'] ?? 0,
      repairCount: json['repair_count'] ?? 0,
      replaceCount: json['replace_count'] ?? 0,
      notes: json['notes'],
    );
  }
}

class ChecksheetJobItem {
  final String id;
  final String jenisPekerjaan;
  final String stdPrwtn;
  final String alatBahan;
  final String? status;
  final String? notes;
  final String? photo;

  ChecksheetJobItem({
    required this.id,
    required this.jenisPekerjaan,
    required this.stdPrwtn,
    required this.alatBahan,
    this.status,
    this.notes,
    this.photo,
  });

  factory ChecksheetJobItem.fromJson(Map<String, dynamic> json) {
    return ChecksheetJobItem(
      id: json['id'],
      jenisPekerjaan: json['jenis_pekerjaan'] ?? '',
      stdPrwtn: json['std_prwtn'] ?? '',
      alatBahan: json['alat_bahan'] ?? '-',
      status: json['status'],
      notes: json['notes'],
      photo: json['photo'],
    );
  }
}

// Model for asset job details
class AssetJobDetail {
  final String templateId;
  final String componentName;
  final String jenisPekerjaan;
  final String stdPrwtn;
  final String alatBahan;
  final String periode;
  final int intervalPeriode;
  final String? lastChecksheetDate;
  final String? nextScheduleDate;

  AssetJobDetail({
    required this.templateId,
    required this.componentName,
    required this.jenisPekerjaan,
    required this.stdPrwtn,
    required this.alatBahan,
    required this.periode,
    required this.intervalPeriode,
    this.lastChecksheetDate,
    this.nextScheduleDate,
  });

  factory AssetJobDetail.fromJson(Map<String, dynamic> json) {
    return AssetJobDetail(
      templateId: json['template_id'],
      componentName: json['component_name'] ?? 'Unknown Component',
      jenisPekerjaan: json['jenis_pekerjaan'] ?? '',
      stdPrwtn: json['std_prwtn'] ?? '',
      alatBahan: json['alat_bahan'] ?? '-',
      periode: json['periode'] ?? '',
      intervalPeriode: json['interval_periode'] ?? 0,
      lastChecksheetDate: json['last_checksheet_date'],
      nextScheduleDate: json['next_schedule_date'],
    );
  }

  // Get formatted interval string (e.g., "Per 1 Minggu", "Per 2 Hari")
  String getIntervalString() {
    if (intervalPeriode == 0) return '-';

    String periodeText = periode;
    switch (periode.toLowerCase()) {
      case 'harian':
        periodeText = 'Hari';
        break;
      case 'mingguan':
        periodeText = 'Minggu';
        break;
      case 'bulanan':
        periodeText = 'Bulan';
        break;
      case 'tahunan':
        periodeText = 'Tahun';
        break;
    }

    return 'Per $intervalPeriode $periodeText';
  }

  // Calculate next schedule date based on last checksheet and interval
  static String? calculateNextSchedule(
    String? lastDate,
    String periode,
    int interval,
  ) {
    print(
      'calculateNextSchedule: lastDate=$lastDate, periode=$periode, interval=$interval',
    );

    if (lastDate == null) {
      print('calculateNextSchedule: lastDate is null');
      return null;
    }

    // Default interval to 1 if not set
    final effectiveInterval = interval > 0 ? interval : 1;

    try {
      final last = DateTime.parse(lastDate);
      DateTime next;

      final periodeNormalized = periode.toLowerCase().trim();
      print('calculateNextSchedule: periodeNormalized=$periodeNormalized');

      if (periodeNormalized.contains('hari') ||
          periodeNormalized == 'harian' ||
          periodeNormalized == 'daily') {
        next = last.add(Duration(days: effectiveInterval));
      } else if (periodeNormalized.contains('minggu') ||
          periodeNormalized == 'mingguan' ||
          periodeNormalized == 'weekly') {
        next = last.add(Duration(days: effectiveInterval * 7));
      } else if (periodeNormalized.contains('bulan') ||
          periodeNormalized == 'bulanan' ||
          periodeNormalized == 'monthly') {
        next = DateTime(last.year, last.month + effectiveInterval, last.day);
      } else if (periodeNormalized.contains('tahun') ||
          periodeNormalized == 'tahunan' ||
          periodeNormalized == 'yearly') {
        next = DateTime(last.year + effectiveInterval, last.month, last.day);
      } else {
        // Default to daily if periode format is unknown
        print(
          'calculateNextSchedule: Unknown periode format, defaulting to daily',
        );
        next = last.add(Duration(days: effectiveInterval));
      }

      final result =
          "${next.year}-${next.month.toString().padLeft(2, '0')}-${next.day.toString().padLeft(2, '0')}";
      print('calculateNextSchedule: result=$result');
      return result;
    } catch (e) {
      print('calculateNextSchedule: Error parsing date: $e');
      return null;
    }
  }
}

class AssetPendingSchedule {
  final String scheduleId;
  final String assetId;
  final String assetName;
  final String assetCode;
  final String scheduleDate;
  final int pendingItemsCount;

  AssetPendingSchedule({
    required this.scheduleId,
    required this.assetId,
    required this.assetName,
    required this.assetCode,
    required this.scheduleDate,
    required this.pendingItemsCount,
  });
}
