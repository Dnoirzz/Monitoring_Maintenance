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

  // Get checksheet history with filters
  static Future<List<ChecksheetHistoryItem>> getChecksheetHistory({
    String? assetId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      dynamic query = _client.from('cek_sheet_schedule').select('''
            id,
            tgl_jadwal,
            tgl_selesai,
            catatan,
            assets_id,
            completed_by,
            asset:assets!assets_id (
              nama_assets,
              kode_assets
            ),
            karyawan:karyawan!completed_by (
              full_name
            )
          ''');

      // Only get completed checksheets
      query = query.not('tgl_selesai', 'is', null);

      if (assetId != null) {
        query = query.eq('assets_id', assetId);
      }

      if (startDate != null) {
        query = query.gte(
          'tgl_selesai',
          startDate.toIso8601String().split('T')[0],
        );
      }

      if (endDate != null) {
        query = query.lte(
          'tgl_selesai',
          endDate.toIso8601String().split('T')[0],
        );
      }

      query = query.order('tgl_selesai', ascending: false);

      final data = await query as List;

      // Get statistics for each schedule
      final historyItems = <ChecksheetHistoryItem>[];

      for (final schedule in data) {
        final scheduleId = schedule['id'];

        // Get results statistics
        final results =
            await _client
                    .from('cek_sheet_results')
                    .select('status')
                    .eq('schedule_id', scheduleId)
                as List;

        int goodCount = 0;
        int repairCount = 0;
        int replaceCount = 0;

        for (final result in results) {
          final status = result['status']?.toString().toLowerCase();
          if (status == 'good') {
            goodCount++;
          } else if (status == 'repair') {
            repairCount++;
          } else if (status == 'replace') {
            replaceCount++;
          }
        }

        historyItems.add(
          ChecksheetHistoryItem(
            id: scheduleId,
            scheduleDate: schedule['tgl_jadwal'],
            completedDate: schedule['tgl_selesai'],
            assetName: schedule['asset']?['nama_assets'] ?? 'Unknown',
            assetCode: schedule['asset']?['kode_assets'] ?? '-',
            completedByName: schedule['karyawan']?['full_name'],
            totalItems: results.length,
            goodCount: goodCount,
            repairCount: repairCount,
            replaceCount: replaceCount,
            notes: schedule['catatan'],
          ),
        );
      }

      return historyItems;
    } catch (e) {
      print('Error fetching checksheet history: $e');
      rethrow;
    }
  }

  // Get history detail with all job items and results
  static Future<Map<String, dynamic>> getHistoryDetail(
    String scheduleId,
  ) async {
    try {
      // Get schedule info with asset and completed by
      final schedule =
          await _client
              .from('cek_sheet_schedule')
              .select('''
            id,
            tgl_jadwal,
            tgl_selesai,
            catatan,
            assets_id,
            asset:assets!assets_id (
              nama_assets,
              kode_assets
            ),
            karyawan:karyawan!completed_by (
              full_name
            )
          ''')
              .eq('id', scheduleId)
              .single();

      // Get all results with template details
      final results =
          await _client
                  .from('cek_sheet_results')
                  .select('''
            id,
            template_id,
            status,
            notes,
            photo,
            template:cek_sheet_template!template_id (
              jenis_pekerjaan,
              std_prwtn,
              alat_bahan
            )
          ''')
                  .eq('schedule_id', scheduleId)
              as List;

      // Calculate statistics
      int goodCount = 0;
      int repairCount = 0;
      int replaceCount = 0;

      final jobItems =
          results.map((result) {
            final status = result['status']?.toString().toLowerCase();
            if (status == 'good')
              goodCount++;
            else if (status == 'repair')
              repairCount++;
            else if (status == 'replace')
              replaceCount++;

            return ChecksheetJobItem(
              id: result['template_id'],
              jenisPekerjaan: result['template']?['jenis_pekerjaan'] ?? '',
              stdPrwtn: result['template']?['std_prwtn'] ?? '',
              alatBahan: result['template']?['alat_bahan'] ?? '-',
              status: result['status'],
              notes: result['notes'],
              photo: result['photo'],
            );
          }).toList();

      final historyInfo = ChecksheetHistoryItem(
        id: schedule['id'],
        scheduleDate: schedule['tgl_jadwal'],
        completedDate: schedule['tgl_selesai'],
        assetName: schedule['asset']?['nama_assets'] ?? 'Unknown',
        assetCode: schedule['asset']?['kode_assets'] ?? '-',
        completedByName: schedule['karyawan']?['full_name'],
        totalItems: results.length,
        goodCount: goodCount,
        repairCount: repairCount,
        replaceCount: replaceCount,
        notes: schedule['catatan'],
      );

      return {'historyInfo': historyInfo, 'jobItems': jobItems};
    } catch (e) {
      print('Error fetching history detail: $e');
      rethrow;
    }
  }

  // Get job list summary for a schedule (for preview/expansion)
  static Future<List<ChecksheetJobItem>> getJobListBySchedule(
    String scheduleId,
  ) async {
    try {
      final results =
          await _client
                  .from('cek_sheet_results')
                  .select('''
            template_id,
            status,
            template:cek_sheet_template!template_id (
              jenis_pekerjaan,
              std_prwtn,
              alat_bahan
            )
          ''')
                  .eq('schedule_id', scheduleId)
              as List;

      return results.map((result) {
        return ChecksheetJobItem(
          id: result['template_id'],
          jenisPekerjaan: result['template']?['jenis_pekerjaan'] ?? '',
          stdPrwtn: result['template']?['std_prwtn'] ?? '',
          alatBahan: result['template']?['alat_bahan'] ?? '-',
          status: result['status'],
          notes: null,
          photo: null,
        );
      }).toList();
    } catch (e) {
      print('Error fetching job list: $e');
      rethrow;
    }
  }

  // Get all job templates for an asset with component information
  static Future<List<AssetJobDetail>> getAssetJobTemplates(
    String assetId,
  ) async {
    try {
      // Get all templates for this asset via komponen_assets
      final templates =
          await _client
                  .from('cek_sheet_template')
                  .select('''
            id,
            jenis_pekerjaan,
            std_prwtn,
            alat_bahan,
            periode,
            interval_periode,
            komponen:komponen_assets!komponen_assets_id (
              nama_bagian,
              assets_id
            )
          ''')
                  .eq('komponen.assets_id', assetId)
              as List;

      // Get last checksheet dates for all templates
      final jobDetails = <AssetJobDetail>[];

      for (final template in templates) {
        final templateId = template['id'];

        // Get the last completed checksheet for this template
        // Since cek_sheet_schedule now uses assets_id, we need to:
        // 1. Find schedules for this asset that are completed
        // 2. Find results for this template in those schedules
        // 3. Get the most recent one

        final lastResult =
            await _client
                    .from('cek_sheet_results')
                    .select('''
              *,
              schedule:cek_sheet_schedule!schedule_id (
                tgl_selesai,
                assets_id
              )
            ''')
                    .eq('template_id', templateId)
                    .eq('schedule.assets_id', assetId)
                    .not('schedule.tgl_selesai', 'is', null)
                    .order('created_at', ascending: false)
                    .limit(1)
                as List;

        String? lastDate;
        if (lastResult.isNotEmpty) {
          lastDate = lastResult[0]['schedule']?['tgl_selesai'];
        }

        // Calculate next schedule date based on last completed
        String? nextDate = AssetJobDetail.calculateNextSchedule(
          lastDate,
          template['periode'] ?? '',
          template['interval_periode'] ?? 0,
        );

        // If no calculated next date, check for pending schedules in database
        if (nextDate == null) {
          final pendingSchedule =
              await _client
                      .from('cek_sheet_schedule')
                      .select('tgl_jadwal')
                      .eq('assets_id', assetId)
                      .isFilter('tgl_selesai', null)
                      .order('tgl_jadwal', ascending: true)
                      .limit(1)
                  as List;

          if (pendingSchedule.isNotEmpty) {
            nextDate = pendingSchedule[0]['tgl_jadwal'];
          }
        }

        jobDetails.add(
          AssetJobDetail(
            templateId: templateId,
            componentName: template['komponen']?['nama_bagian'] ?? 'Unknown',
            jenisPekerjaan: template['jenis_pekerjaan'] ?? '',
            stdPrwtn: template['std_prwtn'] ?? '',
            alatBahan: template['alat_bahan'] ?? '-',
            periode: template['periode'] ?? '',
            intervalPeriode: template['interval_periode'] ?? 0,
            lastChecksheetDate: lastDate,
            nextScheduleDate: nextDate,
          ),
        );
      }

      return jobDetails;
    } catch (e) {
      print('Error fetching asset job templates: $e');
      rethrow;
    }
  }

  // Get pending checksheet schedules for today with item counts
  static Future<List<AssetPendingSchedule>> getTodayPendingSchedules() async {
    try {
      final now = DateTime.now();
      final today =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Get schedules for today that are not completed
      final schedules =
          await _client
                  .from('cek_sheet_schedule')
                  .select('''
            id,
            tgl_jadwal,
            assets_id,
            asset:assets!assets_id (
              nama_assets,
              kode_assets
            )
          ''')
                  .eq('tgl_jadwal', today)
                  .isFilter('tgl_selesai', null)
              as List;

      final List<AssetPendingSchedule> pendingSchedules = [];

      for (final schedule in schedules) {
        final assetId = schedule['assets_id'];

        // Count templates for this asset
        // Note: This assumes all templates for the asset are included in the daily check
        final templates =
            await _client
                    .from('cek_sheet_template')
                    .select('id, komponen:komponen_assets!inner(assets_id)')
                    .eq('komponen.assets_id', assetId)
                as List;

        pendingSchedules.add(
          AssetPendingSchedule(
            scheduleId: schedule['id'],
            assetId: assetId,
            assetName: schedule['asset']?['nama_assets'] ?? 'Unknown',
            assetCode: schedule['asset']?['kode_assets'] ?? '-',
            scheduleDate: schedule['tgl_jadwal'],
            pendingItemsCount: templates.length,
          ),
        );
      }

      return pendingSchedules;
    } catch (e) {
      print('Error fetching today pending schedules: $e');
      rethrow;
    }
  }
}
