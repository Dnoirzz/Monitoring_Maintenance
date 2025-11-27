import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monitoring_maintenance/screen/admin/widgets/header_widget.dart';
import 'package:monitoring_maintenance/screen/admin/widgets/sidebar_widget.dart';
import 'package:monitoring_maintenance/screen/admin/pages/beranda_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/data_assets_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/daftar_karyawan_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/maintenance_schedule_page.dart';
import 'package:monitoring_maintenance/screen/admin/pages/cek_sheet_schedule_page.dart';
import 'package:monitoring_maintenance/controller/admin_controller.dart';
import 'package:monitoring_maintenance/controller/asset_controller.dart';
import 'package:monitoring_maintenance/controller/check_sheet_controller.dart';
import 'package:monitoring_maintenance/controller/karyawan_controller.dart';
import 'package:monitoring_maintenance/controller/dashboard_controller.dart';
import 'package:monitoring_maintenance/providers/auth_provider.dart';
import 'package:monitoring_maintenance/services/supabase_service.dart';
 

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

class AdminTemplate extends ConsumerStatefulWidget {
  const AdminTemplate({super.key});

  @override
  ConsumerState<AdminTemplate> createState() => _AdminTemplateState();
}

class _AdminTemplateState extends ConsumerState<AdminTemplate>
    with SingleTickerProviderStateMixin {
  late AdminController _adminController;
  late AssetController _assetController;
  late CheckSheetController _checkSheetController;
  late KaryawanController _karyawanController;
  late DashboardController _dashboardController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _assetController = AssetController();
    _checkSheetController = CheckSheetController();
    // Sample data removed - data will be loaded from Supabase
    _karyawanController = KaryawanController();
    _dashboardController = DashboardController();
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

    // Handle logout
    if (index == 4) {
      _showLogoutDialog();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Keluar'),
          content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout();
              },
              child: Text(
                'Keluar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Close sidebar
      setState(() {
        _adminController.isSidebarOpen = false;
        _animationController.reverse();
      });

      // Sign out from Supabase (if using Supabase auth)
      try {
        await SupabaseService.instance.signOut();
      } catch (e) {
        // Ignore Supabase signOut errors if not using Supabase auth
      }

      // Logout from auth provider (clears storage and resets state)
      await ref.read(authProvider.notifier).logout();

      // Navigation will be handled automatically by main.dart
      // based on authState.isAuthenticated
    } catch (e) {
      // Show error if logout fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal keluar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        return DaftarKaryawanPage(
          karyawanController: _karyawanController,
          dashboardController: _dashboardController,
        );
      case 3:
        if (_adminController.selectedScheduleSubMenu == 31) {
          return const MaintenanceSchedulePage();
        } else if (_adminController.selectedScheduleSubMenu == 32) {
          return CekSheetSchedulePage(
            checkSheetController: _checkSheetController,
          );
        } else {
          // Jika tidak ada sub menu dipilih, tampilkan halaman kosong
          return Container();
        }
      default:
        return BerandaPage(
          key: ValueKey('beranda'), // Key tetap untuk memungkinkan refresh
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
