import 'package:flutter/material.dart';
import 'package:monitoring_maintenance/screen/admin/widgets/header_widget.dart';
import 'package:monitoring_maintenance/screen/admin/widgets/sidebar_widget.dart';
import 'package:monitoring_maintenance/screen/admin/pages/beranda_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/data_assets_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/daftar_karyawan_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/maintenance_schedule_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/cek_sheet_schedule_page.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminTemplate(),
    );
  }
}

class AdminTemplate extends StatefulWidget {
  const AdminTemplate({super.key});

  @override
  _AdminTemplateState createState() => _AdminTemplateState();
}

class _AdminTemplateState extends State<AdminTemplate>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  int? selectedScheduleSubMenu; // null, 31 (Maintenance), 32 (Cek Sheet)
  bool _isSidebarOpen = false;
  bool _isScheduleExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      if (_isSidebarOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleMenuSelected(int index) {
    setState(() {
      selectedIndex = index;
      if (index == 3) {
        // Untuk Schedule, expand dropdown
        _isScheduleExpanded = true;
        selectedScheduleSubMenu = null;
      } else if (index == 4) {
        // Logout action
        // Add your logout logic here
      } else {
        _toggleSidebar();
      }
    });
  }

  void _handleSubMenuSelected(int index) {
    setState(() {
      selectedIndex = 3;
      selectedScheduleSubMenu = index;
      _toggleSidebar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ========================== MAIN CONTENT ==========================
          Column(
            children: [
              // ====================== HEADER ======================
              HeaderWidget(
                title: "Selamat Datang, Admin",
                onMenuPressed: _toggleSidebar,
              ),

              // ====================== CONTENT ======================
              Expanded(
                child: Container(
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: getSelectedPage(),
                  ),
                ),
              ),
            ],
          ),

          // ========================== SIDEBAR ==========================
          SidebarWidget(
            isOpen: _isSidebarOpen,
            animation: _animation,
            selectedIndex: selectedIndex,
            selectedScheduleSubMenu: selectedScheduleSubMenu,
            isScheduleExpanded: _isScheduleExpanded,
            onMenuSelected: _handleMenuSelected,
            onToggleSchedule: () {
              setState(() {
                _isScheduleExpanded = !_isScheduleExpanded;
              });
            },
            onSubMenuSelected: _handleSubMenuSelected,
            onOverlayTap: _toggleSidebar,
          ),
        ],
      ),
    );
  }

  // Halaman yang dipilih
  Widget getSelectedPage() {
    switch (selectedIndex) {
      case 1:
        return DataMesinPage();
      case 2:
        return DaftarKaryawanPage();
      case 3:
        if (selectedScheduleSubMenu == 31) {
          return MaintenanceSchedulePage();
        } else if (selectedScheduleSubMenu == 32) {
          return CekSheetSchedulePage();
        } else {
          // Jika tidak ada sub menu dipilih, tampilkan halaman kosong
          return Container();
        }
      default:
        return BerandaPage(
          onNavigateToDataMesin: () {
            setState(() {
              selectedIndex = 1;
            });
          },
          onNavigateToKaryawan: () {
            setState(() {
              selectedIndex = 2;
            });
          },
          onNavigateToMaintenanceSchedule: () {
            setState(() {
              selectedIndex = 3;
              selectedScheduleSubMenu = 31;
            });
          },
          onNavigateToCekSheetSchedule: () {
            setState(() {
              selectedIndex = 3;
              selectedScheduleSubMenu = 32;
            });
          },
        );
    }
  }
}
