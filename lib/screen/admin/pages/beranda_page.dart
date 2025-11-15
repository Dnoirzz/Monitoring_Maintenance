import 'package:flutter/material.dart';

class BerandaPage extends StatelessWidget {
  final VoidCallback onNavigateToDataMesin;
  final VoidCallback onNavigateToKaryawan;
  final VoidCallback onNavigateToSchedule;

  BerandaPage({
    required this.onNavigateToDataMesin,
    required this.onNavigateToKaryawan,
    required this.onNavigateToSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dashboard Admin",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF022415),
          ),
        ),
        SizedBox(height: 30),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.2,
            children: [
              _buildCard(
                icon: Icons.build,
                title: "Data Mesin",
                subtitle: "Kelola data mesin",
                color: Color(0xFF0A9C5D),
                onTap: onNavigateToDataMesin,
              ),
              _buildCard(
                icon: Icons.group,
                title: "Daftar Karyawan",
                subtitle: "Kelola data karyawan",
                color: Color(0xFF0A9C5D),
                onTap: onNavigateToKaryawan,
              ),
              _buildCard(
                icon: Icons.schedule,
                title: "Schedule",
                subtitle: "Kelola jadwal maintenance",
                color: Color(0xFF0A9C5D),
                onTap: onNavigateToSchedule,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
