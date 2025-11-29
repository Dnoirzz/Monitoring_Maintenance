import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monitoring_maintenance/model/maintenance_request_model.dart';
import 'package:monitoring_maintenance/model/mt_schedule_model.dart';
import 'package:monitoring_maintenance/model/cek_sheet_schedule_model.dart';
import 'package:monitoring_maintenance/providers/auth_provider.dart';
import 'package:monitoring_maintenance/services/teknisi/technician_dashboard_service.dart';
import 'package:monitoring_maintenance/screen/teknisi/pages/laporan_kerusakan.dart';
import 'package:monitoring_maintenance/utils/name_helper.dart';

class TeknisiDashboardPage extends ConsumerStatefulWidget {
  const TeknisiDashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TeknisiDashboardPage> createState() =>
      _TeknisiDashboardPageState();
}

class _TeknisiDashboardPageState extends ConsumerState<TeknisiDashboardPage>
    with SingleTickerProviderStateMixin {
  final TechnicianDashboardService _dashboardService =
      TechnicianDashboardService();
  late Future<List<dynamic>> _todayTasksFuture;
  late Future<List<dynamic>> _upcomingTasksFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _todayTasksFuture = _dashboardService.fetchTodayTasks();
      _upcomingTasksFuture = _dashboardService.fetchUpcomingTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userFullName = authState.userFullName;
    final Color primary = const Color(0xFF0A9C5D);
    final Color textLight = const Color(0xFF0D1C15);
    final Color textSubtle = const Color(0xFF4B9B78);
    final Color cardLight = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: primary,
                              child: Text(
                                NameHelper.getInitials(userFullName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          color: textLight,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NameHelper.getGreetingWithName(userFullName),
                      style: TextStyle(
                        color: textLight,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<List<dynamic>>(
                      future: _todayTasksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            'Memuat tugas...',
                            style: TextStyle(color: textSubtle, fontSize: 16),
                          );
                        }
                        final count = snapshot.data?.length ?? 0;
                        return Text(
                          'Anda memiliki $count tugas hari ini.',
                          style: TextStyle(color: textSubtle, fontSize: 16),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFFCFE8DD)),
                  ),
                ),
                child: TabBar(
                  labelColor: textLight,
                  unselectedLabelColor: textSubtle,
                  indicatorColor: primary,
                  tabs: const [
                    Tab(text: 'Tugas Hari Ini'),
                    Tab(text: 'Jadwal Mendatang'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _TasksList(
                      future: _todayTasksFuture,
                      onRefresh: () async => _refreshData(),
                      primary: primary,
                      textLight: textLight,
                      cardLight: cardLight,
                      textSubtle: textSubtle,
                    ),
                    _UpcomingList(
                      future: _upcomingTasksFuture,
                      onRefresh: () async => _refreshData(),
                      primary: primary,
                      textLight: textLight,
                      cardLight: cardLight,
                      textSubtle: textSubtle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LaporanKerusakanPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Lapor Kerusakan'),
      ),
    );
  }
}

class _TasksList extends StatelessWidget {
  final Future<List<dynamic>> future;
  final RefreshCallback onRefresh;
  final Color primary;
  final Color textLight;
  final Color cardLight;
  final Color textSubtle;

