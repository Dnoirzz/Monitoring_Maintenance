const List<String> monthShortNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

enum MaintenanceCategory {
  miling,
  creeper,
  crumbing;

  String get displayName {
    switch (this) {
      case MaintenanceCategory.miling:
        return 'MILING';
      case MaintenanceCategory.creeper:
        return 'CREEPER';
      case MaintenanceCategory.crumbing:
        return 'CRUMBING';
    }
  }
}

class MaintenanceScheduleEntry {
  final MaintenanceCategory category;
  final String machine;
  final String part;
  final String liftTime;
  final Map<String, List<WeekMetric>> monthlySchedule;

  const MaintenanceScheduleEntry({
    required this.category,
    required this.machine,
    required this.part,
    required this.liftTime,
    required this.monthlySchedule,
  });
}

class WeekMetric {
  final int? plan; // Tanggal rencana (null jika tidak ada rencana)
  final int? actual; // Tanggal pelaksanaan (null jika belum dilaksanakan)

  const WeekMetric({this.plan, this.actual});
}

// Helper function untuk membuat schedule bulanan dengan week numbering kontinyu
// planDates dan actualDates adalah tanggal dalam bulan (1-31)
// Week numbering: Jan=1-4, Feb=5-8, Mar=9-12, dst (total 48 week dalam setahun)
Map<String, List<WeekMetric>> buildMonthlyScheduleFromDates({
  required Map<String, int?> planDates, // Map bulan ke tanggal plan
  required Map<String, int?> actualDates, // Map bulan ke tanggal actual
}) {
  final Map<String, List<WeekMetric>> schedule = {};

  for (var month in monthShortNames) {
    final planDate = planDates[month];
    final actualDate = actualDates[month];

    // Tentukan week mana untuk plan dan actual (0-3 dalam bulan)
    int? planWeek = planDate != null ? _getWeekFromDate(planDate) : null;
    int? actualWeek = actualDate != null ? _getWeekFromDate(actualDate) : null;

    // Buat 4 week metrics untuk bulan ini
    schedule[month] = List.generate(4, (weekIndex) {
      return WeekMetric(
        plan: planWeek == weekIndex ? planDate : null,
        actual: actualWeek == weekIndex ? actualDate : null,
      );
    });
  }

  return schedule;
}

// Fungsi helper untuk menentukan week dari tanggal dalam bulan (0-3)
int _getWeekFromDate(int date) {
  if (date >= 1 && date <= 7) return 0; // Week 1 dalam bulan
  if (date >= 8 && date <= 14) return 1; // Week 2 dalam bulan
  if (date >= 15 && date <= 21) return 2; // Week 3 dalam bulan
  return 3; // Week 4 dalam bulan (22-31)
}

// Fungsi helper untuk mendapatkan week number global (1-52)
int getGlobalWeekNumber(int monthIndex, int weekInMonth) {
  // monthIndex: 0=Jan, 1=Feb, dst
  // weekInMonth: 0-3
  return (monthIndex * 4) + weekInMonth + 1;
}
