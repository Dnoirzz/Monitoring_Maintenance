import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/mt_schedule_model.dart';
import '../../model/maintenance_request_model.dart';
import '../../model/cek_sheet_schedule_model.dart';
import '../supabase_service.dart';

class TechnicianDashboardService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Fetch tasks for today (Scheduled Maintenance + Pending Requests)
  Future<List<dynamic>> fetchTodayTasks() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    // 1. Fetch Scheduled Maintenance for today
    final scheduleResponse = await _client
        .from('mt_schedule')
        .select('*, assets(*), mt_template(*)')
        .gte('tgl_jadwal', startOfDay.toIso8601String())
        .lte('tgl_jadwal', endOfDay.toIso8601String())
        .order('tgl_jadwal', ascending: true);

    final schedules =
        (scheduleResponse as List)
            .map((json) => MtSchedule.fromJson(json))
            .toList();

    // 2. Fetch Pending/In Progress Maintenance Requests (Urgent/Repair)
    // We assume these are "tasks" for the technician to pick up or work on.
    final requestResponse = await _client
        .from('maintenance_request')
        .select('*, assets(*)')
        .inFilter('status', ['Pending', 'Disetujui'])
        .order('created_at', ascending: false);

    final requests =
        (requestResponse as List)
            .map((json) => MaintenanceRequest.fromJson(json))
            .toList();

    // 3. Fetch Check Sheet Schedules for today
    final checkSheetResponse = await _client
        .from('cek_sheet_schedule')
        .select('*, cek_sheet_template(*)')
        .gte('tgl_jadwal', startOfDay.toIso8601String())
        .lte('tgl_jadwal', endOfDay.toIso8601String())
        .order('tgl_jadwal', ascending: true);

    final checkSheets =
        (checkSheetResponse as List)
            .map((json) => CekSheetSchedule.fromJson(json))
            .toList();

    // Combine all
    return [...schedules, ...requests, ...checkSheets];
  }

  /// Fetch upcoming scheduled maintenance (Tomorrow onwards)
  Future<List<dynamic>> fetchUpcomingTasks() async {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    // 1. Maintenance Schedules
    final mtResponse = await _client
        .from('mt_schedule')
        .select('*, assets(*), mt_template(*)')
        .gte('tgl_jadwal', tomorrow.toIso8601String())
        .order('tgl_jadwal', ascending: true)
        .limit(10);

    final schedules =
        (mtResponse as List).map((json) => MtSchedule.fromJson(json)).toList();

    // 2. Check Sheet Schedules
    final csResponse = await _client
        .from('cek_sheet_schedule')
        .select('*, cek_sheet_template(*)')
        .gte('tgl_jadwal', tomorrow.toIso8601String())
        .order('tgl_jadwal', ascending: true)
        .limit(10);

    final checkSheets =
        (csResponse as List)
            .map((json) => CekSheetSchedule.fromJson(json))
            .toList();

    // Combine and sort by date
    final allUpcoming = [...schedules, ...checkSheets];
    allUpcoming.sort((a, b) {
      DateTime? dateA;
      DateTime? dateB;

      if (a is MtSchedule) dateA = a.tglJadwal;
      if (a is CekSheetSchedule) dateA = a.tglJadwal;

      if (b is MtSchedule) dateB = b.tglJadwal;
      if (b is CekSheetSchedule) dateB = b.tglJadwal;

      if (dateA == null || dateB == null) return 0;
      return dateA.compareTo(dateB);
    });

    return allUpcoming;
  }
}
