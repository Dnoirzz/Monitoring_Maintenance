import '../model/dashboard_model.dart';
import 'asset_controller.dart';
import 'karyawan_controller.dart';

class DashboardController {
  final AssetController assetController;
  final KaryawanController karyawanController;

  DashboardController({
    required this.assetController,
    required this.karyawanController,
  });

  DashboardStats getStats() {
    final assets = assetController.getAllAssets();
    final karyawan = karyawanController.getAllKaryawan();

    // Count unique assets
    final uniqueAssets = assets.map((a) => a.namaAset).toSet().length;

    return DashboardStats(
      totalAssets: uniqueAssets,
      totalKaryawan: karyawan.length,
      pendingRequests: 8, // This could be calculated from actual data
      activeMaintenance: 5, // This could be calculated from actual data
      overdueSchedule: 3, // This could be calculated from actual data
    );
  }

  List<RequestHistory> getRequestHistory() {
    return [
      RequestHistory(
        title: "Breakdown - Mesin Produksi A",
        status: "Disetujui",
        date: "2 hari lalu",
      ),
      RequestHistory(
        title: "Cleaning - Alat Berat B",
        status: "Disetujui",
        date: "5 hari lalu",
      ),
      RequestHistory(
        title: "Upgrade - Listrik C",
        status: "Ditolak",
        date: "1 minggu lalu",
      ),
    ];
  }

  List<UpcomingSchedule> getUpcomingSchedules() {
    return [
      UpcomingSchedule(
        title: "Maintenance - Mesin A",
        date: "Hari ini",
        isOverdue: false,
      ),
      UpcomingSchedule(
        title: "Cek Sheet - Komponen B",
        date: "Besok",
        isOverdue: false,
      ),
      UpcomingSchedule(
        title: "Maintenance - Mesin C",
        date: "2 hari lagi",
        isOverdue: true,
      ),
    ];
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

