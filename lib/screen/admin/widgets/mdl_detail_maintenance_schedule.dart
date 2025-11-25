import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../model/mt_schedule_model.dart';

class ModalDetailMaintenanceSchedule {
  static void show(
    BuildContext context, {
    required MtSchedule schedule,
    required DateTime date,
    VoidCallback? onEdit,
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
            Text('Status: ${schedule.status}'),
            if (schedule.catatan != null)
              Text('Catatan: ${schedule.catatan}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onEdit != null) onEdit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0A9C5D),
              foregroundColor: Colors.white,
            ),
            child: Text('Edit'),
          ),
        ],
      ),
    );
  }
}

