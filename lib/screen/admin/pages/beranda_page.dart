import 'package:flutter/material.dart';
import 'package:monitoring_maintenance/controller/dashboard_controller.dart';
import 'package:monitoring_maintenance/model/dashboard_model.dart';

class BerandaPage extends StatefulWidget {
  final DashboardController dashboardController;
  final VoidCallback onNavigateToDataMesin;
  final VoidCallback onNavigateToKaryawan;
  final VoidCallback? onNavigateToMaintenanceSchedule;
  final VoidCallback? onNavigateToCekSheetSchedule;

  const BerandaPage({
    super.key,
    required this.dashboardController,
    required this.onNavigateToDataMesin,
    required this.onNavigateToKaryawan,
    this.onNavigateToMaintenanceSchedule,
    this.onNavigateToCekSheetSchedule,
  });

  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  List<bool> _isMenuHovered = List.generate(4, (index) => false);
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // Method public untuk refresh stats dari luar (dipanggil saat add mesin/karyawan atau refresh manual)
  void refreshStats() {
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = widget.dashboardController.getStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF022415),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.refresh, color: Color(0xFF0A9C5D)),
                    onPressed: _loadStats,
                    tooltip: 'Refresh Data',
                  ),
                  SizedBox(width: 8),
                  Text(
                    widget.dashboardController.getCurrentDate(),
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 30),

          // Statistik Cards
          _buildStatsSection(),
          SizedBox(height: 30),

          // Quick Actions / Menu Cards
          Text(
            "Menu Utama",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF022415),
            ),
          ),
          SizedBox(height: 15),
          _buildMenuGrid(),
          SizedBox(height: 30),

          // Recent Activities / Informasi Penting
          Row(
            children: [
              Expanded(child: _buildPendingRequestsCard()),
              SizedBox(width: 20),
              Expanded(child: _buildUpcomingScheduleCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return FutureBuilder<DashboardStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              Expanded(child: _buildLoadingStatCard()),
              SizedBox(width: 15),
              Expanded(child: _buildLoadingStatCard()),
              SizedBox(width: 15),
              Expanded(child: _buildLoadingStatCard()),
            ],
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading stats: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final stats =
            snapshot.data ??
            DashboardStats(
              totalAssets: 0,
              totalKaryawan: 0,
              pendingRequests: 0,
              activeMaintenance: 0,
              overdueSchedule: 0,
            );

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.miscellaneous_services_outlined,
                title: "Total Assets",
                value: stats.totalAssets.toString(),
                color: Color(0xFF0A9C5D),
                subtitle: "Terdaftar di sistem",
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                icon: Icons.group,
                title: "Total Karyawan",
                value: stats.totalKaryawan.toString(),
                color: Color(0xFF2196F3),
                subtitle: "Aktif: ${stats.totalKaryawan}",
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                icon: Icons.build,
                title: "Maintenance Aktif",
                value: stats.activeMaintenance.toString(),
                color: Color(0xFF9C27B0),
                subtitle: "Sedang berjalan",
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingStatCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(20),
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A9C5D)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF022415),
              ),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.2,
      children: [
        _buildMenuCard(
          index: 0,
          icon: Icons.miscellaneous_services_outlined,
          title: "Data Assets",
          subtitle: "Kelola data assets",
          color: Color(0xFF0A9C5D),
          onTap: widget.onNavigateToDataMesin,
        ),
        _buildMenuCard(
          index: 1,
          icon: Icons.group,
          title: "Daftar Karyawan",
          subtitle: "Kelola data karyawan",
          color: Color(0xFF0A9C5D),
          onTap: widget.onNavigateToKaryawan,
        ),
        _buildMenuCard(
          index: 2,
          icon: Icons.build_circle,
          title: "Maintenance Schedule",
          subtitle: "Jadwal maintenance",
          color: Color(0xFF0A9C5D),
          onTap: widget.onNavigateToMaintenanceSchedule ?? () {},
        ),
        _buildMenuCard(
          index: 3,
          icon: Icons.checklist,
          title: "Cek Sheet Schedule",
          subtitle: "Jadwal cek sheet",
          color: Color(0xFF0A9C5D),
          onTap: widget.onNavigateToCekSheetSchedule ?? () {},
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isMenuHovered[index] = true),
      onExit: (_) => setState(() => _isMenuHovered[index] = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform:
            _isMenuHovered[index]
                ? (Matrix4.identity()..translate(0.0, -10.0))
                : Matrix4.identity(),
        child: Card(
          elevation: _isMenuHovered[index] ? 12 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [color, Color(0xFF022415)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 50, color: Colors.white),
                  SizedBox(height: 15),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingRequestsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Color(0xFFFF9800), size: 24),
                SizedBox(width: 10),
                Text(
                  "Request History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF022415),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            ...widget.dashboardController.getRequestHistory().map((request) {
              Color statusColor =
                  request.status == "Disetujui" ? Colors.green : Colors.red;
              return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _buildRequestItem(
                  request.title,
                  request.status,
                  statusColor,
                  request.date,
                ),
              );
            }),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to all requests
              },
              child: Text("Lihat Semua →"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(
    String title,
    String status,
    Color statusColor,
    String date,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF022415),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingScheduleCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Color(0xFF9C27B0), size: 24),
                SizedBox(width: 10),
                Text(
                  "Jadwal Mendatang",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF022415),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            SizedBox(height: 15),
            ...widget.dashboardController.getUpcomingSchedules().map((
              schedule,
            ) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _buildScheduleItem(
                  schedule.title,
                  schedule.date,
                  schedule.isOverdue,
                ),
              );
            }),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to all schedules
              },
              child: Text("Lihat Semua →"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String title, String date, bool isOverdue) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.orange.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverdue ? Colors.orange.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOverdue ? Colors.orange : Color(0xFF0A9C5D),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF022415),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
