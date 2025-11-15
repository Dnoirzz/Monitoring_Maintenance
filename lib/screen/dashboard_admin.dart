import 'package:flutter/material.dart';

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminTemplate(),
    );
  }
}

class AdminTemplate extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ========================== MAIN CONTENT ==========================
          Column(
            children: [
              // ====================== HEADER ======================
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A9C5D), Color(0xFF022415)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.menu, color: Colors.white),
                      onPressed: _toggleSidebar,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Selamat Datang, Admin",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF0A9C5D)),
                    ),
                  ],
                ),
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

          // ========================== SIDEBAR OVERLAY ==========================
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

          // ========================== SIDEBAR ==========================
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset(-1.0, 0.0),
              end: Offset(0.0, 0.0),
            ).animate(_animation),
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
                    menuItem(Icons.home, "Beranda", 0),
                    menuItem(Icons.build, "Data Mesin", 1),
                    menuItem(Icons.group, "Daftar Karyawan", 2),
                    _buildScheduleMenu(),
                    Spacer(),
                    menuItem(Icons.logout, "Keluar", 4, color: Colors.red.shade300),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Menu Item Builder
  Widget menuItem(IconData icon, String title, int index, {Color? color}) {
    bool isSelected = selectedIndex == index;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () {
          setState(() {
            selectedIndex = index;
            if (index == 4) {
              // Logout action
              // Add your logout logic here
            } else {
              _toggleSidebar();
            }
          });
        },
      ),
    );
  }

  // Schedule Menu dengan Dropdown
  Widget _buildScheduleMenu() {
    bool isSelected = selectedIndex == 3;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.schedule,
              color: Colors.white,
            ),
            title: Text(
              "Schedule",
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Icon(
              _isScheduleExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
            onTap: () {
              setState(() {
                _isScheduleExpanded = !_isScheduleExpanded;
                if (!_isScheduleExpanded) {
                  selectedIndex = 3;
                  selectedScheduleSubMenu = null;
                }
              });
            },
          ),
          if (_isScheduleExpanded)
            Column(
              children: [
                _buildSubMenuItem(
                  "Maintenance Schedule",
                  31,
                  Icons.build_circle,
                ),
                _buildSubMenuItem(
                  "Cek Sheet Schedule",
                  32,
                  Icons.checklist,
                ),
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
        color: isSelected
            ? Colors.white.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            selectedIndex = 3;
            selectedScheduleSubMenu = index;
            _toggleSidebar();
          });
        },
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
          return SchedulePage(
            onSelectMaintenance: () {
              setState(() {
                selectedScheduleSubMenu = 31;
              });
            },
            onSelectCekSheet: () {
              setState(() {
                selectedScheduleSubMenu = 32;
              });
            },
          );
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
          onNavigateToSchedule: () {
            setState(() {
              selectedIndex = 3;
            });
          },
        );
    }
  }
}

//////////////////////////////////////////////////////////////////
//                        BERANDA PAGE
//////////////////////////////////////////////////////////////////

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
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
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

//////////////////////////////////////////////////////////////////
//                        DATA MESIN PAGE
//////////////////////////////////////////////////////////////////

class DataMesinPage extends StatelessWidget {
  final List<Map<String, String>> mesinData = [
    {
      "nama": "Creeper 1",
      "kode": "CRP-001",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
    },
    {
      "nama": "Creeper 2",
      "kode": "CRP-002",
      "maintenance_terakhir": "10 Januari 2024",
      "maintenance_selanjutnya": "10 Februari 2024",
    },
    {
      "nama": "Mixing Machine",
      "kode": "MIX-001",
      "maintenance_terakhir": "5 Januari 2024",
      "maintenance_selanjutnya": "5 Februari 2024",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Data Mesin",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF022415),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Add your add machine logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Fitur Tambah Data Mesin")),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Tambah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A9C5D),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        // ================= TABLE ==================
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Color(0xFF0A9C5D).withOpacity(0.1),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        "Nama Mesin",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Kode Mesin",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Tanggal Maintenance Terakhir",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Tanggal Maintenance Selanjutnya",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: mesinData
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(Text(item["nama"]!)),
                            DataCell(Text(item["kode"]!)),
                            DataCell(Text(item["maintenance_terakhir"]!)),
                            DataCell(Text(item["maintenance_selanjutnya"]!)),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////
//                        DAFTAR KARYAWAN
//////////////////////////////////////////////////////////////////

