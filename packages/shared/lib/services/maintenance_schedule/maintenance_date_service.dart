import 'package:flutter/material.dart';
import 'package:shared/models/mt_schedule_model.dart';
import 'package:shared/repositories/maintenance_schedule_repository.dart';

/// Service untuk handle date picker dan update operations
class MaintenanceDateService {
  final MaintenanceScheduleRepository repository;
  final BuildContext context;

  MaintenanceDateService({
    required this.repository,
    required this.context,
  });

  /// Edit tanggal plan (tglJadwal)
  Future<void> pickAndEditPlanDate({
    required MtSchedule schedule,
    required int selectedYear,
    required VoidCallback onSuccess,
  }) async {
    final initialDate = schedule.tglJadwal ?? DateTime.now();
    final firstDate = DateTime(selectedYear, 1, 1);
    final lastDate = DateTime(selectedYear, 12, 31);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0A9C5D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    try {
      if (schedule.id == null) throw Exception('ID schedule tidak ditemukan');
      
      final updatedSchedule = schedule.copyWith(tglJadwal: pickedDate);
      await repository.updateSchedule(schedule.id!, updatedSchedule);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tanggal plan diperbarui: ${pickedDate.day}-${pickedDate.month}-${pickedDate.year}'),
            backgroundColor: Colors.green,
          ),
        );
      }
      onSuccess();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah tanggal plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Set/Edit tanggal actual (tglSelesai)
  /// Memungkinkan tanggal actual sebelum tanggal plan (kasus lapangan selesai sebelum jadwal)
  Future<void> pickAndSetActualDate({
    required MtSchedule schedule,
    required int selectedYear,
    required VoidCallback onSuccess,
  }) async {
    final initialDate = schedule.tglSelesai ?? schedule.tglJadwal ?? DateTime.now();
    // Allow picking date before plan date - allow any date in selected year and next year
    final firstDate = DateTime(selectedYear, 1, 1);
    final lastDate = DateTime(selectedYear + 1, 12, 31);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0A9C5D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    try {
      if (schedule.id == null) throw Exception('ID schedule tidak ditemukan');
      await repository.updateActualDate(schedule.id!, pickedDate, markCompleted: true);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tanggal actual disimpan: ${pickedDate.day}-${pickedDate.month}-${pickedDate.year}'),
            backgroundColor: Colors.green,
          ),
        );
      }
      onSuccess();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan tanggal actual: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Hapus tanggal actual (set tglSelesai ke null)
  Future<void> deleteActualDate({
    required MtSchedule schedule,
    required VoidCallback onSuccess,
  }) async {
    try {
      if (schedule.id == null) throw Exception('ID schedule tidak ditemukan');
      
      final updatedSchedule = schedule.copyWith(
        tglSelesai: null,
        status: 'Perlu Maintenance',
        completedBy: null,
      );
      await repository.updateSchedule(schedule.id!, updatedSchedule);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal actual dihapus - status kembali ke Perlu Maintenance'),
            backgroundColor: Colors.green,
          ),
        );
      }
      onSuccess();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus tanggal actual: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
