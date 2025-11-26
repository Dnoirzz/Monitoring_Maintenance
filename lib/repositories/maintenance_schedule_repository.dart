import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/mt_schedule_model.dart';
import '../model/mt_template_model.dart';
import '../services/supabase_service.dart';

/// Maintenance Schedule Repository
/// Handles all database operations related to mt_schedule and mt_template
class MaintenanceScheduleRepository {
  final SupabaseClient _client = SupabaseService.instance.client;

  // ==================== MT_TEMPLATE OPERATIONS ====================

  /// Get all templates
  Future<List<MtTemplate>> getAllTemplates() async {
    try {
      final response = await _client
          .from('mt_template')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MtTemplate.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch templates: $e');
    }
  }

  /// Get template by ID
  Future<MtTemplate?> getTemplateById(String id) async {
    try {
      final response =
          await _client.from('mt_template').select().eq('id', id).single();

      return MtTemplate.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch template: $e');
    }
  }

  /// Create new template
  Future<MtTemplate> createTemplate(MtTemplate template) async {
    try {
      final response = await _client
          .from('mt_template')
          .insert(template.toJson())
          .select()
          .single();

      return MtTemplate.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create template: $e');
    }
  }

  /// Update template
  Future<MtTemplate> updateTemplate(String id, MtTemplate template) async {
    try {
      final response = await _client
          .from('mt_template')
          .update(template.toJson())
          .eq('id', id)
          .select()
          .single();

      return MtTemplate.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update template: $e');
    }
  }

  /// Delete template
  Future<void> deleteTemplate(String id) async {
    try {
      await _client.from('mt_template').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  }

  // ==================== MT_SCHEDULE OPERATIONS ====================

  /// Get all schedules with joined template, asset, and bg_mesin data
  Future<List<MtSchedule>> getAllSchedules() async {
    try {
      final response = await _client
          .from('mt_schedule')
          .select('*, mt_template(*, bg_mesin(*)), assets(*)')
          .order('tgl_jadwal', ascending: false);

      return (response as List)
          .map((json) => MtSchedule.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch schedules: $e');
    }
  }

  /// Get schedule by ID with joined data
  Future<MtSchedule?> getScheduleById(String id) async {
    try {
      final response = await _client
          .from('mt_schedule')
          .select('*, mt_template(*, bg_mesin(*)), assets(*)')
          .eq('id', id)
          .single();

      return MtSchedule.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch schedule: $e');
    }
  }

  /// Get schedules by asset ID
  Future<List<MtSchedule>> getSchedulesByAssetId(String assetId) async {
    try {
      final response = await _client
          .from('mt_schedule')
          .select('*, mt_template(*, bg_mesin(*)), assets(*)')
          .eq('assets_id', assetId)
          .order('tgl_jadwal', ascending: false);

      return (response as List)
          .map((json) => MtSchedule.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch schedules by asset: $e');
    }
  }

  /// Create new schedule
  Future<MtSchedule> createSchedule(MtSchedule schedule) async {
    try {
      final response = await _client
          .from('mt_schedule')
          .insert(schedule.toJson())
          .select()
          .single();

      return MtSchedule.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create schedule: $e');
    }
  }

  /// Update schedule
  Future<MtSchedule> updateSchedule(String id, MtSchedule schedule) async {
    try {
      final response = await _client
          .from('mt_schedule')
          .update(schedule.toJson())
          .eq('id', id)
          .select()
          .single();

      return MtSchedule.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  Future<void> updateActualDate(String id, DateTime actualDate,
      {bool markCompleted = true}) async {
    try {
      final Map<String, dynamic> data = {
        'tgl_selesai': actualDate.toIso8601String().split('T')[0],
        if (markCompleted) 'status': 'Selesai',
      };
      await _client.from('mt_schedule').update(data).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update actual date: $e');
    }
  }

  /// Delete schedule
  Future<void> deleteSchedule(String id) async {
    try {
      await _client.from('mt_schedule').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }
}
