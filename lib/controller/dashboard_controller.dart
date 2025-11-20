import '../model/dashboard_model.dart';
import '../model/maintenance_model.dart';
import 'asset_controller.dart';
import 'karyawan_controller.dart';
import 'maintenance_controller.dart';
import 'cek_sheet_controller.dart';

class DashboardController {
  final AssetController assetController;
  final KaryawanController karyawanController;
  final MaintenanceController? maintenanceController;
  final CekSheetController? cekSheetController;

  DashboardController({
    required this.assetController,
    required this.karyawanController,
    this.maintenanceController,
    this.cekSheetController,
  });

  DashboardStats getStats() {
    final assets = assetController.getAllAssets();
    final karyawan = karyawanController.getAllKaryawan();

    // Count unique assets
    final uniqueAssets = assets.map((a) => a.namaAssets).toSet().length;

    // Get active maintenance count
    int activeMaintenance = 0;
    if (maintenanceController != null) {
      activeMaintenance = maintenanceController!.getActiveSchedules().length;
    }

    // Get pending requests count
    int pendingRequests = 0;
    if (maintenanceController != null) {
      pendingRequests = maintenanceController!.getPendingRequests().length;
    }

    // Get overdue schedules count
    int overdueSchedule = 0;
    if (maintenanceController != null) {
      overdueSchedule = maintenanceController!.getOverdueSchedules().length;
    }

    return DashboardStats(
      totalAssets: uniqueAssets,
      totalKaryawan: karyawan.length,
      pendingRequests: pendingRequests,
      activeMaintenance: activeMaintenance,
      overdueSchedule: overdueSchedule,
    );
  }

  List<RequestHistory> getRequestHistory() {
    if (maintenanceController == null) {
      return [];
    }

    final requests = maintenanceController!.getRecentRequests(limit: 5);
    final now = DateTime.now();

    return requests.map((request) {
      String statusText = _getStatusText(request.status);
      String dateText = _formatDateDifference(request.createdAt, now);

      String title = request.judul ?? "Maintenance Request";
      if (request.requestType != null) {
        title = "${_getRequestTypeText(request.requestType!)} - $title";
      }

      return RequestHistory(
        title: title,
        status: statusText,
        date: dateText,
      );
    }).toList();
  }

  List<UpcomingSchedule> getUpcomingSchedules() {
    List<UpcomingSchedule> schedules = [];

    // Get maintenance schedules
    if (maintenanceController != null) {
      final mtSchedules = maintenanceController!.getUpcomingSchedules(days: 7);
      final now = DateTime.now();

      for (var schedule in mtSchedules.take(3)) {
        bool isOverdue = schedule.tglJadwal != null &&
            schedule.tglJadwal!.isBefore(now) &&
            schedule.status != MtSchedStatus.selesai;

        String dateText = schedule.tglJadwal != null
            ? _formatDateDifference(schedule.tglJadwal, now)
            : "Tidak ada jadwal";

        schedules.add(UpcomingSchedule(
          title: "Maintenance - ${_getAssetName(schedule.assetsId)}",
          date: dateText,
          isOverdue: isOverdue,
        ));
      }
    }

    // Get cek sheet schedules
    if (cekSheetController != null) {
      final cekSchedules = cekSheetController!.getUpcomingSchedules(days: 7);
      final now = DateTime.now();

      for (var schedule in cekSchedules.take(3)) {
        bool isOverdue = schedule.tglJadwal != null &&
            schedule.tglJadwal!.isBefore(now);

        String dateText = schedule.tglJadwal != null
            ? _formatDateDifference(schedule.tglJadwal, now)
            : "Tidak ada jadwal";

        schedules.add(UpcomingSchedule(
          title: "Cek Sheet - ${_getTemplateName(schedule.templateId)}",
          date: dateText,
          isOverdue: isOverdue,
        ));
      }
    }

    // Sort by date and take first 5
    schedules.sort((a, b) {
      // Sort overdue first, then by date
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      return 0;
    });

    return schedules.take(5).toList();
  }

  String _getStatusText(ReqStatus? status) {
    switch (status) {
      case ReqStatus.approved:
        return "Disetujui";
      case ReqStatus.rejected:
        return "Ditolak";
      case ReqStatus.inProgress:
        return "Dalam Proses";
      case ReqStatus.completed:
        return "Selesai";
      case ReqStatus.cancelled:
        return "Dibatalkan";
      default:
        return "Pending";
    }
  }

  String _getRequestTypeText(RequestType type) {
    switch (type) {
      case RequestType.breakdown:
        return "Breakdown";
      case RequestType.preventive:
        return "Preventive";
      case RequestType.corrective:
        return "Corrective";
      case RequestType.upgrade:
        return "Upgrade";
      case RequestType.cleaning:
        return "Cleaning";
    }
  }

  String _formatDateDifference(DateTime? date, DateTime now) {
    if (date == null) return "Tidak ada tanggal";

    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return "Baru saja";
      }
      return "${difference.inHours} jam lalu";
    } else if (difference.inDays == 1) {
      return "Kemarin";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} hari lalu";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "$weeks minggu lalu";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "$months bulan lalu";
    } else {
      final years = (difference.inDays / 365).floor();
      return "$years tahun lalu";
    }
  }

  String _getAssetName(String? assetsId) {
    if (assetsId == null) return "Unknown";
    final assets = assetController.getAllAssets();
    try {
      final asset = assets.firstWhere((a) => a.id == assetsId);
      return asset.namaAssets;
    } catch (e) {
      return "Unknown";
    }
  }

  String _getTemplateName(String? templateId) {
    if (templateId == null || cekSheetController == null) return "Unknown";
    final template = cekSheetController!.getTemplateById(templateId);
    return template?.jenisPekerjaan ?? "Unknown";
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

