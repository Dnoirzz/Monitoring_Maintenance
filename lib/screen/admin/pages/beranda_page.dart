import 'package:flutter/material.dart';

class BerandaPage extends StatefulWidget {
  final VoidCallback onNavigateToDataMesin;
  final VoidCallback onNavigateToKaryawan;
  final VoidCallback? onNavigateToMaintenanceSchedule;
  final VoidCallback? onNavigateToCekSheetSchedule;

  BerandaPage({
    required this.onNavigateToDataMesin,
    required this.onNavigateToKaryawan,
    this.onNavigateToMaintenanceSchedule,
    this.onNavigateToCekSheetSchedule,
  });

  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  // Mock data - nanti bisa diganti dengan data dari API
  final int totalAssets = 45;
  final int totalKaryawan = 28;
  final int pendingRequests = 8;
  final int activeMaintenance = 5;
  final int overdueSchedule = 3;
  
  // Track hover state for menu cards
  List<bool> _isMenuHovered = List.generate(4, (index) => false);

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
              Text(
                _getCurrentDate(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
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
              Expanded(
                child: _buildPendingRequestsCard(),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _buildUpcomingScheduleCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.miscellaneous_services_outlined,
            title: "Total Assets",
            value: totalAssets.toString(),
            color: Color(0xFF0A9C5D),
            subtitle: "Aktif: ${totalAssets - 2}",
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.group,
            title: "Total Karyawan",
            value: totalKaryawan.toString(),
            color: Color(0xFF2196F3),
            subtitle: "Aktif: ${totalKaryawan}",
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.build,
            title: "Maintenance Aktif",
            value: activeMaintenance.toString(),
            color: Color(0xFF9C27B0),
            subtitle: "Sedang berjalan",
          ),
        ),
      ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
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
        transform: _isMenuHovered[index]
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
            _buildRequestItem("Breakdown - Mesin Produksi A", "Disetujui", Colors.green, "2 hari lalu"),
            SizedBox(height: 10),
            _buildRequestItem("Cleaning - Alat Berat B", "Disetujui", Colors.green, "5 hari lalu"),
            SizedBox(height: 10),
            _buildRequestItem("Upgrade - Listrik C", "Ditolak", Colors.red, "1 minggu lalu"),
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

  Widget _buildRequestItem(String title, String status, Color statusColor, String date) {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
            if (overdueSchedule > 0)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "$overdueSchedule jadwal terlambat",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 15),
            _buildScheduleItem("Maintenance - Mesin A", "Hari ini", false),
            SizedBox(height: 10),
            _buildScheduleItem("Cek Sheet - Komponen B", "Besok", false),
            SizedBox(height: 10),
            _buildScheduleItem("Maintenance - Mesin C", "2 hari lagi", true),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
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
