import 'package:flutter/material.dart';
import 'package:shared/models/check_sheet_model.dart';

class KalenderPengecekanPage extends StatefulWidget {
  final CheckSheetModel item;

  const KalenderPengecekanPage({
    super.key,
    required this.item,
  });

  @override
  _KalenderPengecekanPageState createState() => _KalenderPengecekanPageState();
}

class _KalenderPengecekanPageState extends State<KalenderPengecekanPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    Map<int, String> tanggalStatus = widget.item.tanggalStatus;

    // Hitung jumlah hari dalam bulan
    int daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    // Hitung hari pertama bulan (0 = Minggu, 1 = Senin, dst)
    DateTime firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    // Convert weekday: Dart uses 1-7 (Mon=1, Sun=7), we need 0-6 (Sun=0, Sat=6)
    // weekday 7 (Sunday) -> 0, weekday 1 (Monday) -> 1, etc.
    int firstDayWeekday =
        firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jadwal Pengecekan - ${widget.item.namaInfrastruktur}",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0A9C5D),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            // Info Bagian
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bagian: ${widget.item.bagian}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF022415),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Jenis Pekerjaan: ${widget.item.jenisPekerjaan}",
                    style: TextStyle(fontSize: 13, color: Color(0xFF022415)),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "Keterangan: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "M = Rencana Perawatan",
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(width: 15),
                      Text(
                        "V = Aktual Perawatan",
                        style: TextStyle(
                          color: Color(0xFF0A9C5D),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Header Bulan dan Navigasi
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month - 1,
                        );
                      });
                    },
                  ),
                  Text(
                    "${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF022415),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),

            // Kalender Grid
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.all(8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double availableHeight = constraints.maxHeight;
                    double headerHeight = 30;
                    double calendarHeight = availableHeight - headerHeight;
                    double cellHeight =
                        calendarHeight / 6; // 6 baris untuk bulan penuh
                    double cellWidth =
                        (constraints.maxWidth - 16) /
                        7; // 7 kolom, minus padding

                    return Column(
                      children: [
                        // Header Hari
                        Row(
                          children:
                              ['Ming', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
                                  .map(
                                    (day) => SizedBox(
                                      width: cellWidth,
                                      child: Text(
                                        day,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: Color(0xFF022415),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        SizedBox(height: 4),
                        // Grid Kalender
                        Expanded(
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  childAspectRatio: cellWidth / cellHeight,
                                ),
                            itemCount: 42, // 6 minggu x 7 hari
                            itemBuilder: (context, index) {
                              int dayNumber = index - firstDayWeekday + 1;
                              bool isValidDay =
                                  dayNumber >= 1 && dayNumber <= daysInMonth;

                              if (!isValidDay) {
                                return Container(); // Kosong untuk hari di luar bulan
                              }

                              bool hasRencana = tanggalStatus.containsKey(
                                dayNumber,
                              );
                              String status =
                                  hasRencana ? tanggalStatus[dayNumber]! : "";
                              bool hasAktual = status.contains("V");

                              return Container(
                                margin: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        hasRencana
                                            ? Color(0xFF0A9C5D)
                                            : Colors.grey.shade300,
                                    width: hasRencana ? 1.5 : 0.5,
                                  ),
                                  color:
                                      hasAktual
                                          ? Color(0xFF0A9C5D).withOpacity(0.2)
                                          : hasRencana
                                          ? Color(0xFF0A9C5D).withOpacity(0.05)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$dayNumber",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            hasAktual
                                                ? Color(0xFF0A9C5D)
                                                : Colors.black,
                                      ),
                                    ),
                                    if (hasRencana) ...[
                                      SizedBox(height: 2),
                                      Text(
                                        "M",
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                    if (hasAktual) ...[
                                      SizedBox(height: 1),
                                      Text(
                                        "V",
                                        style: TextStyle(
                                          fontSize: 9,
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
                      ],
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

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }
}
