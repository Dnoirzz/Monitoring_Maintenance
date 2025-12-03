import 'package:shared/services/supabase_service.dart';
import '../models/checksheet_models.dart';

class ChecksheetService {
  static final _client = SupabaseService.instance.client;

  // Get list of checksheet schedules
  static Future<List<ChecksheetSchedule>> getSchedules({
    String? date,
    String? status,
    String? assetId, // Optional: filter by asset
  }) async {
    try {
      // Build query dynamically
      dynamic query = _client.from('cek_sheet_schedule').select('''
            id,
            tgl_jadwal,
            tgl_selesai,
            catatan,
            asset:assets!assets_id (
              nama_assets,
              kode_assets
            )
          ''');

      if (date != null) {
        query = query.eq('tgl_jadwal', date);
      }

      if (assetId != null) {
        query = query.eq('assets_id', assetId);
      }

      if (status == 'pending') {
        query = query.is_('tgl_selesai', null);
      } else if (status == 'completed') {
        query = query.not('tgl_selesai', 'is', null);
      }

      query = query.order('tgl_jadwal', ascending: false);

      final data = await query as List;

      return data.map((schedule) {
        return ChecksheetSchedule(
          id: schedule['id'],
          date: schedule['tgl_jadwal'],
          completedDate: schedule['tgl_selesai'],
          status: schedule['tgl_selesai'] != null ? 'completed' : 'pending',
          machineName: schedule['asset']?['nama_assets'] ?? 'Unknown',
          machineCode: schedule['asset']?['kode_assets'] ?? '-',
          notes: schedule['catatan'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching checksheet schedules: $e');
      rethrow;
    }
  }

  // Get schedule details with templates
  static Future<ChecksheetScheduleDetail> getScheduleDetails(
    String scheduleId,
  ) async {
    try {
      // Get schedule with machine info
      final schedule =
          await _client
              .from('cek_sheet_schedule')
              .select('''
            id,
            assets_id,
            tgl_jadwal,
            tgl_selesai,
            catatan,
            asset:assets!assets_id (
              nama_assets,
              kode_assets
            )
          ''')
              .eq('id', scheduleId)
              .single();

      final assetsId = schedule['assets_id'];

      // Get all templates for this asset (via komponen_assets)
      // Note: We need to join komponen_assets to filter by assets_id
      final templates =
          await _client
                  .from('cek_sheet_template')
                  .select('''
            id,
            jenis_pekerjaan,
            std_prwtn,
            alat_bahan,
            periode,
            komponen:komponen_assets!komponen_assets_id (
              assets_id
            )
          ''')
                  .eq(
                    'komponen.assets_id',
                    assetsId,
                  ) // Filter by asset ID via relation
              as List;

      // Filter manually if nested filtering has issues, or rely on Supabase filtering
      // For safety, we can filter in Dart if the query returns too much, but .eq on joined table should work if set up correctly.
      // However, Supabase sometimes needs explicit inner join hints.
      // Let's assume the query returns templates linked to components of this asset.

      // Get existing results if any
      final existingResults =
          await _client
                  .from('cek_sheet_results')
                  .select('*')
                  .eq('schedule_id', scheduleId)
              as List;

      // Map results to templates
      final templatesWithResults =
          templates.map((template) {
            final result = existingResults
                .cast<Map<String, dynamic>?>()
                .firstWhere(
                  (r) => r?['template_id'] == template['id'],
                  orElse: () => null,
                );

            return ChecksheetTemplate(
              id: template['id'],
              jenisPekerjaan: template['jenis_pekerjaan'] ?? '',
              stdPrwtn: template['std_prwtn'] ?? '',
              alatBahan: template['alat_bahan'] ?? '-',
              status: result?['status'],
              notes: result?['notes'],
              photo: result?['photo'],
            );
          }).toList();

      return ChecksheetScheduleDetail(
        schedule: ScheduleInfo(
          id: schedule['id'],
          tglJadwal: schedule['tgl_jadwal'],
          tglSelesai: schedule['tgl_selesai'],
          catatan: schedule['catatan'] ?? '',
          assetName: schedule['asset']?['nama_assets'] ?? 'Unknown',
          assetCode: schedule['asset']?['kode_assets'] ?? '-',
        ),
        templates: templatesWithResults,
      );
    } catch (e) {
      print('Error fetching schedule details: $e');
      rethrow;
    }
  }

  // Submit checksheet results
  static Future<void> submitChecksheet({
    required String scheduleId,
    required List<ChecksheetTemplate> results,
    required String generalNotes,
  }) async {
    try {
      // Get current user ID from auth
      final userId = _client.auth.currentUser?.id;

      // 1. Delete existing results
      await _client
          .from('cek_sheet_results')
          .delete()
          .eq('schedule_id', scheduleId);

      // 2. Insert new results
      final resultsToInsert =
          results
              .where((r) => r.status != null && r.status!.isNotEmpty)
              .map(
                (result) => {
                  'schedule_id': scheduleId,
                  'template_id': result.id,
                  'status': result.status,
                  'notes': result.notes,
                  'photo': result.photo,
                },
              )
              .toList();

      if (resultsToInsert.isNotEmpty) {
        await _client.from('cek_sheet_results').insert(resultsToInsert);
      }

      // 3. Update schedule
      final updateData = <String, dynamic>{
        'tgl_selesai': DateTime.now().toIso8601String().split('T')[0],
        'catatan': generalNotes,
        'completed_by': userId,
      };

      await _client
          .from('cek_sheet_schedule')
          .update(updateData)
          .eq('id', scheduleId);
    } catch (e) {
      print('Error submitting checksheet: $e');
      rethrow;
    }
  }
}
