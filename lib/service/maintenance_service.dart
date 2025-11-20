import '../model/maintenance_model.dart';
import 'supabase_service.dart';

class MaintenanceService {
  final _client = SupabaseService.client;

  // ============ MAINTENANCE TEMPLATE ============
  Future<List<MtTemplateModel>> getAllTemplates() async {
    try {
      final response = await _client.from('mt_template').select();
      return (response as List<dynamic>)
          .map((item) => MtTemplateModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting mt_template: $e');
      return [];
    }
  }

  Future<MtTemplateModel?> getTemplateById(String id) async {
    try {
      final response = await _client.from('mt_template').select().eq('id', id).single();
      return MtTemplateModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error getting mt_template by id: $e');
      return null;
    }
  }

  // ============ MAINTENANCE SCHEDULE ============
  Future<List<MtScheduleModel>> getAllSchedules() async {
    try {
      final response = await _client.from('mt_schedule').select();
      return (response as List<dynamic>)
          .map((item) => MtScheduleModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting mt_schedule: $e');
      return [];
    }
  }

  Future<List<MtScheduleModel>> getSchedulesByStatus(MtSchedStatus status) async {
    try {
      final response = await _client
          .from('mt_schedule')
          .select()
          .eq('status', status.name);
      return (response as List<dynamic>)
          .map((item) => MtScheduleModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting mt_schedule by status: $e');
      return [];
    }
  }

  Future<List<MtScheduleModel>> getUpcomingSchedules({int days = 7}) async {
    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: days));
      final response = await _client
          .from('mt_schedule')
          .select()
          .gte('tgl_jadwal', now.toIso8601String())
          .lte('tgl_jadwal', endDate.toIso8601String())
          .order('tgl_jadwal', ascending: true);
      return (response as List<dynamic>)
          .map((item) => MtScheduleModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting upcoming mt_schedule: $e');
      return [];
    }
  }

  Future<List<MtScheduleModel>> getOverdueSchedules() async {
    try {
      final now = DateTime.now();
      final response = await _client
          .from('mt_schedule')
          .select()
          .lt('tgl_jadwal', now.toIso8601String())
          .neq('status', MtSchedStatus.selesai.name)
          .order('tgl_jadwal', ascending: true);
      return (response as List<dynamic>)
          .map((item) => MtScheduleModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting overdue mt_schedule: $e');
      return [];
    }
  }

  Future<MtScheduleModel?> createSchedule(MtScheduleModel schedule) async {
    try {
      final response =
          await _client.from('mt_schedule').insert(schedule.toMap()).select().single();
      return MtScheduleModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error creating mt_schedule: $e');
      return null;
    }
  }

  Future<MtScheduleModel?> updateSchedule(MtScheduleModel schedule) async {
    try {
      if (schedule.id == null) return null;
      final response = await _client
          .from('mt_schedule')
          .update(schedule.toMap())
          .eq('id', schedule.id!)
          .select()
          .single();
      return MtScheduleModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error updating mt_schedule: $e');
      return null;
    }
  }

  // ============ MAINTENANCE REQUEST ============
  Future<List<MaintenanceRequestModel>> getAllRequests() async {
    try {
      final response = await _client.from('maintenance_request').select();
      return (response as List<dynamic>)
          .map((item) => MaintenanceRequestModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting maintenance_request: $e');
      return [];
    }
  }

  Future<List<MaintenanceRequestModel>> getRequestsByStatus(ReqStatus status) async {
    try {
      final response = await _client
          .from('maintenance_request')
          .select()
          .eq('status', status.name)
          .order('created_at', ascending: false);
      return (response as List<dynamic>)
          .map((item) => MaintenanceRequestModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting maintenance_request by status: $e');
      return [];
    }
  }

  Future<List<MaintenanceRequestModel>> getRecentRequests({int limit = 10}) async {
    try {
      final response = await _client
          .from('maintenance_request')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return (response as List<dynamic>)
          .map((item) => MaintenanceRequestModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting recent maintenance_request: $e');
      return [];
    }
  }

  Future<MaintenanceRequestModel?> createRequest(MaintenanceRequestModel request) async {
    try {
      final response = await _client
          .from('maintenance_request')
          .insert(request.toMap())
          .select()
          .single();
      return MaintenanceRequestModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error creating maintenance_request: $e');
      return null;
    }
  }

  Future<MaintenanceRequestModel?> updateRequest(MaintenanceRequestModel request) async {
    try {
      if (request.id == null) return null;
      final response = await _client
          .from('maintenance_request')
          .update(request.toMap())
          .eq('id', request.id!)
          .select()
          .single();
      return MaintenanceRequestModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error updating maintenance_request: $e');
      return null;
    }
  }
}

