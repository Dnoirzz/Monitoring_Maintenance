import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Teknis',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1392EC),
        scaffoldBackgroundColor: const Color(0xFFF6F7F8),
        fontFamily: 'Manrope',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1392EC),
        scaffoldBackgroundColor: const Color(0xFF101A22),
        fontFamily: 'Manrope',
      ),
      themeMode: ThemeMode.dark,
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF101A22) : const Color(0xFFF6F7F8);
    final cardColor = isDark ? const Color(0xFF192833) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final textSecondary =
        isDark ? const Color(0xFF92B2C9) : const Color(0xFF6B7280);
    final primaryColor = const Color(0xFF1392EC);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      drawer: _buildDrawer(
        context,
        isDark,
        cardColor,
        textPrimary,
        textSecondary,
        primaryColor,
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
                      child: Icon(Icons.menu, color: textSecondary),
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
                      color: textSecondary,
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
                      'Selamat datang, Budi Setiawan!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
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
                              color: textPrimary,
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
                                        color: textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Terakhir diperbarui: 10 menit lalu',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
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
                        color: textPrimary,
                      ),
                    ),
                  ),

                  // Maintenance List
                  MaintenanceItem(
                    machineName: 'Mesin CNC-01',
                    date: '25 Okt 2024, 08:00',
                    type: 'Preventive Maintenance',
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    primaryColor: primaryColor,
                  ),
                  MaintenanceItem(
                    machineName: 'Mesin Bubut-03',
                    date: '26 Okt 2024, 10:00',
                    type: 'Corrective Maintenance',
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    primaryColor: primaryColor,
                  ),
                  MaintenanceItem(
                    machineName: 'Mesin Press-02',
                    date: '28 Okt 2024, 14:00',
                    type: 'Preventive Maintenance',
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    primaryColor: primaryColor,
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
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
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

  Widget _buildDrawer(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color primaryColor,
  ) {
    return Drawer(
      backgroundColor: cardColor,
      child: Column(
        children: [
          // User Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? const Color(0xFF101A22)
                              : const Color(0xFFF6F7F8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, size: 28, color: textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budi Setiawan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Teknisi',
                          style: TextStyle(fontSize: 14, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  isActive: true,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  primaryColor: primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  icon: Icons.checklist,
                  title: 'Formulir Cek Sheet Harian',
                  isActive: false,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  primaryColor: primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  icon: Icons.calendar_month,
                  title: 'Jadwal Maintenance Penuh',
                  isActive: false,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  primaryColor: primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  icon: Icons.build,
                  title: 'Permintaan Maintenance',
                  isActive: false,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  primaryColor: primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  icon: Icons.precision_manufacturing,
                  title: 'Detail Mesin',
                  isActive: false,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  primaryColor: primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red.withOpacity(0.1),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isActive ? primaryColor.withOpacity(0.15) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? primaryColor : textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? primaryColor : textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
