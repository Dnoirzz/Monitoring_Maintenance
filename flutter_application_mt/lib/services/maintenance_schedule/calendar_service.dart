import 'package:monitoring_maintenance/model/mt_schedule_model.dart';

/// Service untuk kalkulasi dan logika calendar maintenance schedule
class CalendarService {
  /// Group schedules by asset dan bagian mesin
  static Map<String, Map<String, List<MtSchedule>>> groupSchedules(
    List<MtSchedule> schedules,
    int selectedYear,
  ) {
    Map<String, Map<String, List<MtSchedule>>> grouped = {};

    for (var schedule in schedules) {
      if (schedule.tglJadwal?.year != selectedYear) continue;
      
      String assetName = schedule.assetName ?? 'Unknown Asset';
      String bagianMesin = schedule.template?.bagianMesinName ?? 'Unknown';
      
      if (!grouped.containsKey(assetName)) {
        grouped[assetName] = {};
      }
      if (!grouped[assetName]!.containsKey(bagianMesin)) {
        grouped[assetName]![bagianMesin] = [];
      }
      grouped[assetName]![bagianMesin]!.add(schedule);
    }

    return grouped;
  }

  /// Filter schedules berdasarkan search query dan kategori
  static List<MtSchedule> filterSchedules(
    List<MtSchedule> schedules,
    String searchQuery,
    String? filterJenisAset,
  ) {
    final query = searchQuery.trim().toLowerCase();
    Iterable<MtSchedule> list = schedules;
    
    if (filterJenisAset != null && filterJenisAset.isNotEmpty) {
      list = list.where((s) => s.assetJenisAset == filterJenisAset);
    }
    
    if (query.isEmpty) return list.toList();
    
    return list.where((schedule) {
      final assetName = schedule.assetName?.toLowerCase() ?? '';
      final templateName = schedule.template?.displayName.toLowerCase() ?? '';
      final status = schedule.status.toLowerCase();
      final catatan = schedule.catatan?.toLowerCase() ?? '';
      final completedBy = schedule.completedBy?.toLowerCase() ?? '';
      
      return assetName.contains(query) ||
          templateName.contains(query) ||
          status.contains(query) ||
          catatan.contains(query) ||
          completedBy.contains(query);
    }).toList();
  }

  /// Cari schedule dalam range minggu tertentu
  static MtSchedule? findScheduleInWeek({
    required List<MtSchedule> schedules,
    required int month,
    required int year,
    required int weekIndex,
    required bool byJadwal,
  }) {
    int startDay = weekIndex * 7 + 1;
    int endDay = (weekIndex + 1) * 7;

    for (var schedule in schedules) {
      final dateToCheck = byJadwal ? schedule.tglJadwal : schedule.tglSelesai;
      
      if (dateToCheck != null &&
          dateToCheck.year == year &&
          dateToCheck.month == month &&
          dateToCheck.day >= startDay &&
          dateToCheck.day <= endDay) {
        return schedule;
      }
    }
    return null;
  }

  /// Check apakah maintenance sudah selesai (completed)
  static bool isMaintenanceCompleted(MtSchedule schedule) {
    return schedule.tglSelesai != null && 
           schedule.status.toLowerCase() == 'selesai';
  }

  /// Format tanggal untuk display
  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}-${date.month}-${date.year}';
  }
}
