import 'package:flutter/material.dart';
import 'kalender_pengecekan_page.dart';

class CekSheetSchedulePage extends StatelessWidget {
  // Data mentah dengan detail per bagian
  final List<Map<String, dynamic>> _rawData = [
    {
      "no": 1,
      "nama_infrastruktur": "SCREW BREAKER",
      "bagian": "Pisau Duduk",
      "periode": "Per 1 Minggu",
      "jenis_pekerjaan": "Cek hasil potongan remahan",
      "standar_perawatan": "Ukuran output remahan < 15cm",
      "alat_bahan": "Kunci 33,48,28,19,41,24",
      "tanggal_status": Map<int, String>.from({}),
    },
    {
      "no": 2,
      "nama_infrastruktur": "SCREW BREAKER",
      "bagian": "Pisau Duduk",
      "periode": "Per 2 Minggu",
      "jenis_pekerjaan": "Las tambah daging + pengasahan",
      "standar_perawatan": "Ujung pisau max 3mm dari screen",
      "alat_bahan": "Kunci 33,48,28,19,41,24",
      "tanggal_status": Map<int, String>.from({}),
    },
    {
      "no": 3,
      "nama_infrastruktur": "SCREW BREAKER",
      "bagian": "V-Belt",
      "periode": "Per 3 Hari",
      "jenis_pekerjaan": "Cek",
      "standar_perawatan": "Tidak ada slip, retak, getar",
      "alat_bahan": "Kunci 33,48,28,19,41,24",
      "tanggal_status": Map<int, String>.from({}),
    },
    {
      "no": 4,
      "nama_infrastruktur": "SCREW BREAKER",
      "bagian": "Gearbox",
      "periode": "Per 12 Bulan",
      "jenis_pekerjaan": "Ganti Oli",
      "standar_perawatan": "Volume oli sesuai standard",
      "alat_bahan": "Kunci 33,48,28,19,41,24",
      "tanggal_status": Map<int, String>.from({}),
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

  // Mengelompokkan data berdasarkan bagian dalam satu infrastruktur
  Map<String, List<Map<String, dynamic>>> _groupByBagian(
    List<Map<String, dynamic>> items,
  ) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in items) {
      String bagian = item["bagian"];
      if (!grouped.containsKey(bagian)) {
        grouped[bagian] = [];
      }
      grouped[bagian]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cek Sheet Schedule",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF022415),
          ),
        ),
        SizedBox(height: 20),

        // Button Tambah
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Fitur Tambah Cek Sheet Schedule")),
            );
          },
          icon: Icon(Icons.add),
          label: Text("Tambah"),
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            backgroundColor: Color(0xFF0A9C5D),
            iconColor: Colors.white,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 5),

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
    final headerStyle = const TextStyle(fontWeight: FontWeight.bold);
    const double rowHeight = 65.0;

    // Lebar kolom
    const double colNo = 60.0;
    const double col1 = 180.0;
    const double col2 = 150.0;
    const double col3 = 120.0;
    const double col4 = 220.0;
    const double col5 = 260.0;
    const double col6 = 260.0;
    const double col7 = 200.0; // Kolom AKSI

    Map<String, List<Map<String, dynamic>>> grouped = _groupByInfrastruktur();
    List<Widget> dataRows = [];

    // Data Rows dengan MERGED CELLS
    int globalNo = 1;
    grouped.forEach((namaInfrastruktur, items) {
      int totalRows = items.length;
      double mergedHeight = rowHeight * totalRows;

      // Kelompokkan berdasarkan bagian
      Map<String, List<Map<String, dynamic>>> groupedByBagian = _groupByBagian(
        items,
      );
      List<Widget> bagianRows = [];

      groupedByBagian.forEach((bagian, bagianItems) {
        int bagianRowCount = bagianItems.length;
        double bagianMergedHeight = rowHeight * bagianRowCount;

        if (bagianRowCount > 1) {
          // Jika bagian memiliki lebih dari 1 item, merge bagian
          bagianRows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian - merged untuk semua baris bagian ini
                _cellCenter(bagian, col2, bagianMergedHeight, null),

                // Data untuk setiap item dalam bagian
                Column(
                  children:
                      bagianItems.map((item) {
                        return Row(
                          children: [
                            _cellCenter(item["periode"], col3, rowHeight, null),
                            _cellCenter(
                              item["jenis_pekerjaan"],
                              col4,
                              rowHeight,
                              null,
                            ),
                            _cellCenter(
                              item["standar_perawatan"],
                              col5,
                              rowHeight,
                              null,
                            ),
                            _cellCenter(
                              item["alat_bahan"],
                              col6,
                              rowHeight,
                              null,
                            ),
                            _actionCell(context, item, col7, rowHeight),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),
          );
        } else {
          // Jika bagian hanya 1 item, tidak perlu merge
          var item = bagianItems[0];
          bagianRows.add(
            Row(
              children: [
                _cellCenter(bagian, col2, rowHeight, null),
                _cellCenter(item["periode"], col3, rowHeight, null),
                _cellCenter(item["jenis_pekerjaan"], col4, rowHeight, null),
                _cellCenter(item["standar_perawatan"], col5, rowHeight, null),
                _cellCenter(item["alat_bahan"], col6, rowHeight, null),
                _actionCell(context, item, col7, rowHeight),
              ],
            ),
          );
        }
      });

      dataRows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom NO - merged untuk semua baris
            _cellCenter(globalNo.toString(), colNo, mergedHeight, null),

            // Kolom NAMA INFRASTRUKTUR - merged untuk semua baris
            _cellCenter(namaInfrastruktur, col1, mergedHeight, null),

            // Kolom 2-7 dengan data per bagian (yang sudah di-merge jika perlu)
            Column(children: bagianRows),
          ],
        ),
      );
      globalNo++;
    });

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        children: [
          // HEADER ROW
          Row(
            children: [
              _cellCenter("NO", colNo, rowHeight, headerStyle, isHeader: true),
              _cellCenter(
                "NAMA INFRASTRUKTUR",
                col1,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "BAGIAN",
                col2,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "PERIODE",
                col3,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "JENIS PEKERJAAN",
                col4,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "STANDAR PERAWATAN",
                col5,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "ALAT DAN BAHAN",
                col6,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter("AKSI", col7, rowHeight, headerStyle, isHeader: true),
            ],
          ),
          // DATA ROWS
          ...dataRows,
        ],
      ),
    );
  }

  Widget _cellCenter(
    String text,
    double width,
    double height,
    TextStyle? style, {
    bool isHeader = false,
  }) {
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

  Widget _actionCell(
    BuildContext context,
    Map<String, dynamic> item,
    double width,
    double height,
  ) {
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
          // Tombol Kalender
          _iconButton(
            icon: Icons.calendar_today,
            color: Color(0xFF0A9C5D),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KalenderPengecekanPage(item: item),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          // Tombol Edit
          _iconButton(
            icon: Icons.edit,
            color: Colors.blue,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Edit: ${item["nama_infrastruktur"]} - ${item["bagian"]}",
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          // Tombol Hapus
          _iconButton(
            icon: Icons.delete,
            color: Colors.red,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Hapus: ${item["nama_infrastruktur"]} - ${item["bagian"]}",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
