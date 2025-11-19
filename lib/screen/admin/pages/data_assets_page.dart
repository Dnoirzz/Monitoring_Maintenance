import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DataMesinPage extends StatefulWidget {
  const DataMesinPage({super.key});

  @override
  _DataMesinPageState createState() => _DataMesinPageState();
}

class _DataMesinPageState extends State<DataMesinPage> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    // Sinkronkan scroll body ke header
    _horizontalScrollController.addListener(() {
      if (!_isSyncing && _headerScrollController.hasClients) {
        _isSyncing = true;
        _headerScrollController.jumpTo(_horizontalScrollController.offset);
        Future.microtask(() => _isSyncing = false);
      }
    });
    // Sinkronkan scroll header ke body
    _headerScrollController.addListener(() {
      if (!_isSyncing && _horizontalScrollController.hasClients) {
        _isSyncing = true;
        _horizontalScrollController.jumpTo(_headerScrollController.offset);
        Future.microtask(() => _isSyncing = false);
      }
    });
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    _headerScrollController.dispose();
    super.dispose();
  }

  void _handleHeaderPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }
    if (!_verticalScrollController.hasClients) {
      return;
    }

    final double targetOffset =
        (_verticalScrollController.offset + event.scrollDelta.dy).clamp(
          _verticalScrollController.position.minScrollExtent,
          _verticalScrollController.position.maxScrollExtent,
        );

    if (targetOffset != _verticalScrollController.offset) {
      _verticalScrollController.jumpTo(targetOffset);
    }
  }

  // Data mentah dengan detail per komponen (setiap komponen = 1 row)
  final List<Map<String, dynamic>> _rawData = [
    // Creeper 1 - Roll Atas (3 komponen)
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Atas",
      "komponen_aset": "Bearing",
      "produk_yang_digunakan": "SKF 6205",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Atas",
      "komponen_aset": "Seal",
      "produk_yang_digunakan": "Oil Seal 25x40x7",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Atas",
      "komponen_aset": "Shaft",
      "produk_yang_digunakan": "Shaft Steel 40mm",
      "gambar_aset": null,
    },
    // Creeper 1 - Roll Bawah (4 komponen)
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Bawah",
      "komponen_aset": "Bearing",
      "produk_yang_digunakan": "SKF 6206",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Bawah",
      "komponen_aset": "Seal",
      "produk_yang_digunakan": "Oil Seal 30x45x7",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Bawah",
      "komponen_aset": "Shaft",
      "produk_yang_digunakan": "Shaft Steel 45mm",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Bawah",
      "komponen_aset": "Pulley",
      "produk_yang_digunakan": "Pulley V-Belt 8PK",
      "gambar_aset": null,
    },
    // Excavator
    {
      "nama_aset": "Excavator",
      "jenis_aset": "Alat Berat",
      "maintenance_terakhir": "10 Januari 2024",
      "maintenance_selanjutnya": "10 Februari 2024",
      "bagian_aset": "Hydraulic System",
      "komponen_aset": "Hydraulic Pump",
      "produk_yang_digunakan": "Hydraulic Oil AW46",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Excavator",
      "jenis_aset": "Alat Berat",
      "maintenance_terakhir": "10 Januari 2024",
      "maintenance_selanjutnya": "10 Februari 2024",
      "bagian_aset": "Hydraulic System",
      "komponen_aset": "Cylinder",
      "produk_yang_digunakan": "Seal Kit Cylinder",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Excavator",
      "jenis_aset": "Alat Berat",
      "maintenance_terakhir": "10 Januari 2024",
      "maintenance_selanjutnya": "10 Februari 2024",
      "bagian_aset": "Hydraulic System",
      "komponen_aset": "Hose",
      "produk_yang_digunakan": "Hydraulic Hose 1/2 inch",
      "gambar_aset": null,
    },
    // Generator Set
    {
      "nama_aset": "Generator Set",
      "jenis_aset": "Listrik",
      "maintenance_terakhir": "5 Januari 2024",
      "maintenance_selanjutnya": "5 Februari 2024",
      "bagian_aset": "Engine",
      "komponen_aset": "Alternator",
      "produk_yang_digunakan": "Alternator 12V 100A",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Generator Set",
      "jenis_aset": "Listrik",
      "maintenance_terakhir": "5 Januari 2024",
      "maintenance_selanjutnya": "5 Februari 2024",
      "bagian_aset": "Engine",
      "komponen_aset": "Battery",
      "produk_yang_digunakan": "Battery Dry 12V 100Ah",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Generator Set",
      "jenis_aset": "Listrik",
      "maintenance_terakhir": "5 Januari 2024",
      "maintenance_selanjutnya": "5 Februari 2024",
      "bagian_aset": "Engine",
      "komponen_aset": "Fuel System",
      "produk_yang_digunakan": "Fuel Filter Element",
      "gambar_aset": null,
    },
    // Mixing Machine
    {
      "nama_aset": "Mixing Machine",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "20 Januari 2024",
      "maintenance_selanjutnya": "20 Februari 2024",
      "bagian_aset": "Gearbox",
      "komponen_aset": "Gear",
      "produk_yang_digunakan": "Gear Oil EP90",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Mixing Machine",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "20 Januari 2024",
      "maintenance_selanjutnya": "20 Februari 2024",
      "bagian_aset": "Gearbox",
      "komponen_aset": "Oli",
      "produk_yang_digunakan": "Gear Oil EP90 5L",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Mixing Machine",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "20 Januari 2024",
      "maintenance_selanjutnya": "20 Februari 2024",
      "bagian_aset": "Gearbox",
      "komponen_aset": "Seal",
      "produk_yang_digunakan": "Oil Seal 50x70x8",
      "gambar_aset": null,
    },
  ];

  // Mengelompokkan data berdasarkan nama_aset
  Map<String, List<Map<String, dynamic>>> _groupByAset() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in _rawData) {
      String nama = item["nama_aset"];
      if (!grouped.containsKey(nama)) {
        grouped[nama] = [];
      }
      grouped[nama]!.add(item);
    }
    return grouped;
  }

  // Mengelompokkan data berdasarkan bagian dalam satu aset
  Map<String, List<Map<String, dynamic>>> _groupByBagian(
    List<Map<String, dynamic>> items,
  ) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in items) {
      String bagian = item["bagian_aset"];
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
          "Data Aset",
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Fitur Tambah Data Aset")));
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
            child: _buildTableWithStickyHeader(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTableWithStickyHeader(BuildContext context) {
    final headerStyle = const TextStyle(fontWeight: FontWeight.bold);
    const double rowHeight = 65.0;
    const double horizontalScrollbarThickness = 12.0;
    const double horizontalScrollbarPadding =
        horizontalScrollbarThickness + 8.0;

    // Lebar kolom
    const double colNo = 60.0;
    const double col1 = 180.0; // Nama Aset
    const double col2 = 150.0; // Jenis Aset
    const double col3 = 200.0; // Maintenance Terakhir
    const double col4 = 200.0; // Maintenance Selanjutnya
    const double col5 = 150.0; // Bagian Aset
    const double col6 = 150.0; // Komponen Aset
    const double col7 = 200.0; // Produk yang Digunakan
    const double col8 = 200.0; // Gambar Aset
    const double col9 = 120.0; // Kolom AKSI

    // Build header row content (tanpa scroll view)
    Widget headerRowContent = Row(
      children: [
        _cellCenter("NO", colNo, rowHeight, headerStyle, isHeader: true),
        _cellCenter("NAMA ASET", col1, rowHeight, headerStyle, isHeader: true),
        _cellCenter("JENIS ASET", col2, rowHeight, headerStyle, isHeader: true),
        _cellCenter(
          "MAINTENANCE TERAKHIR",
          col3,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter(
          "MAINTENANCE SELANJUTNYA",
          col4,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter(
          "BAGIAN ASET",
          col5,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter(
          "KOMPONEN ASET",
          col6,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter(
          "PRODUK YANG DIGUNAKAN",
          col7,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter(
          "GAMBAR ASET",
          col8,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter("AKSI", col9, rowHeight, headerStyle, isHeader: true),
      ],
    );

    // Build body dengan padding tambahan agar tidak tertutup scrollbar horizontal
    Widget tableBody = Padding(
      padding: const EdgeInsets.only(bottom: horizontalScrollbarPadding),
      child: _buildTableBody(context),
    );

    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      thickness: horizontalScrollbarThickness,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: Stack(
        children: [
          // Scrollable Body dengan horizontal scroll
          Column(
            children: [
              // Spacer untuk header
              SizedBox(height: rowHeight),
              // Scrollable Body
              Expanded(
                child: Scrollbar(
                  controller: _verticalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: tableBody,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Sticky Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                color: Colors.white,
              ),
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerSignal: _handleHeaderPointerSignal,
                child: SingleChildScrollView(
                  controller: _headerScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: AlwaysScrollableScrollPhysics(),
                  child: headerRowContent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableBody(BuildContext context) {
    const double rowHeight = 65.0;

    // Lebar kolom
    const double colNo = 60.0;
    const double col1 = 180.0; // Nama Aset
    const double col2 = 150.0; // Jenis Aset
    const double col3 = 200.0; // Maintenance Terakhir
    const double col4 = 200.0; // Maintenance Selanjutnya
    const double col5 = 150.0; // Bagian Aset
    const double col6 = 150.0; // Komponen Aset
    const double col7 = 200.0; // Produk yang Digunakan
    const double col8 = 200.0; // Gambar Aset
    const double col9 = 120.0; // Kolom AKSI

    Map<String, List<Map<String, dynamic>>> grouped = _groupByAset();
    List<Widget> dataRows = [];

    // Data Rows dengan MERGED CELLS
    int globalNo = 1;
    grouped.forEach((namaAset, items) {
      int totalRows = items.length;
      double mergedHeight = rowHeight * totalRows;

      // Ambil data dari item pertama untuk kolom yang di-merge
      var firstItem = items[0];

      // Kelompokkan berdasarkan bagian
      Map<String, List<Map<String, dynamic>>> groupedByBagian = _groupByBagian(
        items,
      );
      List<Widget> bagianRows = [];

      groupedByBagian.forEach((bagian, bagianItems) {
        int bagianRowCount = bagianItems.length;
        double bagianMergedHeight = rowHeight * bagianRowCount;

        if (bagianRowCount > 1) {
          // Jika bagian memiliki lebih dari 1 komponen, merge bagian
          bagianRows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian - merged untuk semua komponen dalam bagian ini
                _cellCenter(bagian, col5, bagianMergedHeight, null),

                // Data untuk setiap komponen dalam bagian (tanpa gambar dan aksi)
                Column(
                  children:
                      bagianItems.map((item) {
                        return Row(
                          children: [
                            _cellCenter(
                              item["komponen_aset"]!,
                              col6,
                              rowHeight,
                              null,
                            ),
                            _cellCenter(
                              item["produk_yang_digunakan"]!,
                              col7,
                              rowHeight,
                              null,
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),
          );
        } else {
          // Jika bagian hanya 1 komponen, tidak perlu merge
          var item = bagianItems[0];
          bagianRows.add(
            Row(
              children: [
                _cellCenter(bagian, col5, rowHeight, null),
                _cellCenter(item["komponen_aset"]!, col6, rowHeight, null),
                _cellCenter(
                  item["produk_yang_digunakan"]!,
                  col7,
                  rowHeight,
                  null,
                ),
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

            // Kolom NAMA ASET - merged untuk semua baris
            _cellCenter(namaAset, col1, mergedHeight, null),

            // Kolom JENIS ASET - merged untuk semua baris
            _cellCenter(firstItem["jenis_aset"]!, col2, mergedHeight, null),

            // Kolom MAINTENANCE TERAKHIR - merged untuk semua baris
            _cellCenter(
              firstItem["maintenance_terakhir"]!,
              col3,
              mergedHeight,
              null,
            ),

            // Kolom MAINTENANCE SELANJUTNYA - merged untuk semua baris
            _cellCenter(
              firstItem["maintenance_selanjutnya"]!,
              col4,
              mergedHeight,
              null,
            ),

            // Kolom BAGIAN ASET, KOMPONEN ASET, PRODUK
            Column(children: bagianRows),

            // Kolom GAMBAR ASET - merged untuk semua baris dalam satu aset
            _imageCell(firstItem["gambar_aset"], col8, mergedHeight),

            // Kolom AKSI - merged untuk semua baris dalam satu aset
            _actionCell(context, firstItem, col9, mergedHeight),
          ],
        ),
      );
      globalNo++;
    });

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.black, width: 1),
          right: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Column(children: dataRows),
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

  Widget _imageCell(String? imagePath, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child:
          imagePath != null
              ? Image.asset(
                imagePath,
                width: width - 8,
                height: height - 8,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported, size: 24);
                },
              )
              : Icon(Icons.image, size: 24, color: Colors.grey),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tombol Edit
          _iconButton(
            icon: Icons.edit,
            color: Colors.blue,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Edit: ${item["nama_aset"]}")),
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
                SnackBar(content: Text("Hapus: ${item["nama_aset"]}")),
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
