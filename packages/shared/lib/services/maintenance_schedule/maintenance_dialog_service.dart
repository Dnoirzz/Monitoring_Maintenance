import 'package:flutter/material.dart';
import 'package:shared/models/mt_schedule_model.dart';
import 'package:shared/repositories/maintenance_schedule_repository.dart';

/// Callback functions untuk dialog operations
typedef OnPlanDateEdited = Future<void> Function(MtSchedule);
typedef OnActualDateSet = Future<void> Function(MtSchedule);
typedef OnActualDateDeleted = Future<void> Function(MtSchedule);

/// Service untuk menampilkan dialog dan handle user interactions
class MaintenanceDialogService {
  final MaintenanceScheduleRepository repository;
  final BuildContext context;

  MaintenanceDialogService({
    required this.repository,
    required this.context,
  });

  /// Tampilkan context menu untuk PLAN row
  void showPlanContextMenu({
    required MtSchedule schedule,
    required VoidCallback onTambahActual,
    required VoidCallback onUbahTanggal,
  }) {
    final isCompleted = schedule.tglSelesai != null && 
                        schedule.status.toLowerCase() == 'selesai';
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.edit_calendar, 
              color: isCompleted ? Colors.blue : const Color(0xFF0A9C5D),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCompleted ? 'Detail Maintenance (Selesai)' : 'Edit Tanggal Plan'
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${schedule.assetName} - ${schedule.template?.bagianMesinName}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            if (isCompleted) ...[
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan:',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                        Text(
                          '${schedule.tglJadwal!.day}-${schedule.tglJadwal!.month}-${schedule.tglJadwal!.year}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Actual:',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                        Text(
                          '${schedule.tglSelesai!.day}-${schedule.tglSelesai!.month}-${schedule.tglSelesai!.year}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Plan: ${schedule.tglJadwal != null ? '${schedule.tglJadwal!.day}-${schedule.tglJadwal!.month}-${schedule.tglJadwal!.year}' : '-'}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          if (!isCompleted) ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                onTambahActual();
              },
              icon: const Icon(Icons.add_circle),
              label: const Text('Tambah Actual'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                onUbahTanggal();
              },
              icon: const Icon(Icons.event),
              label: const Text('Ubah Tanggal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A9C5D),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Tampilkan context menu untuk ACTUAL row
  void showActualContextMenu({
    required MtSchedule schedule,
    required VoidCallback onSetActual,
    required VoidCallback onDeleteActual,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF0A9C5D)),
            const SizedBox(width: 12),
            Expanded(child: const Text('Tanggal Actual')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${schedule.assetName} - ${schedule.template?.bagianMesinName}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              schedule.tglSelesai != null
                  ? 'Tanggal actual: ${schedule.tglSelesai!.day}-${schedule.tglSelesai!.month}-${schedule.tglSelesai!.year}'
                  : 'Belum ada tanggal actual',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tanggal actual dapat dipilih kapan saja, termasuk sebelum tanggal plan',
                      style: TextStyle(fontSize: 9, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          if (schedule.tglSelesai != null) ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                onDeleteActual();
              },
              icon: const Icon(Icons.delete),
              label: const Text('Hapus'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              onSetActual();
            },
            icon: const Icon(Icons.event),
            label: Text(schedule.tglSelesai != null ? 'Edit' : 'Set Tanggal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A9C5D),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilkan dialog konfirmasi hapus
  Future<bool?> showDeleteConfirmation({
    required String title,
    required String message,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  /// Tampilkan snackbar
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.green,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
