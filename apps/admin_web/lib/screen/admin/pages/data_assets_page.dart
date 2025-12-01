import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Added for kIsWeb

import 'package:shared/controllers/asset_controller.dart';
import 'package:shared/repositories/asset_supabase_repository.dart'; // Import Repository
import '../widgets/mdl_tambah_asset.dart';
import '../widgets/mdl_edit_asset.dart';

class DataMesinPage extends StatefulWidget {
  final AssetController assetController;
  final VoidCallback? onDataChanged; // Callback untuk refresh dashboard saat data berubah

  const DataMesinPage({
    super.key, 
    required this.assetController,
    this.onDataChanged,
  });

  @override
  _DataMesinPageState createState() => _DataMesinPageState();
}

class _DataMesinPageState extends State<DataMesinPage> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSyncing = false;
  bool _isLoading = true; // Tambahkan status loading
  String _searchQuery = '';
  String? _sortColumn;
  bool _sortAscending = true;
  String? _filterJenisAset;
  String? _hoveredRowKey;

  // Data aset (awalnya kosong, diisi dari Supabase)
  List<Map<String, dynamic>> _rawData = [];

  @override
  void initState() {
    super.initState();
    _setupScrollControllers();
    _setupSearchController();
    _fetchData(); // Ambil data saat init
  }

  void _setupScrollControllers() {
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
  }

  void _setupSearchController() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = AssetSupabaseRepository();
      final rawAssets = await repository.getAllAssets();

      // Transformasi data Nested (Supabase) ke Flat (UI Table)
      List<Map<String, dynamic>> flatData = [];

      for (var asset in rawAssets) {
        String namaAset = asset['nama_assets'] ?? '-';
        String? kodeAssets = asset['kode_assets'];
        String jenisAset = asset['jenis_assets'] ?? '-';
        String? foto = asset['foto'];
        String status = asset['status'] ?? 'Aktif';
        String? mtPriority = asset['mt_priority'];
        String? assetId = asset['id'];

        // Data bagian mesin
        List<dynamic> bagianList = asset['bg_mesin'] ?? [];

        if (bagianList.isEmpty) {
          // Jika tidak ada bagian/komponen, tetap tampilkan assetnya
          flatData.add({
            "id": assetId,
            "nama_aset": namaAset,
            "kode_assets": kodeAssets,
            "jenis_aset": jenisAset,
            "status": status,
            "mt_priority": mtPriority,
            "maintenance_terakhir": "-", // Belum ada data maintenance
            "maintenance_selanjutnya": "-",
            "bagian_aset": "-",
            "komponen_aset": "-",
            "produk_yang_digunakan": "-",
            "gambar_aset": foto,
          });
        } else {
          for (var bagian in bagianList) {
            String namaBagian = bagian['nama_bagian'] ?? '-';
            List<dynamic> komponenList = bagian['komponen_assets'] ?? [];

            if (komponenList.isEmpty) {
              flatData.add({
                "id": assetId,
                "nama_aset": namaAset,
                "kode_assets": kodeAssets,
                "jenis_aset": jenisAset,
                "status": status,
                "mt_priority": mtPriority,
                "maintenance_terakhir": "-",
                "maintenance_selanjutnya": "-",
                "bagian_aset": namaBagian,
                "komponen_aset": "-",
                "produk_yang_digunakan": "-",
                "gambar_aset": foto,
              });
            } else {
              for (var komponen in komponenList) {
                String namaKomponen =
                    komponen['nama_bagian'] ??
                    '-'; // Di tabel komponen nama kolomnya nama_bagian
                String spesifikasi = komponen['spesifikasi'] ?? '-';

                flatData.add({
                  "id": assetId,
                  "nama_aset": namaAset,
                  "kode_assets": kodeAssets,
                  "jenis_aset": jenisAset,
                  "status": status,
                  "mt_priority": mtPriority,
                  "maintenance_terakhir":
                      "-", // TODO: Ambil dari tabel maintenance
                  "maintenance_selanjutnya": "-",
                  "bagian_aset": namaBagian,
                  "komponen_aset": namaKomponen,
                  "produk_yang_digunakan": spesifikasi,
                  "gambar_aset": foto,
                });
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _rawData = flatData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                item["kode_assets"]?.toString().toLowerCase().contains(
                      _searchQuery,
                    ) ==
                    true ||
                item["jenis_aset"]?.toString().toLowerCase().contains(
                      _searchQuery,
                    ) ==
                    true ||
                item["status"]?.toString().toLowerCase().contains(
                      _searchQuery,
                    ) ==
                    true ||
                item["mt_priority"]?.toString().toLowerCase().contains(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Data Aset",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF022415),
              ),
            ),
            // Tombol Refresh
            IconButton(
              icon: Icon(Icons.refresh, color: Color(0xFF0A9C5D)),
              tooltip: 'Refresh Data',
              onPressed: _fetchData,
            ),
          ],
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
                    items: const [
                      DropdownMenuItem<String>(value: null, child: Text('Semua Jenis')),
                      DropdownMenuItem<String>(value: 'Mesin Produksi', child: Text('Mesin Produksi')),
                      DropdownMenuItem<String>(value: 'Alat Berat', child: Text('Alat Berat')),
                      DropdownMenuItem<String>(value: 'Listrik', child: Text('Listrik')),
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
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0A9C5D),
                      ),
                    )
                    : _buildTableWithStickyHeader(context),
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
    const double col1 = 180.0; // Nama Aset
    const double col1a = 120.0; // Kode Aset
    const double col2 = 150.0; // Jenis Aset
    const double col2a = 100.0; // Status
    const double col2b = 100.0; // Prioritas
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
          "KODE ASET",
          col1a,
          rowHeight,
          headerStyle,
          "kode_assets",
        ),
        _sortableHeaderCell(
          "JENIS ASET",
          col2,
          rowHeight,
          headerStyle,
          "jenis_aset",
        ),
        _sortableHeaderCell(
          "STATUS",
          col2a,
          rowHeight,
          headerStyle,
          "status",
        ),
        _sortableHeaderCell(
          "PRIORITAS",
          col2b,
          rowHeight,
          headerStyle,
          "mt_priority",
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
    const double col1 = 180.0; // Nama Aset
    const double col1a = 120.0; // Kode Aset
    const double col2 = 150.0; // Jenis Aset
    const double col2a = 100.0; // Status
    const double col2b = 100.0; // Prioritas
    const double col3 = 200.0;
    const double col4 = 200.0;
    const double col5 = 150.0;
    const double col6 = 150.0;
    const double col7 = 200.0;
    const double col8 = 120.0;
    const double col9 = 200.0;

    Map<String, List<Map<String, dynamic>>> grouped = _groupByAset();

    const double totalWidth =
        colNo + col1 + col1a + col2 + col2a + col2b + col3 + col4 + col5 + col6 + col7 + col8 + col9;

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
                firstItem["kode_assets"] ?? "-",
                col1a,
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
              _cellWidget(
                _buildStatusBadge(firstItem["status"] ?? "Aktif"),
                col2a,
                mergedHeight,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellWidget(
                _buildPriorityBadge(firstItem["mt_priority"]),
                col2b,
                mergedHeight,
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

  Widget _cellWidget(
    Widget child,
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
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'aktif':
        badgeColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'breakdown':
        badgeColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'perlu maintenance':
        badgeColor = Colors.orange;
        textColor = Colors.white;
        break;
      default:
        badgeColor = Colors.grey;
        textColor = Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String? priority) {
    if (priority == null || priority.isEmpty) {
      return Text(
        '-',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      );
    }

    Color badgeColor;
    Color textColor;
    
    switch (priority.toLowerCase()) {
      case 'low':
        badgeColor = Colors.blue;
        textColor = Colors.white;
        break;
      case 'medium':
        badgeColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'high':
        badgeColor = Colors.red.shade400;
        textColor = Colors.white;
        break;
      default:
        badgeColor = Colors.grey;
        textColor = Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
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

    bool isUrl(String? path) {
      if (path == null) return false;
      return path.startsWith('http') || path.startsWith('https');
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
                    child:
                        isUrl(imagePath)
                            ? Image.network(
                              imagePath,
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
                            )
                            : Container(
                              width: width - 12,
                              height: height - 12,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 24,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Local File',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
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
      onSave: (newData) async {
        // Tunggu sedikit untuk memastikan dialog modal tertutup
        await Future.delayed(Duration(milliseconds: 100));
        // Panggil ulang fetch data dari DB
        if (mounted) {
          await _fetchData();
          // Refresh dashboard stats
          if (widget.onDataChanged != null && mounted) {
            widget.onDataChanged!();
          }
        }
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
      onSave: (newData, oldData) async {
        await _updateAsset(oldData["nama_aset"], newData);
      },
    );
  }

  // ---------- IMPLEMENTASI UPDATE ----------

  Future<void> _updateAsset(
    String namaAssetLama,
    List<Map<String, dynamic>> newData,
  ) async {
    if (newData.isEmpty) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // Ambil data dari newData pertama
      final firstRow = newData.first;
      final String namaAssetBaru = firstRow["nama_aset"];
      final String jenisAsset = firstRow["jenis_aset"];
      final String? foto = firstRow["gambar_aset"];
      final String? kodeAssets = firstRow["kode_assets"];
      final String? mtPriority = firstRow["mt_priority"];

      // Group data by bagian
      Map<String, List<Map<String, dynamic>>> groupedByBagian = {};
      for (var row in newData) {
        String bagian = row["bagian_aset"];
        if (!groupedByBagian.containsKey(bagian)) {
          groupedByBagian[bagian] = [];
        }
        groupedByBagian[bagian]!.add(row);
      }

      // Transform ke format bagianList
      List<Map<String, dynamic>> bagianList = [];
      groupedByBagian.forEach((namaBagian, komponenRows) {
        List<Map<String, dynamic>> komponenList =
            komponenRows.map((row) {
              return {
                "namaKomponen": row["komponen_aset"],
                "spesifikasi": row["produk_yang_digunakan"],
              };
            }).toList();

        bagianList.add({"namaBagian": namaBagian, "komponen": komponenList});
      });

      // Panggil repository update
      final repository = AssetSupabaseRepository();
      await repository.updateCompleteAsset(
        namaAssetLama: namaAssetLama,
        namaAssetBaru: namaAssetBaru,
        jenisAsset: jenisAsset,
        foto: foto,
        kodeAssets: kodeAssets,
        mtPriority: mtPriority,
        bagianList: bagianList,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Tunggu dialog benar-benar tertutup sebelum refresh
      await Future.delayed(Duration(milliseconds: 100));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asset "$namaAssetBaru" berhasil diupdate'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Refresh data hanya jika widget masih mounted
      if (mounted) {
        await _fetchData();
        // Refresh dashboard stats
        if (widget.onDataChanged != null && mounted) {
          widget.onDataChanged!();
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate asset: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      print('Error updating asset: $e');
    }
  }

  // ---------- PREVIEW GAMBAR ----------

  void _showImagePreview(BuildContext context, String imagePath) {
    bool isUrl(String? path) {
      if (path == null) return false;
      return path.startsWith('http') || path.startsWith('https');
    }

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
                  child:
                      isUrl(imagePath)
                          ? Image.network(imagePath, fit: BoxFit.contain)
                          : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Preview tidak tersedia untuk file lokal',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
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
              onPressed: () async {
                Navigator.of(context).pop();
                // Tunggu dialog konfirmasi benar-benar tertutup
                await Future.delayed(Duration(milliseconds: 100));
                if (mounted) {
                  await _deleteAsset(item["nama_aset"]);
                }
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

  // ---------- IMPLEMENTASI DELETE ----------

  Future<void> _deleteAsset(String namaAsset) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = AssetSupabaseRepository();
      await repository.deleteAssetByName(namaAsset);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Tunggu dialog benar-benar tertutup sebelum refresh
      await Future.delayed(Duration(milliseconds: 100));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asset "$namaAsset" berhasil dihapus'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Refresh data hanya jika widget masih mounted
      if (mounted) {
        await _fetchData();
        // Refresh dashboard stats
        if (widget.onDataChanged != null && mounted) {
          widget.onDataChanged!();
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus asset: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      print('Error deleting asset: $e');
    }
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
