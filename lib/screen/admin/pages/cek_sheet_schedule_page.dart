import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'kalender_pengecekan_page.dart';

class CekSheetSchedulePage extends StatefulWidget {
  const CekSheetSchedulePage({super.key});

  @override
  _CekSheetSchedulePageState createState() => _CekSheetSchedulePageState();
}

class _CekSheetSchedulePageState extends State<CekSheetSchedulePage> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  bool _isSyncing = false;
  String? _hoveredRowKey;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  Map<String, List<Map<String, dynamic>>> _groupByInfrastruktur() {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    List<Map<String, dynamic>> filteredData = _rawData.where((item) {
      if (_searchQuery.isEmpty) return true;

      String query = _searchQuery.toLowerCase();
      return item["nama_infrastruktur"]?.toString().toLowerCase().contains(query) == true ||
          item["bagian"]?.toString().toLowerCase().contains(query) == true ||
          item["periode"]?.toString().toLowerCase().contains(query) == true ||
          item["jenis_pekerjaan"]?.toString().toLowerCase().contains(query) == true ||
          item["standar_perawatan"]?.toString().toLowerCase().contains(query) == true ||
          item["alat_bahan"]?.toString().toLowerCase().contains(query) == true;
    }).toList();

    for (var item in filteredData) {
      String nama = item["nama_infrastruktur"];
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
                    hintText: "Cari infrastruktur, bagian, periode, jenis pekerjaan...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF0A9C5D)),
                    suffixIcon: _searchQuery.isNotEmpty
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
                      borderSide: BorderSide(color: Color(0xFF0A9C5D), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showTambahScheduleModal(context),
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
                elevation: 2,
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
            child: _buildTableWithStickyHeader(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTableWithStickyHeader(BuildContext context) {
    final headerStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      color: Colors.white,
    );
    const double rowHeight = 65.0;
    const double horizontalScrollbarThickness = 12.0;
    const double horizontalScrollbarPadding = horizontalScrollbarThickness + 8.0;

    const double colNo = 60.0;
    const double col1 = 180.0;
    const double col2 = 150.0;
    const double col3 = 120.0;
    const double col7 = 200.0;
    
    const double fixedColumnsWidth = colNo + col1 + col2 + col3 + col7;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - fixedColumnsWidth;
        final expandedColWidth = availableWidth > 0 ? availableWidth / 3 : 220.0;
        
        final col4 = expandedColWidth < 220 ? 220.0 : expandedColWidth;
        final col5 = expandedColWidth < 220 ? 220.0 : expandedColWidth;
        final col6 = expandedColWidth < 220 ? 220.0 : expandedColWidth;

        Widget headerRowContent = Row(
          children: [
            _headerCell("NO", colNo, rowHeight, headerStyle),
            _headerCell("NAMA INFRASTRUKTUR", col1, rowHeight, headerStyle),
            _headerCell("BAGIAN", col2, rowHeight, headerStyle),
            _headerCell("PERIODE", col3, rowHeight, headerStyle),
            _headerCell("JENIS PEKERJAAN", col4, rowHeight, headerStyle),
            _headerCell("STANDAR PERAWATAN", col5, rowHeight, headerStyle),
            _headerCell("ALAT DAN BAHAN", col6, rowHeight, headerStyle),
            _headerCell("AKSI", col7, rowHeight, headerStyle),
          ],
        );

        Widget tableBody = Padding(
          padding: const EdgeInsets.only(bottom: horizontalScrollbarPadding),
          child: _buildTableBodyDynamic(context, col4, col5, col6),
        );

        final totalTableWidth = colNo + col1 + col2 + col3 + col4 + col5 + col6 + col7;
        final needsScroll = totalTableWidth > constraints.maxWidth;

        return Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: needsScroll,
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
                          physics: needsScroll
                              ? AlwaysScrollableScrollPhysics()
                              : NeverScrollableScrollPhysics(),
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
                      physics: needsScroll
                          ? AlwaysScrollableScrollPhysics()
                          : NeverScrollableScrollPhysics(),
                      child: headerRowContent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableBodyDynamic(BuildContext context, double col4, double col5, double col6) {
    const double rowHeight = 65.0;

    const double colNo = 60.0;
    const double col1 = 180.0;
    const double col2 = 150.0;
    const double col3 = 120.0;
    const double col7 = 200.0;

    Map<String, List<Map<String, dynamic>>> grouped = _groupByInfrastruktur();

    if (grouped.isEmpty) {
      final screenWidth = MediaQuery.of(context).size.width;

      return Container(
        width: screenWidth,
        padding: EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                "Data tidak ditemukan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Coba kata kunci lain atau bersihkan pencarian",
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              if (_searchQuery.isNotEmpty) ...[
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      );
    }

    List<Widget> dataRows = [];

    int globalNo = 1;
    int rowIndex = 0;
    grouped.forEach((namaInfrastruktur, items) {
      int totalRows = items.length;
      double mergedHeight = rowHeight * totalRows;
      bool isEvenRow = rowIndex % 2 == 0;

      String rowKey = "${namaInfrastruktur}_$rowIndex";
      bool isHovered = _hoveredRowKey == rowKey;

      Map<String, List<Map<String, dynamic>>> groupedByBagian = _groupByBagian(items);
      List<Widget> bagianRows = [];

      groupedByBagian.forEach((bagian, bagianItems) {
        int bagianRowCount = bagianItems.length;
        double bagianMergedHeight = rowHeight * bagianRowCount;

        if (bagianRowCount > 1) {
          bagianRows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _cellCenter(
                    bagian,
                    col2,
                    bagianMergedHeight,
                    null,
                    isEvenRow: isEvenRow,
                    isHovered: isHovered,
                  ),
                  Column(
                    children: bagianItems.map((item) {
                      return SizedBox(
                        height: rowHeight,
                        child: Row(
                          children: [
                            _cellCenter(
                              item["periode"],
                              col3,
                              rowHeight,
                              null,
                              isEvenRow: isEvenRow,
                              isHovered: isHovered,
                            ),
                            _cellCenter(
                              item["jenis_pekerjaan"],
                              col4,
                              rowHeight,
                              null,
                              isEvenRow: isEvenRow,
                              isHovered: isHovered,
                            ),
                            _cellCenter(
                              item["standar_perawatan"],
                              col5,
                              rowHeight,
                              null,
                              isEvenRow: isEvenRow,
                              isHovered: isHovered,
                            ),
                            _cellCenter(
                              item["alat_bahan"],
                              col6,
                              rowHeight,
                              null,
                              isEvenRow: isEvenRow,
                              isHovered: isHovered,
                            ),
                            _actionCell(
                              context,
                              item,
                              col7,
                              rowHeight,
                              isEvenRow: isEvenRow,
                              isHovered: isHovered,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        } else {
          var item = bagianItems[0];
          bagianRows.add(
            SizedBox(
              height: rowHeight,
              child: Row(
                children: [
                  _cellCenter(
                    bagian,
                    col2,
                    rowHeight,
                    null,
                    isEvenRow: isEvenRow,
                    isHovered: isHovered,
                  ),
                  _cellCenter(
                    item["periode"],
                    col3,
                    rowHeight,
                    null,
                    isEvenRow: isEvenRow,
                    isHovered: isHovered,
                  ),
                  _cellCenter(
                    item["jenis_pekerjaan"],
                    col4,
                    rowHeight,
                    null,
                    isEvenRow: isEvenRow,
                    isHovered: isHovered,
                  ),
                  _cellCenter(
                    item["standar_perawatan"],
                    col5,
                    rowHeight,
                    null,
                    isEvenRow: isEvenRow,
                    isHovered: isHovered,
                  ),
                  _cellCenter(
                    item["alat_bahan"],
                    col6,
                    rowHeight,
                    null,
                    isEvenRow: isEvenRow,
                    isHovered: isHovered,
                  ),
                  _actionCell(
                    context,
                    item,
                    col7,
                    rowHeight,
                    isEvenRow: isEvenRow,
                    isHovered: isHovered,
                  ),
                ],
              ),
            ),
          );
        }
      });

      dataRows.add(
        MouseRegion(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  namaInfrastruktur,
                  col1,
                  mergedHeight,
                  null,
                  isEvenRow: isEvenRow,
                  isHovered: isHovered,
                ),
                Column(children: bagianRows),
              ],
            ),
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

  Widget _headerCell(
    String text,
    double width,
    double height,
    TextStyle style,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          bottom: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _cellCenter(
    String text,
    double width,
    double height,
    TextStyle? style, {
    bool isEvenRow = true,
    bool isHovered = false,
  }) {
    Color backgroundColor;
    if (isHovered) {
      backgroundColor = Color(0xFF0A9C5D).withOpacity(0.1);
    } else {
      backgroundColor = isEvenRow ? Colors.white : Colors.grey[50]!;
    }

    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: height),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: Colors.grey[300]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: style ?? TextStyle(fontSize: 12, color: Colors.grey[800]),
        textAlign: TextAlign.center,
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
      backgroundColor = isEvenRow ? Colors.white : Colors.grey[50]!;
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
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          const SizedBox(width: 8),
          _iconButton(
            icon: Icons.edit,
            color: Color(0xFF2196F3),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Edit: ${item["nama_infrastruktur"]} - ${item["bagian"]}",
                  ),
                  backgroundColor: Color(0xFF0A9C5D),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _iconButton(
            icon: Icons.delete,
            color: Color(0xFFF44336),
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

  void _showTambahScheduleModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final namaInfrastrukturController = TextEditingController();
    final List<BagianScheduleItem> bagianList = [BagianScheduleItem()];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF0A9C5D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.schedule,
                              color: Color(0xFF0A9C5D),
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tambah Cek Sheet Schedule",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Isi form di bawah ini untuk menambahkan schedule baru",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(),
                      const SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _modalTextField(
                                controller: namaInfrastrukturController,
                                label: "Nama Infrastruktur",
                                icon: Icons.precision_manufacturing,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Nama infrastruktur wajib diisi";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Bagian dan Detail Pekerjaan",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setModalState(() {
                                        bagianList.add(BagianScheduleItem());
                                      });
                                    },
                                    icon: Icon(Icons.add_circle, size: 20),
                                    label: Text("Tambah Bagian"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF0A9C5D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              ...bagianList.asMap().entries.map((entry) {
                                int index = entry.key;
                                BagianScheduleItem bagian = entry.value;

                                return Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF7F9FB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF0A9C5D),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              "Bagian ${index + 1}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          if (bagianList.length > 1)
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove_circle,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                setModalState(() {
                                                  bagian.dispose();
                                                  bagianList.removeAt(index);
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 12),

                                      _modalTextField(
                                        controller: bagian.bagianController,
                                        label: "Nama Bagian",
                                        icon: Icons.category,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return "Nama bagian wajib diisi";
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 12),

                                      DropdownButtonFormField<String>(
                                        value: bagian.selectedPeriode,
                                        decoration: _modalInputDecoration(
                                          label: "Periode",
                                          icon: Icons.calendar_today,
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: "Harian",
                                            child: Text("Harian"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Mingguan",
                                            child: Text("Mingguan"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Bulanan",
                                            child: Text("Bulanan"),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setModalState(() {
                                            bagian.selectedPeriode = value;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Periode wajib dipilih";
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 12),

                                      if (bagian.selectedPeriode != null) ...[
                                        _buildIntervalSpinBox(
                                          bagian: bagian,
                                          setModalState: setModalState,
                                        ),
                                        SizedBox(height: 12),
                                      ],

                                      _modalTextField(
                                        controller: bagian.jenisPekerjaanController,
                                        label: "Jenis Pekerjaan",
                                        icon: Icons.work_outline,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return "Jenis pekerjaan wajib diisi";
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 12),

                                      _modalTextField(
                                        controller: bagian.standarPerawatanController,
                                        label: "Standar Perawatan",
                                        icon: Icons.checklist,
                                        maxLines: 2,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return "Standar perawatan wajib diisi";
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 12),

                                      _modalTextField(
                                        controller: bagian.alatBahanController,
                                        label: "Alat dan Bahan",
                                        icon: Icons.build,
                                        maxLines: 2,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return "Alat dan bahan wajib diisi";
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Divider(),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text("Batal"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (!(formKey.currentState?.validate() ?? false)) {
                                return;
                              }

                              setState(() {
                                for (var bagian in bagianList) {
                                  String intervalUnit = "";
                                  switch (bagian.selectedPeriode) {
                                    case "Harian":
                                      intervalUnit = "Hari";
                                      break;
                                    case "Mingguan":
                                      intervalUnit = "Minggu";
                                      break;
                                    case "Bulanan":
                                      intervalUnit = "Bulan";
                                      break;
                                  }
                                  String periodeText =
                                      "Per ${bagian.intervalController.text.trim()} $intervalUnit";
                                  _rawData.add({
                                    "no": _rawData.length + 1,
                                    "nama_infrastruktur":
                                        namaInfrastrukturController.text.trim(),
                                    "bagian": bagian.bagianController.text.trim(),
                                    "periode": periodeText,
                                    "jenis_pekerjaan":
                                        bagian.jenisPekerjaanController.text.trim(),
                                    "standar_perawatan":
                                        bagian.standarPerawatanController.text.trim(),
                                    "alat_bahan":
                                        bagian.alatBahanController.text.trim(),
                                    "tanggal_status": Map<int, String>.from({}),
                                  });
                                }
                              });

                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Schedule ${namaInfrastrukturController.text.trim()} ditambahkan dengan ${bagianList.length} bagian",
                                  ),
                                  backgroundColor: Color(0xFF0A9C5D),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A9C5D),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            icon: Icon(Icons.save),
                            label: const Text("Simpan"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      namaInfrastrukturController.dispose();
      for (var bagian in bagianList) {
        bagian.dispose();
      }
    });
  }

  Widget _buildIntervalSpinBox({
    required BagianScheduleItem bagian,
    required StateSetter setModalState,
  }) {
    if (bagian.intervalController.text.isEmpty) {
      bagian.intervalController.text = "1";
    }

    String getIntervalLabel(String? periode) {
      switch (periode) {
        case "Harian":
          return "Hari";
        case "Mingguan":
          return "Minggu";
        case "Bulanan":
          return "Bulan";
        default:
          return periode ?? "";
      }
    }

    return FormField<int>(
      initialValue: int.tryParse(bagian.intervalController.text) ?? 1,
      validator: (value) {
        if (bagian.intervalController.text.isEmpty) {
          return "Interval wajib diisi";
        }
        int? val = int.tryParse(bagian.intervalController.text);
        if (val == null) {
          return "Harus berupa angka";
        }
        if (val <= 0) {
          return "Harus lebih dari 0";
        }
        return null;
      },
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      formFieldState.hasError
                          ? Colors.red.shade300
                          : Colors.grey.shade300,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.repeat, color: const Color(0xFF0A9C5D)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Interval (${bagian.selectedPeriode})",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Per ${bagian.intervalController.text.isEmpty ? '1' : bagian.intervalController.text} ${getIntervalLabel(bagian.selectedPeriode)}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Material(
                        color:
                            (int.tryParse(bagian.intervalController.text) ?? 1) > 1
                                ? Color(0xFFF44336)
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap:
                              (int.tryParse(bagian.intervalController.text) ?? 1) > 1
                                  ? () {
                                    setModalState(() {
                                      int currentValue =
                                          int.tryParse(
                                            bagian.intervalController.text,
                                          ) ??
                                          1;
                                      bagian.intervalController.text =
                                          (currentValue - 1).toString();
                                      formFieldState.didChange(currentValue - 1);
                                    });
                                  }
                                  : null,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.remove,
                              color:
                                  (int.tryParse(bagian.intervalController.text) ??
                                              1) >
                                          1
                                      ? Colors.white
                                      : Colors.grey[500],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 60,
                        height: 40,
                        child: TextFormField(
                          controller: bagian.intervalController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A9C5D),
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Color(0xFF0A9C5D),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setModalState(() {
                              formFieldState.didChange(int.tryParse(value));
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Material(
                        color: Color(0xFF0A9C5D),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            setModalState(() {
                              int currentValue =
                                  int.tryParse(bagian.intervalController.text) ?? 1;
                              bagian.intervalController.text =
                                  (currentValue + 1).toString();
                              formFieldState.didChange(currentValue + 1);
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            child: Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (formFieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  formFieldState.errorText ?? '',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _modalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label wajib diisi";
            }
            return null;
          },
      decoration: _modalInputDecoration(label: label, icon: icon),
    );
  }

  InputDecoration _modalInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF0A9C5D)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0A9C5D), width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class BagianScheduleItem {
  final TextEditingController bagianController = TextEditingController();
  String? selectedPeriode;
  final TextEditingController intervalController = TextEditingController();
  final TextEditingController jenisPekerjaanController = TextEditingController();
  final TextEditingController standarPerawatanController = TextEditingController();
  final TextEditingController alatBahanController = TextEditingController();

  void dispose() {
    bagianController.dispose();
    intervalController.dispose();
    jenisPekerjaanController.dispose();
    standarPerawatanController.dispose();
    alatBahanController.dispose();
  }
}