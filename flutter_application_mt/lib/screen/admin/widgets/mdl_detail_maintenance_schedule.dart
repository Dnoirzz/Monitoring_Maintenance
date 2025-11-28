import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../model/mt_schedule_model.dart';

class ModalDetailMaintenanceSchedule {
  static void show(
    BuildContext context, {
    required MtSchedule schedule,
    required DateTime date,
    VoidCallback? onEdit,
    VoidCallback? onSetActual,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Asset: ${schedule.assetName ?? '-'}'),
            Text('Bagian: ${schedule.template?.bagianMesinName ?? '-'}'),
            Text('Tanggal: ${DateFormat('dd MMM yyyy').format(date)}'),
            if (schedule.catatan != null)
              Text('Catatan: ${schedule.catatan}'),
          ],
        ),
        actions: [
          if (onSetActual != null)
            ElevatedButton.icon(
              onPressed: onSetActual,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A9C5D),
                foregroundColor: Colors.white,
              ),
              icon: Icon(Icons.event_available),
              label: Text('Isi Tanggal Actual'),
            ),
          if (onEdit != null)
            TextButton(
              onPressed: onEdit,
              child: Text('Edit'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

