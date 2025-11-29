import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:shared/controllers/check_sheet_controller.dart';
import 'package:shared/models/check_sheet_model.dart';
import 'package:admin_web/screen/admin/widgets/mdl_edit_cek_sheet_schedule.dart';
import 'package:admin_web/screen/admin/widgets/mdl_tambah_cek_sheet_schedule.dart';

import 'kalender_pengecekan_page.dart';

class CekSheetSchedulePage extends StatefulWidget {
  final CheckSheetController checkSheetController;

  const CekSheetSchedulePage({
    super.key,
    required this.checkSheetController,
  });

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
  bool _isLoading = true;

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
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.checkSheetController.loadFromSupabase();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

  List<CheckSheetModel> _getFilteredSchedules() {
    return widget.checkSheetController
        .filterSchedules(searchQuery: _searchQuery);
  }

  Map<String, List<CheckSheetModel>> _groupByInfrastruktur() {
    return widget.checkSheetController
        .groupByInfrastruktur(_getFilteredSchedules());
  }

  Map<String, List<CheckSheetModel>> _groupByBagian(
    List<CheckSheetModel> items,
  ) {
    return widget.checkSheetController.groupByBagian(items);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0A9C5D)),
            SizedBox(height: 16),
          ],
        ),
      );
    }

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

    Map<String, List<CheckSheetModel>> grouped = _groupByInfrastruktur();

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

      Map<String, List<CheckSheetModel>> groupedByBagian = _groupByBagian(items);
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
                              item.periode,
                              col3,
                              rowHeight,
                              null,
                              isEvenRow: isEvenRow,
                              isHovered: isHovered,
                            ),
                            _cellCenter(
                              item.jenisPekerjaan,
                              col4,
                              rowHeight,
                              null,
                              isEvenRow: isEvenRow,
                              isHovered: isHovered,
                            ),
                            _cellCenter(
                              item.standarPerawatan,
                              col5,
                              rowHeight,
                              null,
                              isEvenRow: isEvenRow,
                              isHovered: isHovered,
                            ),
                            _cellCenter(
                              item.alatBahan,
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
                    item.periode,
                    col3,
                    rowHeight,
                    null,
                    isEvenRow: isEvenRow,
                    isHovered: isHovered,
                  ),
                  _cellCenter(
                    item.jenisPekerjaan,
                    col4,
                    rowHeight,
                    null,
                    isEvenRow: isEvenRow,
                    isHovered: isHovered,
                  ),
                  _cellCenter(
                    item.standarPerawatan,
                    col5,
                    rowHeight,
                    null,
                    isEvenRow: isEvenRow,
                    isHovered: isHovered,
                  ),
                  _cellCenter(
                    item.alatBahan,
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
    CheckSheetModel item,
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
    final scheduleMap = {
      "no": item.no,
      "nama_infrastruktur": item.namaInfrastruktur,
      "bagian": item.bagian,
      "periode": item.periode,
      "jenis_pekerjaan": item.jenisPekerjaan,
      "standar_perawatan": item.standarPerawatan,
      "alat_bahan": item.alatBahan,
      "tanggal_status": Map<int, String>.from(item.tanggalStatus),
    };

    ModalEditChecksheet.show(
      context,
      scheduleMap,
                (updatedItem) async {
        final updatedTanggalStatus =
            (updatedItem["tanggal_status"] as Map<int, String>?) ??
                item.tanggalStatus;
        final updatedSchedule = item.copyWith(
          namaInfrastruktur:
              updatedItem["nama_infrastruktur"] ?? item.namaInfrastruktur,
          bagian: updatedItem["bagian"] ?? item.bagian,
          periode: updatedItem["periode"] ?? item.periode,
          jenisPekerjaan:
              updatedItem["jenis_pekerjaan"] ?? item.jenisPekerjaan,
          standarPerawatan: updatedItem["standar_perawatan"] ??
              item.standarPerawatan,
          alatBahan: updatedItem["alat_bahan"] ?? item.alatBahan,
          tanggalStatus: Map<int, String>.from(updatedTanggalStatus),
        );

                  try {
                    await widget.checkSheetController.updateSchedule(updatedSchedule);
                    if (mounted) {
                      setState(() {});
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Bagian ${updatedSchedule.bagian} berhasil diupdate",
                            ),
                            backgroundColor: Color(0xFF2196F3),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal mengupdate: $e'),
                          backgroundColor: Color(0xFFF44336),
                        ),
                      );
                    }
                  }
      },
    );
            },
          ),
          const SizedBox(width: 8),
          _iconButton(
            icon: Icons.delete,
            color: Color(0xFFF44336),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Konfirmasi Hapus'),
                  content: Text(
                    'Apakah Anda yakin ingin menghapus:\n${item.namaInfrastruktur} - ${item.bagian}?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF44336),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Hapus'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                if (!mounted) return;
                
                try {
                  await widget.checkSheetController.deleteSchedule(item.no);
                  
                  // Tunggu sedikit untuk memastikan operasi delete selesai
                  await Future.delayed(Duration(milliseconds: 100));
                  
                  if (mounted) {
                    setState(() {});
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${item.namaInfrastruktur} - ${item.bagian} berhasil dihapus',
                          ),
                          backgroundColor: Color(0xFF0A9C5D),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus: $e'),
                        backgroundColor: Color(0xFFF44336),
                      ),
                    );
                  }
                }
              }
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

  // Method untuk menampilkan modal tambah schedule
  void _showTambahScheduleModal(BuildContext context) {
    ModalTambahChecksheet.show(
      context: context,
      checkSheetController: widget.checkSheetController,
      onSuccess: () async {
        // Tunggu sedikit untuk memastikan modal tertutup
        await Future.delayed(Duration(milliseconds: 100));
        if (mounted) {
          await _loadData();
        }
      },
    );
  }
}
