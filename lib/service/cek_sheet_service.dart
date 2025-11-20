import '../model/cek_sheet_model.dart';
import 'supabase_service.dart';

class CekSheetService {
  final _client = SupabaseService.client;

  // ============ CEK SHEET TEMPLATE ============
  Future<List<CekSheetTemplateModel>> getAllTemplates() async {
    try {
      final response = await _client.from('cek_sheet_template').select();
      return (response as List<dynamic>)
          .map((item) =>
              CekSheetTemplateModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting cek_sheet_template: $e');
      return [];
    }
  }

  Future<CekSheetTemplateModel?> getTemplateById(String id) async {
    try {
      final response =
          await _client.from('cek_sheet_template').select().eq('id', id).single();
      return CekSheetTemplateModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error getting cek_sheet_template by id: $e');
      return null;
    }
  }

  Future<CekSheetTemplateModel?> createTemplate(CekSheetTemplateModel template) async {
    try {
      final response = await _client
          .from('cek_sheet_template')
          .insert(template.toMap())
          .select()
          .single();
      return CekSheetTemplateModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error creating cek_sheet_template: $e');
      return null;
    }
  }

  Future<CekSheetTemplateModel?> updateTemplate(CekSheetTemplateModel template) async {
    try {
      if (template.id == null) return null;
      final response = await _client
          .from('cek_sheet_template')
          .update(template.toMap())
          .eq('id', template.id!)
          .select()
          .single();
      return CekSheetTemplateModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error updating cek_sheet_template: $e');
      return null;
    }
  }

  // ============ CEK SHEET SCHEDULE ============
  Future<List<CekSheetScheduleModel>> getAllSchedules() async {
    try {
      final response = await _client.from('cek_sheet_schedule').select();
      return (response as List<dynamic>)
          .map((item) =>
              CekSheetScheduleModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting cek_sheet_schedule: $e');
      return [];
    }
  }

  Future<List<CekSheetScheduleModel>> getSchedulesByTemplateId(String templateId) async {
    try {
      final response = await _client
          .from('cek_sheet_schedule')
          .select()
          .eq('template_id', templateId)
          .order('tgl_jadwal', ascending: true);
      return (response as List<dynamic>)
          .map((item) =>
              CekSheetScheduleModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting cek_sheet_schedule by template_id: $e');
      return [];
    }
  }

  Future<List<CekSheetScheduleModel>> getUpcomingSchedules({int days = 7}) async {
    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: days));
      final response = await _client
          .from('cek_sheet_schedule')
          .select()
          .gte('tgl_jadwal', now.toIso8601String())
          .lte('tgl_jadwal', endDate.toIso8601String())
          .order('tgl_jadwal', ascending: true);
      return (response as List<dynamic>)
          .map((item) =>
              CekSheetScheduleModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting upcoming cek_sheet_schedule: $e');
      return [];
    }
  }

  Future<CekSheetScheduleModel?> createSchedule(CekSheetScheduleModel schedule) async {
    try {
      final response = await _client
          .from('cek_sheet_schedule')
          .insert(schedule.toMap())
          .select()
          .single();
      return CekSheetScheduleModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error creating cek_sheet_schedule: $e');
      return null;
    }
  }

  Future<CekSheetScheduleModel?> updateSchedule(CekSheetScheduleModel schedule) async {
    try {
      if (schedule.id == null) return null;
      final response = await _client
          .from('cek_sheet_schedule')
          .update(schedule.toMap())
          .eq('id', schedule.id!)
          .select()
          .single();
      return CekSheetScheduleModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error updating cek_sheet_schedule: $e');
      return null;
    }
  }

  Future<bool> deleteSchedule(String id) async {
    try {
      await _client.from('cek_sheet_schedule').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting cek_sheet_schedule: $e');
      return false;
    }
  }
}

