import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:monitoring_maintenance/controller/asset_controller.dart';
import '../widgets/mdl_tambah_asset.dart';
import '../widgets/mdl_edit_asset.dart';

class DataMesinPage extends StatefulWidget {
  final AssetController assetController;
  
  const DataMesinPage({super.key, required this.assetController});

  @override
  _DataMesinPageState createState() => _DataMesinPageState();
}

class _DataMesinPageState extends State<DataMesinPage> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSyncing = false;
  String _searchQuery = '';
  String? _sortColumn;
  bool _sortAscending = true;
  String? _filterJenisAset;
  String? _hoveredRowKey;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.addListener(() {
      if (!_isSyncing && _headerScrollController.hasClients) {
        _isSyncing = true;
        _headerScrollController.jumpTo(_horizontalScrollController.offset);
        Future.microtask(() => _isSyncing = false);
      }
    });
    _headerScrollController.addListener(() {
      if (!_isSyncing && _horizontalScrollController.hasClients) {
        _isSyncing = true;
        _horizontalScrollController.jumpTo(_headerScrollController.offset);
        Future.microtask(() => _isSyncing = false);
      }
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    _headerScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleHeaderPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!_verticalScrollController.hasClients) return;

    final double targetOffset =
        (_verticalScrollController.offset + event.scrollDelta.dy).clamp(
          _verticalScrollController.position.minScrollExtent,
          _verticalScrollController.position.maxScrollExtent,
        );

    if (targetOffset != _verticalScrollController.offset) {
      _verticalScrollController.jumpTo(targetOffset);
    }
  }

  // Data mentah
  List<Map<String, dynamic>> _rawData = [
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

  List<Map<String, dynamic>> _getFilteredAndSortedData() {
    List<Map<String, dynamic>> filtered = _rawData;

    if (_filterJenisAset != null && _filterJenisAset!.isNotEmpty) {
      filtered =
          filtered.where((item) {
            return item["jenis_aset"]?.toString() == _filterJenisAset;
          }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((item) {
            return item["nama_aset"]?.toString().toLowerCase().contains(
                      _searchQuery,
                    ) ==
                    true ||
                item["jenis_aset"]?.toString().toLowerCase().contains(
                      _searchQuery,
                    ) ==
                    true ||
                item["bagian_aset"]?.toString().toLowerCase().contains(
                      _searchQuery,
                    ) ==
                    true ||
                item["komponen_aset"]?.toString().toLowerCase().contains(
                      _searchQuery,
                    ) ==
                    true ||
                item["produk_yang_digunakan"]
                        ?.toString()
                        .toLowerCase()
                        .contains(_searchQuery) ==
                    true ||
                item["maintenance_terakhir"]?.toString().toLowerCase().contains(
                      _searchQuery,
                    ) ==
                    true ||
                item["maintenance_selanjutnya"]
                        ?.toString()
                        .toLowerCase()
                        .contains(_searchQuery) ==
                    true;
          }).toList();
    }

    if (_sortColumn != null) {
      filtered.sort((a, b) {
        var aValue = a[_sortColumn]?.toString() ?? '';
        var bValue = b[_sortColumn]?.toString() ?? '';
        int comparison = aValue.compareTo(bValue);
        return _sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  List<String> _getJenisAsetList() {
    return widget.assetController.getJenisAsetList();
  }

  Map<String, List<Map<String, dynamic>>> _groupByAset() {
    List<Map<String, dynamic>> data = _getFilteredAndSortedData();
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in data) {
      String nama = item["nama_aset"];
      if (!grouped.containsKey(nama)) {
        grouped[nama] = [];
      }
      grouped[nama]!.add(item);
    }
    return grouped;
  }

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

  // ---------- UI ----------

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
        Column(
          children: [
            Row(
              children: [
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
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari data aset...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF0A9C5D),
                        ),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFF0A9C5D),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: _filterJenisAset,
                    hint: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: Color(0xFF0A9C5D),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('Filter Jenis'),
                        ],
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('Semua Jenis'),
                      ),
                      ..._getJenisAsetList().map((jenis) {
                        return DropdownMenuItem<String>(
                          value: jenis,
                          child: Text(jenis),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterJenisAset = value;
                      });
                    },
                    underline: SizedBox(),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    icon: Icon(Icons.arrow_drop_down, color: Color(0xFF0A9C5D)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddAssetForm(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text("Tambah"),
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Color(0xFF0A9C5D),
                    iconColor: Colors.white,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
            if (_filterJenisAset != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text('Filter: $_filterJenisAset'),
                    onDeleted: () {
                      setState(() {
                        _filterJenisAset = null;
                      });
                    },
                    deleteIcon: Icon(Icons.close, size: 18),
                    backgroundColor: Color(0xFF0A9C5D).withOpacity(0.1),
                    labelStyle: TextStyle(color: Color(0xFF0A9C5D)),
                  ),
                ],
              ),
            ],
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
            child: _buildTableWithStickyHeader(context),
          ),
        ),
      ],
    );
  }

  void _handleSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  Widget _buildTableWithStickyHeader(BuildContext context) {
    final headerStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      color: Colors.white,
    );
    const double rowHeight = 65.0;
    const double horizontalScrollbarThickness = 12.0;
    const double horizontalScrollbarPadding =
        horizontalScrollbarThickness + 8.0;

    const double colNo = 60.0;
    const double col1 = 180.0;
    const double col2 = 150.0;
    const double col3 = 200.0;
    const double col4 = 200.0;
    const double col5 = 150.0;
    const double col6 = 150.0;
    const double col7 = 200.0;
    const double col8 = 120.0;
    const double col9 = 200.0;

    Widget headerRowContent = Row(
      children: [
        _sortableHeaderCell("NO", colNo, rowHeight, headerStyle, null),
        _sortableHeaderCell(
          "NAMA ASET",
          col1,
          rowHeight,
          headerStyle,
          "nama_aset",
        ),
        _sortableHeaderCell(
          "JENIS ASET",
          col2,
          rowHeight,
          headerStyle,
          "jenis_aset",
        ),
        _sortableHeaderCell(
          "MAINTENANCE TERAKHIR",
          col3,
          rowHeight,
          headerStyle,
          "maintenance_terakhir",
        ),
        _sortableHeaderCell(
          "MAINTENANCE SELANJUTNYA",
          col4,
          rowHeight,
          headerStyle,
          "maintenance_selanjutnya",
        ),
        _sortableHeaderCell("BAGIAN ASET", col5, rowHeight, headerStyle, null),
        _sortableHeaderCell(
          "KOMPONEN ASET",
          col6,
          rowHeight,
          headerStyle,
          null,
        ),
        _sortableHeaderCell("SPESIFIKASI", col7, rowHeight, headerStyle, null),
        _sortableHeaderCell("GAMBAR ASET", col8, rowHeight, headerStyle, null),
        _sortableHeaderCell("AKSI", col9, rowHeight, headerStyle, null),
      ],
    );

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
          Column(
            children: [
              SizedBox(height: rowHeight),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerSignal: _handleHeaderPointerSignal,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A9C5D), Color(0xFF088A52)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
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

    const double colNo = 60.0;
    const double col1 = 180.0;
    const double col2 = 150.0;
    const double col3 = 200.0;
    const double col4 = 200.0;
    const double col5 = 150.0;
    const double col6 = 150.0;
    const double col7 = 200.0;
    const double col8 = 120.0;
    const double col9 = 200.0;

    Map<String, List<Map<String, dynamic>>> grouped = _groupByAset();

    const double totalWidth =
        colNo + col1 + col2 + col3 + col4 + col5 + col6 + col7 + col8 + col9;

    if (grouped.isEmpty) {
      return Container(
        width: totalWidth,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Tidak ada data ditemukan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty || _filterJenisAset != null
                      ? 'Coba ubah kata kunci pencarian atau filter'
                      : 'Mulai dengan menambahkan data aset baru',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                if (_searchQuery.isNotEmpty || _filterJenisAset != null) ...[
                  SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    icon: Icon(Icons.clear, color: Color(0xFF0A9C5D)),
                    label: Text(
                      "Bersihkan Pencarian",
                      style: TextStyle(color: Color(0xFF0A9C5D)),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      backgroundColor: Color(0xFF0A9C5D).withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    List<Widget> dataRows = [];

    int globalNo = 1;
    int rowIndex = 0;
    grouped.forEach((namaAset, items) {
      int totalRows = items.length;
      double mergedHeight = rowHeight * totalRows;
      bool isEvenRow = rowIndex % 2 == 0;

      var firstItem = items[0];

      String rowKey = namaAset;
      bool isHovered = _hoveredRowKey == rowKey;

      Map<String, List<Map<String, dynamic>>> groupedByBagian = _groupByBagian(
        items,
      );
      List<Widget> bagianRows = [];
      int bagianRowIndex = 0;

      groupedByBagian.forEach((bagian, bagianItems) {
        int bagianRowCount = bagianItems.length;
        double bagianMergedHeight = rowHeight * bagianRowCount;
        bool isBagianEvenRow = (rowIndex + bagianRowIndex) % 2 == 0;

        if (bagianRowCount > 1) {
          bagianRows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cellCenter(
                  bagian,
                  col5,
                  bagianMergedHeight,
                  null,
                  isEvenRow: isBagianEvenRow,
                  isHovered: isHovered,
                ),
                Column(
                  children:
                      bagianItems.asMap().entries.map((entry) {
                        int itemIndex = entry.key;
                        Map<String, dynamic> item = entry.value;
                        bool isItemEvenRow =
                            (rowIndex + bagianRowIndex + itemIndex) % 2 == 0;
                        return Row(
                          children: [
                            _cellCenter(
                              item["komponen_aset"],
                              col6,
                              rowHeight,
                              null,
                              isEvenRow: isItemEvenRow,
                              isHovered: isHovered,
                            ),
                            _cellCenter(
                              item["produk_yang_digunakan"],
                              col7,
                              rowHeight,
                              null,
                              isEvenRow: isItemEvenRow,
                              isHovered: isHovered,
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),
          );
        } else {
          var item = bagianItems[0];
          bagianRows.add(
            Row(
              children: [
                _cellCenter(
                  bagian,
                  col5,
                  rowHeight,
                  null,
                  isEvenRow: isBagianEvenRow,
                  isHovered: isHovered,
                ),
                _cellCenter(
                  item["komponen_aset"],
                  col6,
                  rowHeight,
                  null,
                  isEvenRow: isBagianEvenRow,
                  isHovered: isHovered,
                ),
                _cellCenter(
                  item["produk_yang_digunakan"],
                  col7,
                  rowHeight,
                  null,
                  isEvenRow: isBagianEvenRow,
                  isHovered: isHovered,
                ),
              ],
            ),
          );
        }
        bagianRowIndex += bagianRowCount;
      });

      dataRows.add(
        MouseRegion(
          onEnter: null,
          onExit: null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cellCenter(
                globalNo.toString(),
                colNo,
                mergedHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                namaAset,
                col1,
                mergedHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                firstItem["jenis_aset"],
                col2,
                mergedHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                firstItem["maintenance_terakhir"] ?? "",
                col3,
                mergedHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                firstItem["maintenance_selanjutnya"] ?? "",
                col4,
                mergedHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              Column(children: bagianRows),
              _imageCell(
                firstItem["gambar_aset"],
                col8,
                mergedHeight,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
                context: context,
              ),
              _actionCell(
                context,
                firstItem,
                col9,
                mergedHeight,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
            ],
          ),
        ),
      );
      globalNo++;
      rowIndex++;
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(children: dataRows),
    );
  }

  Widget _sortableHeaderCell(
    String text,
    double width,
    double height,
    TextStyle style,
    String? sortColumn,
  ) {
    bool isSortable = sortColumn != null;
    bool isActive = _sortColumn == sortColumn;

    void handleTap() {
      if (sortColumn != null) {
        _handleSort(sortColumn);
      }
    }

    return MouseRegion(
      cursor: isSortable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isSortable ? handleTap : null,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color:
                isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
            border: Border(
              right: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  text,
                  style: style,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSortable) ...[
                SizedBox(width: 4),
                Icon(
                  isActive
                      ? (_sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward)
                      : Icons.unfold_more,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _cellCenter(
    String text,
    double width,
    double height,
    TextStyle? style, {
    bool isHeader = false,
    bool isEvenRow = true,
    bool isHovered = false,
  }) {
    Color backgroundColor;
    if (isHeader) {
      backgroundColor = const Color(0xFFE0E0E0);
    } else if (isHovered) {
      backgroundColor = Color(0xFF0A9C5D).withOpacity(0.1);
    } else {
      backgroundColor = Colors.white;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: Colors.grey[300]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Text(
        text,
        style: style ?? TextStyle(fontSize: 12, color: Colors.grey[800]),
        textAlign: TextAlign.center,
        maxLines: null,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _imageCell(
    String? imagePath,
    double width,
    double height, {
    bool isEvenRow = true,
    bool isHovered = false,
    BuildContext? context,
  }) {
    Color backgroundColor;
    if (isHovered) {
      backgroundColor = Color(0xFF0A9C5D).withOpacity(0.1);
    } else {
      backgroundColor = Colors.white;
    }

    return GestureDetector(
      onTap:
          imagePath != null && context != null
              ? () => _showImagePreview(context, imagePath)
              : null,
      child: MouseRegion(
        cursor:
            imagePath != null
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              right: BorderSide(color: Colors.grey[300]!, width: 0.5),
              bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.all(6),
          alignment: Alignment.center,
          child:
              imagePath != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(imagePath),
                      width: width - 12,
                      height: height - 12,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.image_not_supported,
                            size: 24,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  )
                  : Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.image, size: 24, color: Colors.grey[600]),
                  ),
        ),
      ),
    );
  }

  Widget _actionCell(
    BuildContext context,
    Map<String, dynamic> item,
    double width,
    double height, {
    bool isEvenRow = true,
    bool isHovered = false,
  }) {
    Color backgroundColor;
    if (isHovered) {
      backgroundColor = Color(0xFF0A9C5D).withOpacity(0.1);
    } else {
      backgroundColor = Colors.white;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: Colors.grey[300]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _iconButton(
            icon: Icons.edit,
            color: Color(0xFF2196F3),
            onPressed: () {
              _showEditAssetForm(context, item["nama_aset"]);
            },
          ),
          const SizedBox(width: 8),
          _iconButton(
            icon: Icons.delete,
            color: Color(0xFFF44336),
            onPressed: () {
              _showDeleteConfirmation(context, item);
            },
          ),
        ],
      ),
    );
  }

  // ---------- MODAL TAMBAH ----------

  void _showAddAssetForm(BuildContext context) {
    ModalTambahAsset.show(
      context,
      onSave: (newData) {
        setState(() {
          _rawData.addAll(newData);
        });
      },
    );
  }

  // ---------- MODAL EDIT ASET ----------

  void _showEditAssetForm(BuildContext context, String namaAset) {
    List<Map<String, dynamic>> asetRows =
        _rawData.where((e) => e["nama_aset"] == namaAset).toList();
    
    ModalEditAsset.show(
      context,
      namaAset: namaAset,
      asetRows: asetRows,
      onSave: (newData, oldData) {
        setState(() {
          _rawData.removeWhere((e) => e["nama_aset"] == oldData["nama_aset"]);
          _rawData.addAll(newData);
        });
      },
    );
  }

  // ---------- PREVIEW GAMBAR ----------

  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(imagePath), fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- KONFIRMASI HAPUS ----------

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Konfirmasi Hapus'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menghapus data aset ini?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Aset: ${item["nama_aset"]}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Jenis: ${item["jenis_aset"]}'),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tindakan ini tidak dapat dibatalkan.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal', style: TextStyle(color: Colors.grey[700])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  widget.assetController.deleteAsset(
                    namaAset: item["nama_aset"] ?? '',
                    bagianAset: item["bagian_aset"] ?? '',
                    komponenAset: item["komponen_aset"] ?? '',
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data aset berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      shadowColor: color.withOpacity(0.5),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}