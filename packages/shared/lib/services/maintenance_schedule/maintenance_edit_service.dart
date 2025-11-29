import 'package:flutter/material.dart';
import '../../models/mt_schedule_model.dart';
import '../../repositories/maintenance_schedule_repository.dart';

/// Helper class untuk menyimpan state edit interval
class _EditIntervalState {
  int interval;
  String periode;

  _EditIntervalState({
    required this.interval,
    required this.periode,
  });
}

/// Service untuk menangani edit interval dan batch delete schedules
class MaintenanceEditService {
  final MaintenanceScheduleRepository repository;
  final BuildContext context;

  MaintenanceEditService({
    required this.repository,
    required this.context,
  });

  /// Show modal untuk edit interval dan periode
  void showEditIntervalModal({
    required MtSchedule schedule,
    required int selectedYear,
    required VoidCallback onSuccess,
  }) {
    if (schedule.template == null) {
      _showSnackBar('Template tidak ditemukan', isError: true);
      return;
    }

    final currentInterval = schedule.template!.intervalPeriode ?? 1;
    final currentPeriode = schedule.template!.periode ?? 'Hari';
    
    // Wrapper untuk menyimpan state
    var state = _EditIntervalState(
      interval: currentInterval,
      periode: currentPeriode,
    );
    
    final intervalController = TextEditingController(text: currentInterval.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Edit Interval Maintenance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule.assetName} - ${schedule.template?.bagianMesinName ?? ''}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 16),
                Text('Interval Saat Ini: $currentInterval $currentPeriode'),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: intervalController,
                        decoration: InputDecoration(
                          labelText: 'Interval',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setModalState(() {
                            state.interval = int.tryParse(value) ?? currentInterval;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: state.periode,
                        decoration: InputDecoration(
                          labelText: 'Periode',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem(value: 'Hari', child: Text('Harian')),
                          DropdownMenuItem(value: 'Minggu', child: Text('Mingguan')),
                          DropdownMenuItem(value: 'Bulan', child: Text('Bulanan')),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            state.periode = value ?? currentPeriode;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                intervalController.dispose();
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (state.interval <= 0) {
                  _showSnackBar('Interval harus lebih dari 0', isError: true);
                  return;
                }

                Navigator.pop(context);
                await _processEditInterval(
                  schedule: schedule,
                  newInterval: state.interval,
                  newPeriode: state.periode,
                  selectedYear: selectedYear,
                  onSuccess: onSuccess,
                );
                intervalController.dispose();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A9C5D),
                foregroundColor: Colors.white,
              ),
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  /// Process edit interval dengan logic: delete old + insert new
  Future<void> _processEditInterval({
    required MtSchedule schedule,
    required int newInterval,
    required String newPeriode,
    required int selectedYear,
    required VoidCallback onSuccess,
  }) async {
    try {
      if (!context.mounted) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memproses perubahan interval...'),
            ],
          ),
        ),
      );

      // Step 1: Fetch semua schedules untuk template ini di tahun terpilih
      final allSchedules = await repository.getAllSchedules();
      final schedulesToDelete = allSchedules
          .where((s) =>
              s.templateId == schedule.templateId &&
              s.tglJadwal != null &&
              s.tglJadwal!.year == selectedYear)
          .toList();

      // Step 2: Batch delete menggunakan optimized method
      if (schedulesToDelete.isNotEmpty) {
        await batchDeleteSchedules(schedulesToDelete.map((s) => s.id!).toList());
      }

      // Step 3: Generate jadwal baru dengan interval baru
      final startDate = schedule.template!.startDate ?? schedule.tglJadwal!;
      List<DateTime> occurrenceDates = [];
      DateTime cursor = startDate;

      while (cursor.year <= selectedYear) {
        if (cursor.year == selectedYear) {
          occurrenceDates.add(cursor);
        }
        switch (newPeriode) {
          case 'Hari':
            cursor = cursor.add(Duration(days: newInterval));
            break;
          case 'Minggu':
            cursor = cursor.add(Duration(days: newInterval * 7));
            break;
          case 'Bulan':
            cursor = DateTime(cursor.year, cursor.month + newInterval, cursor.day);
            break;
          default:
            throw Exception('Periode tidak valid: $newPeriode');
        }
      }

      // Step 4: Create new schedules
      for (final date in occurrenceDates) {
        final newSchedule = MtSchedule(
          templateId: schedule.templateId,
          assetsId: schedule.assetsId,
          tglJadwal: date,
          status: 'Perlu Maintenance',
          catatan: schedule.catatan,
          createdBy: schedule.createdBy,
        );
        await repository.createSchedule(newSchedule);
      }

      // Step 5: Update template dengan interval dan periode baru
      if (schedule.template != null && schedule.template!.id != null) {
        final updatedTemplate = schedule.template!.copyWith(
          intervalPeriode: newInterval,
          periode: newPeriode,
        );
        await repository.updateTemplate(schedule.template!.id!, updatedTemplate);
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showSnackBar('Interval berhasil diubah. ${occurrenceDates.length} jadwal baru dibuat.');
        onSuccess();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showSnackBar('Gagal mengubah interval: $e', isError: true);
      }
    }
  }

  /// Batch delete schedules yang optimal (tidak loop one-by-one)
  /// Menggunakan batch query untuk menghindari multiple round-trips
  Future<void> batchDeleteSchedules(List<String> scheduleIds) async {
    if (scheduleIds.isEmpty) return;

    try {
      // Batch delete dengan chunk size untuk mencegah query URL terlalu panjang
      const int chunkSize = 100;
      for (int i = 0; i < scheduleIds.length; i += chunkSize) {
        final chunk = scheduleIds.sublist(
          i,
          i + chunkSize > scheduleIds.length ? scheduleIds.length : i + chunkSize,
        );

        // Delete chunk dengan IN operator
        await repository.batchDeleteSchedulesByIds(chunk);
      }
    } catch (e) {
      throw Exception('Gagal batch delete: $e');
    }
  }

  /// Show snackbar utility
  void _showSnackBar(String message, {bool isError = false}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
