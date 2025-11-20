import 'package:flutter/material.dart';
import 'package:monitoring_maintenance/screen/admin/widgets/header_widget.dart';
import 'package:monitoring_maintenance/screen/admin/widgets/sidebar_widget.dart';
import 'package:monitoring_maintenance/screen/admin/pages/beranda_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/data_assets_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/daftar_karyawan_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/maintenance_schedule_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/cek_sheet_schedule_page.dart';
import 'package:monitoring_maintenance/controller/admin_controller.dart';
import 'package:monitoring_maintenance/controller/asset_controller.dart';
import 'package:monitoring_maintenance/controller/karyawan_controller.dart';
import 'package:monitoring_maintenance/controller/maintenance_controller.dart';
import 'package:monitoring_maintenance/controller/cek_sheet_controller.dart';
import 'package:monitoring_maintenance/controller/dashboard_controller.dart';

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
  late AdminController _adminController;
  late AssetController _assetController;
  late KaryawanController _karyawanController;
  late MaintenanceController _maintenanceController;
  late CekSheetController _cekSheetController;
  late DashboardController _dashboardController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _assetController = AssetController();
    _karyawanController = KaryawanController();
    _maintenanceController = MaintenanceController();
    _cekSheetController = CekSheetController();
    _dashboardController = DashboardController(
      assetController: _assetController,
      karyawanController: _karyawanController,
      maintenanceController: _maintenanceController,
      cekSheetController: _cekSheetController,
    );
    _adminController = AdminController();

    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Load data from Supabase
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _assetController.initialize();
      await _karyawanController.initialize();
      await _maintenanceController.initialize();
      await _cekSheetController.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading data: $e');
      // Fallback to sample data if Supabase fails
      _assetController.initializeSampleData();
      _karyawanController.initializeSampleData();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _adminController.toggleSidebar();
      if (_adminController.isSidebarOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleMenuSelected(int index) {
    setState(() {
      _adminController.handleMenuSelected(index);
      if (_adminController.isSidebarOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleSubMenuSelected(int index) {
    setState(() {
      _adminController.handleSubMenuSelected(index);
      if (_adminController.isSidebarOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
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
            isOpen: _adminController.isSidebarOpen,
            animation: _animation,
            selectedIndex: _adminController.selectedIndex,
            selectedScheduleSubMenu: _adminController.selectedScheduleSubMenu,
            isScheduleExpanded: _adminController.isScheduleExpanded,
            onMenuSelected: _handleMenuSelected,
            onToggleSchedule: () {
              setState(() {
                _adminController.toggleSchedule();
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
    switch (_adminController.selectedIndex) {
      case 1:
        return DataMesinPage(assetController: _assetController);
      case 2:
        return DaftarKaryawanPage(karyawanController: _karyawanController);
      case 3:
        if (_adminController.selectedScheduleSubMenu == 31) {
          return MaintenanceSchedulePage();
        } else if (_adminController.selectedScheduleSubMenu == 32) {
          return CekSheetSchedulePage(
            cekSheetController: _cekSheetController,
            assetController: _assetController,
          );
        } else {
          // Jika tidak ada sub menu dipilih, tampilkan halaman kosong
          return Container();
        }
      default:
        return BerandaPage(
          dashboardController: _dashboardController,
          onNavigateToDataMesin: () {
            setState(() {
              _adminController.navigateToDataMesin();
            });
          },
          onNavigateToKaryawan: () {
            setState(() {
              _adminController.navigateToKaryawan();
            });
          },
          onNavigateToMaintenanceSchedule: () {
            setState(() {
              _adminController.navigateToMaintenanceSchedule();
            });
          },
          onNavigateToCekSheetSchedule: () {
            setState(() {
              _adminController.navigateToCekSheetSchedule();
            });
          },
        );
    }
  }
}
