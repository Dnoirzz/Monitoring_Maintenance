import '../model/maintenance_schedule_model.dart';

class MaintenanceScheduleController {
  final List<MaintenanceScheduleEntry> _entries = [
    // CREEPER CATEGORY
    // CREEPER 01 - Roll Atas
    MaintenanceScheduleEntry(
      category: MaintenanceCategory.creeper,
      machine: 'CREEPER 01',
      part: 'Roll Atas',
      liftTime: '1 bulan / 364 jam',
      monthlySchedule: buildMonthlyScheduleFromDates(
        planDates: {
          'Jan': 4,
          'Feb': 4,
          'Mar': 4,
          'Apr': 4,
          'May': 4,
          'Jun': 4,
          'Jul': 4,
          'Aug': 4,
          'Sep': 4,
          'Oct': 4,
          'Nov': 4,
          'Dec': 4,
        },
        actualDates: {
          'Jan': 4,
          'Feb': 18,
          'Mar': 13,
          'Apr': 14,
          'May': 20,
          'Jun': 23,
          'Jul': 11,
          'Aug': 21,
          'Sep': 26,
          'Oct': 26,
          'Nov': 26,
          'Dec': 26,
        },
      ),
    ),
    // CREEPER 01 - Roll Bawah
    MaintenanceScheduleEntry(
      category: MaintenanceCategory.creeper,
      machine: 'CREEPER 01',
      part: 'Roll Bawah',
      liftTime: '1 bulan / 364 jam',
      monthlySchedule: buildMonthlyScheduleFromDates(
        planDates: {
          'Jan': 4,
          'Feb': 4,
          'Mar': 4,
          'Apr': 4,
          'May': 4,
          'Jun': 4,
          'Jul': 4,
          'Aug': 4,
          'Sep': 4,
          'Oct': 4,
          'Nov': 4,
          'Dec': 4,
        },
        actualDates: {
          'Jan': 4,
          'Feb': 18,
          'Mar': 18,
          'Apr': 25,
          'May': 25,
          'Jun': 25,
          'Jul': 8,
          'Aug': 25,
          'Sep': 25,
          'Oct': 25,
          'Nov': 25,
          'Dec': 25,
        },
      ),
    ),
    // CREEPER 02 - Roll Atas
    MaintenanceScheduleEntry(
      category: MaintenanceCategory.creeper,
      machine: 'CREEPER 02',
      part: 'Roll Atas',
      liftTime: '2 bulan / 728 jam',
      monthlySchedule: buildMonthlyScheduleFromDates(
        planDates: {
          'Jan': 14,
          'Feb': 14,
          'Mar': 14,
          'Apr': 14,
          'May': 14,
          'Jun': 14,
          'Jul': 14,
          'Aug': 14,
          'Sep': 14,
          'Oct': 14,
          'Nov': 14,
          'Dec': 14,
        },
        actualDates: {
          'Jan': 14,
          'Feb': 14,
          'Mar': 14,
          'Apr': 14,
          'May': 14,
          'Jun': 14,
          'Jul': 14,
          'Aug': 14,
          'Sep': 14,
          'Oct': 14,
          'Nov': 14,
          'Dec': 14,
        },
      ),
    ),
    // CREEPER MANAGEMENT - Skim
    MaintenanceScheduleEntry(
      category: MaintenanceCategory.creeper,
      machine: 'CREEPER MANAGEMENT',
      part: 'Skim',
      liftTime: '2 bulan / 728 jam',
      monthlySchedule: buildMonthlyScheduleFromDates(
        planDates: {
          'Jan': 29,
          'Feb': 29,
          'Mar': 29,
          'Apr': 29,
          'May': 29,
          'Jun': 29,
          'Jul': 29,
          'Aug': 29,
          'Sep': 29,
          'Oct': 29,
          'Nov': 29,
          'Dec': 29,
        },
        actualDates: {
          'Jan': 29,
          'Feb': 29,
          'Mar': 29,
          'Apr': 29,
          'May': 29,
          'Jun': 29,
          'Jul': 29,
          'Aug': 29,
          'Sep': 29,
          'Oct': 29,
          'Nov': 29,
          'Dec': 29,
        },
      ),
    ),
  ];

  List<MaintenanceScheduleEntry> getEntries() {
    return List.unmodifiable(_entries);
  }

  List<MaintenanceScheduleEntry> getEntriesByCategory(
    MaintenanceCategory category,
  ) {
    return _entries.where((entry) => entry.category == category).toList();
  }

  List<MaintenanceCategory> getAvailableCategories() {
    return MaintenanceCategory.values;
  }
}