  const _TasksList({
    Key? key,
    required this.future,
    required this.onRefresh,
    required this.primary,
    required this.textLight,
    required this.cardLight,
    required this.textSubtle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return Center(
            child: Text(
              'Tidak ada tugas hari ini',
              style: TextStyle(color: textSubtle),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(task);
            },
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(dynamic task) {
    String imageUrl = 'https://via.placeholder.com/300'; // Default
    String lokasi = 'Unknown Location';
    String judul = 'Unknown Task';
    String jenis = 'Unknown Type';
    String? tanggal;
    Color statusColor = Colors.grey;
    String statusText = 'Unknown';

    if (task is MtSchedule) {
      imageUrl = task.asset?['foto'] ?? imageUrl;
      lokasi = task.asset?['jenis_assets'] ?? 'Unknown Category';
      judul = task.asset?['nama_assets'] ?? 'Unknown Asset';
      jenis = 'Perawatan Terjadwal';
      tanggal =
          task.tglJadwal != null
              ? '${task.tglJadwal!.day}/${task.tglJadwal!.month}/${task.tglJadwal!.year}'
              : null;
      statusColor = Colors.blue;
      statusText = task.status;
    } else if (task is MaintenanceRequest) {
      imageUrl = task.asset?['foto'] ?? imageUrl;
      lokasi = task.asset?['jenis_assets'] ?? 'Unknown Category';
      judul = task.asset?['nama_assets'] ?? 'Unknown Asset';
      jenis = 'Perbaikan Mendesak';
      statusColor = Colors.red;
      statusText = task.status;
    } else if (task is CekSheetSchedule) {
      // Cek Sheet doesn't have direct asset link in model yet, maybe via template -> komponen -> asset?
      // For now, use template title
      judul = task.title ?? 'Check Sheet';
      jenis = 'Cek Sheet';
      tanggal =
          task.tglJadwal != null
              ? '${task.tglJadwal!.day}/${task.tglJadwal!.month}/${task.tglJadwal!.year}'
              : null;
      statusColor = Colors.orange;
      statusText = 'Scheduled';
    }

    return _TaskCard(
      imageUrl: imageUrl,
      lokasi: lokasi,
      judul: judul,
      jenis: jenis,
      tanggal: tanggal,
      statusColor: statusColor,
      statusText: statusText,
      primary: primary,
      textLight: textLight,
      cardLight: cardLight,
      textSubtle: textSubtle,
    );
  }
}

class _UpcomingList extends StatelessWidget {
  final Future<List<dynamic>> future;
  final RefreshCallback onRefresh;
  final Color primary;
  final Color textLight;
  final Color cardLight;
  final Color textSubtle;

  const _UpcomingList({
    Key? key,
    required this.future,
    required this.onRefresh,
    required this.primary,
    required this.textLight,
    required this.cardLight,
    required this.textSubtle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return Center(
            child: Text(
              'Tidak ada jadwal mendatang',
              style: TextStyle(color: textSubtle),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(task);
            },
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(dynamic task) {
    String imageUrl = 'https://via.placeholder.com/300'; // Default
    String lokasi = 'Unknown Location';
    String judul = 'Unknown Task';
    String jenis = 'Unknown Type';
    String? tanggal;
    Color statusColor = Colors.grey;
    String statusText = 'Unknown';

    if (task is MtSchedule) {
      imageUrl = task.asset?['foto'] ?? imageUrl;
      lokasi = task.asset?['jenis_assets'] ?? 'Unknown Category';
      judul = task.asset?['nama_assets'] ?? 'Unknown Asset';
      jenis = 'Perawatan Terjadwal';
      tanggal =
          task.tglJadwal != null
              ? '${task.tglJadwal!.day}/${task.tglJadwal!.month}/${task.tglJadwal!.year}'
              : null;
      statusColor = Colors.blue;
      statusText = task.status;
    } else if (task is CekSheetSchedule) {
      judul = task.title ?? 'Check Sheet';
      jenis = 'Cek Sheet';
      tanggal =
          task.tglJadwal != null
              ? '${task.tglJadwal!.day}/${task.tglJadwal!.month}/${task.tglJadwal!.year}'
              : null;
      statusColor = Colors.orange;
      statusText = 'Scheduled';
    }

    return _TaskCard(
      imageUrl: imageUrl,
      lokasi: lokasi,
      judul: judul,
      jenis: jenis,
      tanggal: tanggal,
      statusColor: statusColor,
      statusText: statusText,
      primary: primary,
      textLight: textLight,
      cardLight: cardLight,
      textSubtle: textSubtle,
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String imageUrl;
  final String lokasi;
  final String judul;
  final String jenis;
  final String? tanggal;
  final Color statusColor;
  final String statusText;
  final Color primary;
  final Color textLight;
  final Color cardLight;
  final Color textSubtle;

  const _TaskCard({
    Key? key,
    required this.imageUrl,
    required this.lokasi,
    required this.judul,
    required this.jenis,
    this.tanggal,
    required this.statusColor,
    required this.statusText,
    required this.primary,
    required this.textLight,
    required this.cardLight,
    required this.textSubtle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi: $lokasi',
                  style: TextStyle(color: textSubtle, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  judul,
                  style: TextStyle(
                    color: textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenis: $jenis',
                      style: TextStyle(color: textSubtle, fontSize: 16),
                    ),
                    if (tanggal != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tanggal: $tanggal',
                        style: TextStyle(color: textSubtle, fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Mulai Kerjakan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
