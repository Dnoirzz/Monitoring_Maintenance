class DashboardStats {
  final int totalAssets;
  final int totalKaryawan;
  final int pendingRequests;
  final int activeMaintenance;
  final int overdueSchedule;

  DashboardStats({
    required this.totalAssets,
    required this.totalKaryawan,
    required this.pendingRequests,
    required this.activeMaintenance,
    required this.overdueSchedule,
  });
}

class RequestHistory {
  final String title;
  final String status;
  final String date;

  RequestHistory({
    required this.title,
    required this.status,
    required this.date,
  });
}

class UpcomingSchedule {
  final String title;
  final String date;
  final bool isOverdue;

  UpcomingSchedule({
    required this.title,
    required this.date,
    required this.isOverdue,
  });
}

