import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  final VoidCallback onSelectMaintenance;
  final VoidCallback onSelectCekSheet;

  SchedulePage({
    required this.onSelectMaintenance,
    required this.onSelectCekSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Schedule",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF022415),
          ),
        ),
        SizedBox(height: 30),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildScheduleCard(
                  icon: Icons.build_circle,
                  title: "Maintenance Schedule",
                  subtitle: "Kelola jadwal maintenance mesin",
                  color: Color(0xFF0A9C5D),
                  onTap: onSelectMaintenance,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _buildScheduleCard(
                  icon: Icons.checklist,
                  title: "Cek Sheet Schedule",
                  subtitle: "Kelola cek sheet schedule",
                  color: Color(0xFF0A9C5D),
                  onTap: onSelectCekSheet,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard({
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
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [color, Color(0xFF022415)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.white),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
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
