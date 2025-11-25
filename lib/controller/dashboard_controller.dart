import '../model/dashboard_model.dart';
import '../repositories/asset_supabase_repository.dart';

class DashboardController {
  final AssetSupabaseRepository _assetRepository = AssetSupabaseRepository();

  Future<DashboardStats> getStats() async {
    try {
      // Ambil data dari Supabase
      final assets = await _assetRepository.getAllAssets();

      // Count unique assets berdasarkan nama_assets
      final uniqueAssets = assets.map((a) => a['nama_assets']).toSet().length;

      return DashboardStats(
        totalAssets: uniqueAssets,
        totalKaryawan: 0, // TODO: Implement when karyawan uses Supabase
        pendingRequests: 0, // TODO: Calculate from actual data
        activeMaintenance: 0, // TODO: Calculate from actual data
        overdueSchedule: 0, // TODO: Calculate from actual data
      );
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return DashboardStats(
        totalAssets: 0,
        totalKaryawan: 0,
        pendingRequests: 0,
        activeMaintenance: 0,
        overdueSchedule: 0,
      );
    }
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
