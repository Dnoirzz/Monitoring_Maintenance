import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/providers/auth_provider.dart';
import 'package:shared/utils/name_helper.dart';
import '../../widget/teknisi_sidebar.dart';
import 'pages/scan_qr_page.dart';
import 'pages/ceksheet_menu/today_checksheet_list_page.dart';
import '../login_page.dart';

class TeknisiDashboardPage extends ConsumerStatefulWidget {
  const TeknisiDashboardPage({super.key});

  @override
  ConsumerState<TeknisiDashboardPage> createState() =>
      _TeknisiDashboardPageState();
}

class _TeknisiDashboardPageState extends ConsumerState<TeknisiDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userFullName = authState.userFullName;

    // Tema warna hijau yang sudah ada
    final Color primary = const Color(0xFF0A9C5D);
    final Color textLight = const Color(0xFF0D1C15);
    final Color textSubtle = const Color(0xFF4B9B78);
    final Color bgColor = const Color(0xFFF6F8F7);
    final Color cardColor = Colors.white;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      drawer: TeknisiSidebar(
        primaryColor: primary,
        cardColor: cardColor,
        textPrimary: textLight,
        textSecondary: textSubtle,
        userFullName: userFullName,
        userRole: 'Teknisi',
        onMenuTap: (menuTitle) {
          // TODO: Handle navigation berdasarkan menu yang diklik
          // Contoh:
          // if (menuTitle == 'Formulir Cek Sheet Harian') {
          //   Navigator.push(...);
          // }
        },
        onLogout: () {
          _showLogoutConfirmation(context);
        },
      ),
      body: Column(
        children: [
          // Header
          Container(
            color: bgColor,
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Icon(Icons.menu, color: textSubtle),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      NameHelper.getGreetingWithName(userFullName),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Check Sheet Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check Sheet Harian',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textLight,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '3 check sheet perlu diisi hari ini',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: textSubtle,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Terakhir diperbarui: 10 menit lalu',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textSubtle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const TodayChecksheetListPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Lihat Daftar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Section Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      'Jadwal Maintenance (7 Hari Kedepan)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textLight,
                      ),
                    ),
                  ),

                  // Maintenance List
                  MaintenanceItem(
                    machineName: 'Mesin CNC-01',
                    date: '25 Okt 2024, 08:00',
                    type: 'Preventive Maintenance',
                    cardColor: cardColor,
                    textPrimary: textLight,
                    textSecondary: textSubtle,
                    primaryColor: primary,
                  ),
                  MaintenanceItem(
                    machineName: 'Mesin Bubut-03',
                    date: '26 Okt 2024, 10:00',
                    type: 'Corrective Maintenance',
                    cardColor: cardColor,
                    textPrimary: textLight,
                    textSecondary: textSubtle,
                    primaryColor: primary,
                  ),
                  MaintenanceItem(
                    machineName: 'Mesin Press-02',
                    date: '28 Okt 2024, 14:00',
                    type: 'Preventive Maintenance',
                    cardColor: cardColor,
                    textPrimary: textLight,
                    textSecondary: textSubtle,
                    primaryColor: primary,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: bgColor,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: ElevatedButton(
            onPressed: () {
              // Navigate ke halaman scan QR
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanQRPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.qr_code_scanner, size: 24),
                SizedBox(width: 8),
                Text(
                  'Scan QR Mesin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Menampilkan modal konfirmasi logout
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Konfirmasi Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _handleLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handle proses logout
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0A9C5D)),
                  SizedBox(height: 16),
                  Text(
                    'Logging out...',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Panggil logout dari auth provider
      await ref.read(authProvider.notifier).logout();

      // Tutup loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate ke login page dan clear navigation stack
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }

      // Tampilkan snackbar konfirmasi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anda telah berhasil logout'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Tutup loading dialog jika ada error
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Tampilkan error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class MaintenanceItem extends StatelessWidget {
  final String machineName;
  final String date;
  final String type;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color primaryColor;

  const MaintenanceItem({
    super.key,
    required this.machineName,
    required this.date,
    required this.type,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.calendar_month, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machineName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                  Text(
                    type,
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textSecondary),
          ],
        ),
      ),
    );
  }
}