class DaftarKaryawanPage extends StatelessWidget {
  final List<Map<String, String>> karyawan = [
    {
      "nama": "Ramadhan F",
      "mesin": "Creeper 1",
      "telp": "08123456789",
      "email": "ramadhan@example.com",
      "password": "******",
    },
    {
      "nama": "Adityo Saputro",
      "mesin": "Mixing Machine",
      "telp": "087812345678",
      "email": "adityo@example.com",
      "password": "******",
    },
    {
      "nama": "Rama Wijaya",
      "mesin": "Creeper 2",
      "telp": "085312345678",
      "email": "rama@example.com",
      "password": "******",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Daftar Karyawan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF022415),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Add your add employee logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Fitur Tambah Karyawan")),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Tambah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A9C5D),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Color(0xFF0A9C5D).withOpacity(0.1),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        "Nama Petugas",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Mesin yang Dikerjakan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Nomor Telepon",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Alamat Email",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Password",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: karyawan
                      .map((item) => DataRow(cells: [
                            DataCell(Text(item["nama"]!)),
                            DataCell(Text(item["mesin"]!)),
                            DataCell(Text(item["telp"]!)),
                            DataCell(Text(item["email"]!)),
                            DataCell(Text(item["password"]!)),
                          ]))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////
//                        SCHEDULE PAGE
//////////////////////////////////////////////////////////////////

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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
              Icon(
                icon,
                size: 60,
                color: Colors.white,
              ),
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

//////////////////////////////////////////////////////////////////
//                        MAINTENANCE SCHEDULE PAGE
//////////////////////////////////////////////////////////////////

class MaintenanceSchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Maintenance Schedule",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF022415),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Fitur Tambah Maintenance Schedule")),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Tambah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A9C5D),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: Center(
            child: Text(
              "Halaman Maintenance Schedule\n(Belum ada data)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////
//                        CEK SHEET SCHEDULE PAGE
//////////////////////////////////////////////////////////////////

class CekSheetSchedulePage extends StatelessWidget {
  // Data mentah dengan detail per bagian
  final List<Map<String, dynamic>> _rawData = [
    {
      "no": 1,
      "nama_infrastruktur": "CREEPER 2",
      "bagian": "a Bearing",
      "periode": "Per 3 Hari",
      "jenis_pekerjaan": "Pelumasan",
      "standar_perawatan": "Bola-bola/silinder-silinder pada bearing terlumasi",
      "alat_bahan": "Pump grease, kunci neple, kunci 14, kunci 15",
      "tanggal_status": Map<int, String>.from({
        1: "M\nV",
        4: "M\nV",
        7: "M\nV",
        10: "M\nV",
        13: "M\nV",
        16: "M\nV",
        19: "M\nV",
        22: "M\nV",
        25: "M\nV",
        28: "M\nV",
        31: "M\nV",
      }),
    },
    {
      "no": 2,
      "nama_infrastruktur": "CREEPER 2",
      "bagian": "b V-belt feeding roll",
      "periode": "Per 2 Minggu",
      "jenis_pekerjaan": "Cek",
      "standar_perawatan": "Tidak slip dan tidak retak",
      "alat_bahan": "Kunci 38, kunci 48, kunci 28, kunci 14, kunci 19, kunci 24, linggis & palu",
      "tanggal_status": Map<int, String>.from({
        1: "M\nV",
        15: "M\nV",
      }),
    },
    {
      "no": 3,
      "nama_infrastruktur": "CREEPER 2",
      "bagian": "c V-belt",
      "periode": "Per 1 Bulan",
      "jenis_pekerjaan": "Cek",
      "standar_perawatan": "Tidak slip dan tidak retak",
      "alat_bahan": "Kunci 14, kunci 19",
      "tanggal_status": Map<int, String>.from({
        1: "M\nV",
      }),
    },
  ];

  // Mengelompokkan data berdasarkan nama_infrastruktur
  Map<String, List<Map<String, dynamic>>> _groupByInfrastruktur() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in _rawData) {
      String nama = item["nama_infrastruktur"];
      if (!grouped.containsKey(nama)) {
        grouped[nama] = [];
      }
      grouped[nama]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Cek Sheet Schedule",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF022415),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Fitur Tambah Cek Sheet Schedule")),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Tambah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A9C5D),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        // Header Info
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                "Keterangan: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Row(
                children: [
                  Text("M = Rencana Perawatan"),
                  SizedBox(width: 20),
                  Text("V = Aktual Perawatan"),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // ================= TABLE ==================
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: _buildCekSheetTable(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCekSheetTable(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Map<String, List<Map<String, dynamic>>> grouped = _groupByInfrastruktur();
    List<TableRow> rows = [];
    
    // Header Row
    rows.add(
      TableRow(
        decoration: BoxDecoration(
          color: Color(0xFF0A9C5D).withOpacity(0.1),
        ),
        children: [
          _buildTableCell("NO", isHeader: true),
          _buildTableCell("NAMA INFRASTRUKTUR", isHeader: true),
          _buildTableCell("BAGIAN", isHeader: true),
          _buildTableCell("PERIODE", isHeader: true),
          _buildTableCell("JENIS PEKERJAAN", isHeader: true),
          _buildTableCell("STANDARD PERAWATAN", isHeader: true),
          _buildTableCell("ALAT DAN BAHAN", isHeader: true),
          _buildTableCell("AKSI", isHeader: true),
        ],
      ),
    );

    // Data Rows dengan rowspan untuk nama infrastruktur
    int globalNo = 1;
    grouped.forEach((namaInfrastruktur, items) {
      for (int i = 0; i < items.length; i++) {
        var item = items[i];
        bool isFirstRow = i == 0;
        int rowSpan = items.length;
        
        rows.add(
          TableRow(
            children: [
              _buildTableCell(isFirstRow ? "$globalNo" : "", isHeader: false),
              _buildTableCellWithRowSpan(
                isFirstRow ? namaInfrastruktur : "",
                isFirstRow ? rowSpan : 1,
                isHeader: false,
              ),
              _buildTableCell(item["bagian"], isHeader: false),
              _buildTableCell(item["periode"], isHeader: false),
              _buildTableCell(item["jenis_pekerjaan"], isHeader: false),
              _buildTableCell(item["standar_perawatan"], isHeader: false),
              _buildTableCell(item["alat_bahan"], isHeader: false),
              _buildActionCell(context, item),
            ],
          ),
        );
      }
      globalNo++;
    });

    return Container(
      width: screenWidth > 1200 ? screenWidth - 40 : 1200,
      child: Table(
        border: TableBorder.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        columnWidths: {
          0: FixedColumnWidth(50),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.5),
          3: FixedColumnWidth(100),
          4: FlexColumnWidth(1.2),
          5: FlexColumnWidth(2.5),
          6: FlexColumnWidth(2.5),
          7: FixedColumnWidth(150),
        },
        children: rows,
      ),
    );
  }

  Widget _buildTableCellWithRowSpan(String text, int rowSpan, {required bool isHeader}) {
    if (text.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.grey.shade300, width: 1),
            right: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.all(12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade300, width: 1),
          right: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: isHeader ? 12 : 11,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {required bool isHeader}) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 12 : 11,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildActionCell(BuildContext context, Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol Tanggal
          Tooltip(
            message: "Lihat Jadwal Tanggal",
            child: IconButton(
              icon: Icon(Icons.calendar_today, color: Color(0xFF0A9C5D), size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KalenderPengecekanPage(item: item),
                  ),
                );
              },
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(),
            ),
          ),
          SizedBox(width: 4),
          // Tombol Edit
          Tooltip(
            message: "Edit",
            child: IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF0A9C5D), size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Edit: ${item["nama_infrastruktur"]} - ${item["bagian"]}"),
                  ),
                );
              },
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(),
            ),
          ),
          SizedBox(width: 4),
          // Tombol Hapus
          Tooltip(
            message: "Hapus",
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Hapus: ${item["nama_infrastruktur"]} - ${item["bagian"]}"),
                  ),
                );
              },
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

}

