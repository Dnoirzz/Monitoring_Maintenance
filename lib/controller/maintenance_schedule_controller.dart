import '../model/maintenance_schedule_model.dart';
import '../model/mt_schedule_model.dart';
import '../repositories/maintenance_schedule_repository.dart';

class MaintenanceScheduleController {
  final MaintenanceScheduleRepository _repository =
      MaintenanceScheduleRepository();
  List<MtSchedule> _schedules = [];
  bool _isLoading = false;

  // Legacy support for calendar view
  final List<MaintenanceScheduleEntry> _entries = [];

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

  // New methods for database operations
  bool get isLoading => _isLoading;

  List<MtSchedule> getAllSchedules() {
    return List.unmodifiable(_schedules);
  }

  Future<void> loadSchedules() async {
    _isLoading = true;
    try {
      _schedules = await _repository.getAllSchedules();
    } catch (e) {
      throw Exception('Failed to load schedules: $e');
    } finally {
      _isLoading = false;
    }
  }

  List<MtSchedule> filterSchedules({String? searchQuery}) {
    List<MtSchedule> filtered = List.from(_schedules);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((schedule) {
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
    return filtered;
  }

  Map<String, List<MtSchedule>> groupByAsset(
    List<MtSchedule> schedules,
  ) {
    final Map<String, List<MtSchedule>> grouped = {};
    for (var schedule in schedules) {
      final assetName = schedule.assetName ?? 'Unknown';
      grouped.putIfAbsent(assetName, () => []);
      grouped[assetName]!.add(schedule);
    }
    return grouped;
  }

  Future<void> createSchedule(MtSchedule schedule) async {
    try {
      final created = await _repository.createSchedule(schedule);
      _schedules.add(created);
    } catch (e) {
      throw Exception('Failed to create schedule: $e');
    }
  }

  Future<void> updateSchedule(MtSchedule schedule) async {
    try {
      if (schedule.id == null) {
        throw Exception('Schedule ID is required for update');
      }
      final updated = await _repository.updateSchedule(schedule.id!, schedule);
      final index = _schedules.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        _schedules[index] = updated;
      }
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      await _repository.deleteSchedule(id);
      _schedules.removeWhere((s) => s.id == id);
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }
}
