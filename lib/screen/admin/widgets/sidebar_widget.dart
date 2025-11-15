import 'package:flutter/material.dart';

class SidebarWidget extends StatelessWidget {
  final bool isOpen;
  final Animation<double> animation;
  final int selectedIndex;
  final int? selectedScheduleSubMenu;
  final bool isScheduleExpanded;
  final Function(int) onMenuSelected;
  final Function() onToggleSchedule;
  final Function(int) onSubMenuSelected;
  final VoidCallback onOverlayTap;

  const SidebarWidget({
    Key? key,
    required this.isOpen,
    required this.animation,
    required this.selectedIndex,
    this.selectedScheduleSubMenu,
    required this.isScheduleExpanded,
    required this.onMenuSelected,
    required this.onToggleSchedule,
    required this.onSubMenuSelected,
    required this.onOverlayTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isOpen) {
      return SizedBox.shrink();
    }

    return Stack(
      children: [
        // Overlay
        GestureDetector(
          onTap: onOverlayTap,
          child: Container(color: Colors.black.withOpacity(0.5)),
        ),

        // Sidebar
        SlideTransition(
          position: Tween<Offset>(
            begin: Offset(-1.0, 0.0),
            end: Offset(0.0, 0.0),
          ).animate(animation),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A9C5D), Color(0xFF022415)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Menu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildMenuItem(Icons.home, "Beranda", 0),
                  _buildMenuItem(Icons.build, "Data Mesin", 1),
                  _buildMenuItem(Icons.group, "Daftar Karyawan", 2),
                  _buildScheduleMenu(),
                  Spacer(),
                  _buildMenuItem(
                    Icons.logout,
                    "Keluar",
                    4,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    int index, {
    Color? color,
  }) {
    bool isSelected = selectedIndex == index;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () => onMenuSelected(index),
      ),
    );
  }

  Widget _buildScheduleMenu() {
    bool isSelected = selectedIndex == 3;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.schedule, color: Colors.white),
            title: Text(
              "Schedule",
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Icon(
              isScheduleExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
            onTap: () => onToggleSchedule(),
          ),
          if (isScheduleExpanded)
            Column(
              children: [
                _buildSubMenuItem(
                  "Maintenance Schedule",
                  31,
                  Icons.build_circle,
                ),
                _buildSubMenuItem("Cek Sheet Schedule", 32, Icons.checklist),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem(String title, int index, IconData icon) {
    bool isSelected = selectedScheduleSubMenu == index;
    return Container(
      margin: EdgeInsets.only(left: 20, right: 10, bottom: 5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => onSubMenuSelected(index),
      ),
    );
  }
}
