import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ScheduleSheet(),
    );
  }
}

class ScheduleSheet extends StatelessWidget {
  const ScheduleSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cek Sheet Maintenance")),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: MergedTable(),
        ),
      ),
    );
  }
}

class MergedTable extends StatelessWidget {
  const MergedTable({super.key});

  @override
  Widget build(BuildContext context) {
    final headerStyle = const TextStyle(fontWeight: FontWeight.bold);
    const double rowHeight = 65.0;
    
    // Lebar kolom
    const double col1 = 180.0;
    const double col2 = 150.0;
    const double col3 = 120.0;
    const double col4 = 220.0;
    const double col5 = 260.0;
    const double col6 = 260.0;
    const double col7 = 150.0; // Kolom AKSI

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        children: [
          // HEADER ROW
          Row(
            children: [
              _cellCenter("NAMA INFRASTRUKTUR", col1, rowHeight, headerStyle, isHeader: true),
              _cellCenter("BAGIAN", col2, rowHeight, headerStyle, isHeader: true),
              _cellCenter("PERIODE", col3, rowHeight, headerStyle, isHeader: true),
              _cellCenter("JENIS PEKERJAAN", col4, rowHeight, headerStyle, isHeader: true),
              _cellCenter("STANDAR PERAWATAN", col5, rowHeight, headerStyle, isHeader: true),
              _cellCenter("ALAT DAN BAHAN", col6, rowHeight, headerStyle, isHeader: true),
              _cellCenter("AKSI", col7, rowHeight, headerStyle, isHeader: true),
            ],
          ),

          // DATA ROWS dengan MERGED CELLS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom 1: SCREW BREAKER - merged untuk 4 baris
              _cellCenter("SCREW BREAKER", col1, rowHeight * 4, null),
              
              // Kolom 2-6
              Column(
                children: [
                  // Baris 1 & 2: Pisau Duduk (merged)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pisau Duduk - merged 2 baris
                      _cellCenter("Pisau Duduk", col2, rowHeight * 2, null),
                      
                      // Data untuk 2 periode Pisau Duduk
                      Column(
                        children: [
                          // Periode 1
                          Row(
                            children: [
                              _cellCenter("Per 1 Minggu", col3, rowHeight, null),
                              _cellCenter("Cek hasil potongan remahan", col4, rowHeight, null),
                              _cellCenter("Ukuran output remahan < 15cm", col5, rowHeight, null),
                              _cellCenter("Kunci 33,48,28,19,41,24", col6, rowHeight, null),
                              _actionCell(col7, rowHeight),
                            ],
                          ),
                          // Periode 2
                          Row(
                            children: [
                              _cellCenter("Per 2 Minggu", col3, rowHeight, null),
                              _cellCenter("Las tambah daging + pengasahan", col4, rowHeight, null),
                              _cellCenter("Ujung pisau max 3mm dari screen", col5, rowHeight, null),
                              _cellCenter("Kunci 33,48,28,19,41,24", col6, rowHeight, null),
                              _actionCell(col7, rowHeight),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Baris 3: V-Belt
                  Row(
                    children: [
                      _cellCenter("V-Belt", col2, rowHeight, null),
                      _cellCenter("Per 3 Hari", col3, rowHeight, null),
                      _cellCenter("Cek", col4, rowHeight, null),
                      _cellCenter("Tidak ada slip, retak, getar", col5, rowHeight, null),
                      _cellCenter("Kunci 33,48,28,19,41,24", col6, rowHeight, null),
                      _actionCell(col7, rowHeight),
                    ],
                  ),
                  
                  // Baris 4: Gearbox
                  Row(
                    children: [
                      _cellCenter("Gearbox", col2, rowHeight, null),
                      _cellCenter("Per 12 Bulan", col3, rowHeight, null),
                      _cellCenter("Ganti Oli", col4, rowHeight, null),
                      _cellCenter("Volume oli sesuai standard", col5, rowHeight, null),
                      _cellCenter("Kunci 33,48,28,19,41,24", col6, rowHeight, null),
                      _actionCell(col7, rowHeight),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cellCenter(String text, double width, double height, TextStyle? style, {bool isHeader = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFE0E0E0) : Colors.white,
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
        maxLines: null,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _actionCell(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tombol Edit
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                print("Edit clicked");
                // Tambahkan fungsi edit di sini
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text("Edit", style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                minimumSize: const Size(0, 0),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Tombol Hapus
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                print("Hapus clicked");
                // Tambahkan fungsi hapus di sini
              },
              icon: const Icon(Icons.delete, size: 16),
              label: const Text("Hapus", style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                minimumSize: const Size(0, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}