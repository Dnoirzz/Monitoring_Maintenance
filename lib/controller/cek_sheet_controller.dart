import '../model/cek_sheet_model.dart';
import '../service/cek_sheet_service.dart';

class CekSheetController {
  final CekSheetService _cekSheetService = CekSheetService();
  List<CekSheetTemplateModel> _templates = [];
  List<CekSheetScheduleModel> _schedules = [];

  // Load data from Supabase
  Future<void> loadTemplates() async {
    _templates = await _cekSheetService.getAllTemplates();
  }

  Future<void> loadSchedules() async {
    _schedules = await _cekSheetService.getAllSchedules();
  }

  // Initialize with data from Supabase
  Future<void> initialize() async {
    await loadTemplates();
    await loadSchedules();
  }

  // ============ TEMPLATES ============
  List<CekSheetTemplateModel> getAllTemplates() {
    return List.unmodifiable(_templates);
  }

  CekSheetTemplateModel? getTemplateById(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addTemplate(CekSheetTemplateModel template) async {
    final created = await _cekSheetService.createTemplate(template);
    if (created != null) {
      _templates.add(created);
    }
  }

  Future<void> updateTemplate(CekSheetTemplateModel template) async {
    final updated = await _cekSheetService.updateTemplate(template);
    if (updated != null) {
      final index = _templates.indexWhere((t) => t.id == template.id);
      if (index != -1) {
        _templates[index] = updated;
      }
    }
  }

  // ============ SCHEDULES ============
  List<CekSheetScheduleModel> getAllSchedules() {
    return List.unmodifiable(_schedules);
  }

  List<CekSheetScheduleModel> getSchedulesByTemplateId(String templateId) {
    return _schedules.where((s) => s.templateId == templateId).toList();
  }

  List<CekSheetScheduleModel> getUpcomingSchedules({int days = 7}) {
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

  Future<void> addSchedule(CekSheetScheduleModel schedule) async {
    final created = await _cekSheetService.createSchedule(schedule);
    if (created != null) {
      _schedules.add(created);
    }
  }

  Future<void> updateSchedule(CekSheetScheduleModel schedule) async {
    final updated = await _cekSheetService.updateSchedule(schedule);
    if (updated != null) {
      final index = _schedules.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        _schedules[index] = updated;
      }
    }
  }

  Future<void> deleteSchedule(String id) async {
    final success = await _cekSheetService.deleteSchedule(id);
    if (success) {
      _schedules.removeWhere((s) => s.id == id);
    }
  }
}

