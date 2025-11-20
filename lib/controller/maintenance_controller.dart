import '../model/maintenance_model.dart';
import '../service/maintenance_service.dart';

class MaintenanceController {
  final MaintenanceService _maintenanceService = MaintenanceService();
  List<MtScheduleModel> _schedules = [];
  List<MaintenanceRequestModel> _requests = [];

  // Load data from Supabase
  Future<void> loadSchedules() async {
    _schedules = await _maintenanceService.getAllSchedules();
  }

  Future<void> loadRequests() async {
    _requests = await _maintenanceService.getAllRequests();
  }

  // Initialize with data from Supabase
  Future<void> initialize() async {
    await loadSchedules();
    await loadRequests();
  }

  // ============ SCHEDULES ============
  List<MtScheduleModel> getAllSchedules() {
    return List.unmodifiable(_schedules);
  }

  List<MtScheduleModel> getActiveSchedules() {
    return _schedules
        .where((s) => s.status == MtSchedStatus.dalamProses ||
            s.status == MtSchedStatus.perluMaintenance)
        .toList();
  }

  List<MtScheduleModel> getUpcomingSchedules({int days = 7}) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    return _schedules
        .where((s) =>
            s.tglJadwal != null &&
            s.tglJadwal!.isAfter(now) &&
            s.tglJadwal!.isBefore(endDate))
        .toList()
      ..sort((a, b) => a.tglJadwal!.compareTo(b.tglJadwal!));
  }

  List<MtScheduleModel> getOverdueSchedules() {
    final now = DateTime.now();
    return _schedules
        .where((s) =>
            s.tglJadwal != null &&
            s.tglJadwal!.isBefore(now) &&
            s.status != MtSchedStatus.selesai)
        .toList()
      ..sort((a, b) => a.tglJadwal!.compareTo(b.tglJadwal!));
  }

  Future<void> addSchedule(MtScheduleModel schedule) async {
    final created = await _maintenanceService.createSchedule(schedule);
    if (created != null) {
      _schedules.add(created);
    }
  }

  Future<void> updateSchedule(MtScheduleModel schedule) async {
    final updated = await _maintenanceService.updateSchedule(schedule);
    if (updated != null) {
      final index = _schedules.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        _schedules[index] = updated;
      }
    }
  }

  // ============ REQUESTS ============
  List<MaintenanceRequestModel> getAllRequests() {
    return List.unmodifiable(_requests);
  }

  List<MaintenanceRequestModel> getPendingRequests() {
    return _requests
        .where((r) => r.status == ReqStatus.pending)
        .toList()
      ..sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
  }

  List<MaintenanceRequestModel> getRecentRequests({int limit = 10}) {
    final sorted = _requests.toList()
      ..sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
    return sorted.take(limit).toList();
  }

  Future<void> addRequest(MaintenanceRequestModel request) async {
    final created = await _maintenanceService.createRequest(request);
    if (created != null) {
      _requests.add(created);
    }
  }

  Future<void> updateRequest(MaintenanceRequestModel request) async {
    final updated = await _maintenanceService.updateRequest(request);
    if (updated != null) {
      final index = _requests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        _requests[index] = updated;
      }
    }
  }
}