//////////////////////////////////////////////////////////////////
//                        KALENDER PENgecekan PAGE
//////////////////////////////////////////////////////////////////

class KalenderPengecekanPage extends StatefulWidget {
  final Map<String, dynamic> item;

  KalenderPengecekanPage({required this.item});

  @override
  _KalenderPengecekanPageState createState() => _KalenderPengecekanPageState();
}

class _KalenderPengecekanPageState extends State<KalenderPengecekanPage> {

  @override
  Widget build(BuildContext context) {
    Map<int, String> tanggalStatus =
        widget.item["tanggal_status"] as Map<int, String>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jadwal Pengecekan - ${widget.item["nama_infrastruktur"]}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0A9C5D),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey.shade50,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Bagian
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bagian: ${widget.item["bagian"]}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF022415),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Keterangan: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Text("M = Rencana Perawatan"),
                      SizedBox(width: 20),
                      Text(
                        "V = Aktual Perawatan",
                        style: TextStyle(
                          color: Color(0xFF0A9C5D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Grid Kalender
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(15),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 31,
                  itemBuilder: (context, index) {
                    int day = index + 1;
                    bool hasRencana = tanggalStatus.containsKey(day);
                    String status = hasRencana ? tanggalStatus[day]! : "";
                    bool hasAktual = status.contains("V");

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: hasRencana
                              ? Color(0xFF0A9C5D)
                              : Colors.grey.shade300,
                          width: hasRencana ? 2 : 1,
                        ),
                        color: hasAktual
                            ? Color(0xFF0A9C5D).withOpacity(0.2)
                            : hasRencana
                                ? Color(0xFF0A9C5D).withOpacity(0.05)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$day",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: hasAktual
                                  ? Color(0xFF0A9C5D)
                                  : Colors.black,
                            ),
                          ),
                          if (hasRencana) ...[
                            SizedBox(height: 4),
                            Text(
                              "M",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                          if (hasAktual) ...[
                            SizedBox(height: 2),
                            Text(
                              "V",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A9C5D),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
