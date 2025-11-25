import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:monitoring_maintenance/controller/check_sheet_controller.dart';
import 'package:monitoring_maintenance/model/check_sheet_model.dart';
import 'package:monitoring_maintenance/repositories/asset_supabase_repository.dart';
import 'package:monitoring_maintenance/repositories/check_sheet_template_repository.dart';

import 'kalender_pengecekan_page.dart';
import 'mdl_edit_checksheet.dart';

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
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.checkSheetController.loadFromSupabase();
    } catch (e) {
      print('Error loading data: $e');
      // Fallback ke sample data jika error
      widget.checkSheetController.initializeSampleData();
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
            Text(
              'Memuat data dari Supabase...',
              style: TextStyle(color: Colors.grey[600]),
            ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Bagian ${updatedSchedule.bagian} berhasil diupdate",
                ),
                backgroundColor: Color(0xFF2196F3),
              ),
            );
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
              // Konfirmasi delete
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
                try {
                  await widget.checkSheetController.deleteSchedule(item.no);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${item.namaInfrastruktur} - ${item.bagian} berhasil dihapus',
                      ),
                      backgroundColor: Color(0xFF0A9C5D),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Color(0xFFF44336),
                    ),
                  );
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

  void _showTambahScheduleModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final repository = CheckSheetTemplateRepository();
    String? selectedAssetId;
    String? selectedAssetName;
    List<Map<String, dynamic>> availableKomponen = [];
    bool isLoadingKomponen = false;
    final List<KomponenScheduleItem> komponenList = [];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Load assets untuk dropdown
            Future<List<Map<String, dynamic>>> loadAssets() async {
              try {
                final assetRepo = AssetSupabaseRepository();
                final assets = await assetRepo.getAllAssets();
                return assets;
              } catch (e) {
                print('Error loading assets: $e');
                return [];
              }
            }

            // Load komponen dari asset yang dipilih dan otomatis tambahkan ke list
            Future<void> loadKomponenFromAsset(String assetId) async {
              setModalState(() {
                isLoadingKomponen = true;
                komponenList.clear(); // Clear list sebelumnya
              });

              try {
                // Gunakan method khusus untuk mengambil komponen berdasarkan asset ID
                final filtered = await repository.getKomponenByAssetId(assetId);
                print('✅ Ditemukan ${filtered.length} komponen untuk asset $assetId');
                
                // Otomatis tambahkan semua komponen ke list
                setModalState(() {
                  for (var komponen in filtered) {
                    final komponenId = komponen['id']?.toString();
                    if (komponenId != null) {
                      final komponenItem = KomponenScheduleItem();
                      komponenItem.selectedKomponenId = komponenId;
                      komponenList.add(komponenItem);
                    }
                  }
                  isLoadingKomponen = false;
                });
              } catch (e) {
                print('❌ Error loading komponen: $e');
                setModalState(() {
                  isLoadingKomponen = false;
                });
              }
            }
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
                              // Dropdown Asset
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: loadAssets(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                  
                                  final assets = snapshot.data ?? [];
                                  
                                  return DropdownButtonFormField<String>(
                                    value: selectedAssetId,
                                    decoration: _modalInputDecoration(
                                      label: "Pilih Asset/Infrastruktur",
                                      icon: Icons.precision_manufacturing,
                                    ),
                                    hint: Text("Pilih asset"),
                                    items: assets.map((asset) {
                                      final id = asset['id']?.toString() ?? '';
                                      final nama = asset['nama_assets'] as String? ?? 
                                                   asset['nama_aset'] as String? ?? 
                                                   'Unknown';
                                      return DropdownMenuItem(
                                        value: id,
                                        child: Text(nama),
                                      );
                                    }).toList(),
                                    onChanged: (value) async {
                                      if (value != null) {
                                        final asset = assets.firstWhere(
                                          (a) => a['id']?.toString() == value,
                                        );
                                        final nama = asset['nama_assets'] as String? ?? 
                                                     asset['nama_aset'] as String? ?? 
                                                     'Unknown';
                                        setModalState(() {
                                          selectedAssetId = value;
                                          selectedAssetName = nama;
                                          komponenList.clear();
                                        });
                                        await loadKomponenFromAsset(value);
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Asset wajib dipilih";
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              // Komponen List (muncul setelah asset dipilih)
                              if (selectedAssetId != null) ...[
                                if (isLoadingKomponen)
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(color: Color(0xFF0A9C5D)),
                                          SizedBox(height: 12),
                                          Text(
                                            'Memuat komponen dari asset...',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else if (komponenList.isEmpty)
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.orange[700]),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Asset ini belum memiliki komponen. Silakan tambahkan komponen terlebih dahulu di menu Data Assets.',
                                            style: TextStyle(color: Colors.orange[900]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Komponen dan Detail Pekerjaan (${komponenList.length} komponen)",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // FutureBuilder untuk load nama komponen
                                  FutureBuilder<List<Map<String, dynamic>>>(
                                    future: repository.getKomponenAssets(),
                                    builder: (context, komponenSnapshot) {
                                      if (!komponenSnapshot.hasData) {
                                        return Center(child: CircularProgressIndicator());
                                      }
                                      
                                      final allKomponen = komponenSnapshot.data ?? [];
                                      
                                      return Column(
                                        children: komponenList.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          KomponenScheduleItem komponenItem = entry.value;
                                          
                                          // Cari data komponen berdasarkan ID
                                          final komponenData = allKomponen.firstWhere(
                                            (k) => k['id']?.toString() == komponenItem.selectedKomponenId,
                                            orElse: () => <String, dynamic>{},
                                          );
                                          
                                          // Ambil nama komponen dari komponen_assets
                                          // Field di komponen_assets adalah 'nama_bagian' (bukan 'nama_komponen')
                                          final namaKomponen = komponenData['nama_bagian'] as String? ?? 
                                                               komponenData['nama_komponen'] as String? ?? 
                                                               'Unknown';
                                          final bgMesin = komponenData['bg_mesin'] as Map<String, dynamic>?;
                                          final namaBagianMesin = bgMesin?['nama_bagian'] as String? ?? '';
                                          
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
                                                        "Komponen ${index + 1}",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    if (komponenList.length > 1)
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.remove_circle,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                        onPressed: () {
                                                          setModalState(() {
                                                            komponenItem.dispose();
                                                            komponenList.removeAt(index);
                                                          });
                                                        },
                                                      ),
                                                  ],
                                                ),
                                                SizedBox(height: 12),

                                                // Display Nama Komponen (read-only)
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.grey[300]!),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.category, color: Colors.grey[600], size: 20),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Nama Komponen',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.grey[600],
                                                              ),
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              namaBagianMesin.isNotEmpty 
                                                                  ? '$namaBagianMesin - $namaKomponen'
                                                                  : namaKomponen,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                                color: Colors.grey[800],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 12),

                                                          DropdownButtonFormField<String>(
                                                  value: komponenItem.selectedPeriode,
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
                                                      komponenItem.selectedPeriode = value;
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

                                                if (komponenItem.selectedPeriode != null) ...[
                                                  _buildIntervalSpinBox(
                                                    bagian: komponenItem,
                                                    setModalState: setModalState,
                                                  ),
                                                  SizedBox(height: 12),
                                                ],

                                                _modalTextField(
                                                  controller: komponenItem.jenisPekerjaanController,
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
                                                  controller: komponenItem.standarPerawatanController,
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
                                                  controller: komponenItem.alatBahanController,
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
                                      );
                                    },
                                  ),
                                ],
                              ],
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
                          isLoadingKomponen
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text("Menyimpan..."),
                                    ],
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () async {
                                    if (!(formKey.currentState?.validate() ?? false)) {
                                      return;
                                    }

                                    if (selectedAssetId == null || selectedAssetName == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Pilih asset terlebih dahulu'),
                                          backgroundColor: Color(0xFFF44336),
                                        ),
                                      );
                                      return;
                                    }

                                    // Set loading state
                                    setModalState(() {
                                      isLoadingKomponen = true;
                                    });

                            try {
                              int savedCount = 0;
                              // Simpan setiap komponen sebagai cek sheet template terpisah
                              for (var komponenItem in komponenList) {
                                if (komponenItem.selectedKomponenId == null) {
                                  continue;
                                }

                                String intervalUnit = "";
                                switch (komponenItem.selectedPeriode) {
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
                                
                                final interval = int.tryParse(komponenItem.intervalController.text.trim()) ?? 1;
                                final periodeEnum = komponenItem.selectedPeriode ?? 'Harian';

                                try {
                                  await widget.checkSheetController.addCheckSheetTemplate(
                                    komponenAssetsId: komponenItem.selectedKomponenId!,
                                    periode: periodeEnum,
                                    intervalPeriode: interval,
                                    jenisPekerjaan: komponenItem.jenisPekerjaanController.text.trim(),
                                    stdPrwtn: komponenItem.standarPerawatanController.text.trim(),
                                    alatBahan: komponenItem.alatBahanController.text.trim(),
                                  );
                                  savedCount++;
                                  print('✅ Komponen ${savedCount} berhasil disimpan');
                                } catch (e) {
                                  print('❌ Error menyimpan komponen: $e');
                                  // Continue dengan komponen berikutnya
                                }
                              }

                              // Close dialog first before reloading data
                              if (mounted) {
                                Navigator.of(dialogContext).pop();
                                
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Cek sheet untuk ${selectedAssetName} berhasil ditambahkan dengan $savedCount komponen",
                                    ),
                                    backgroundColor: Color(0xFF0A9C5D),
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                // Reload data after a short delay to avoid freeze
                                Future.delayed(Duration(milliseconds: 300), () async {
                                  if (mounted) {
                                    try {
                                      await _loadData();
                                      print('✅ Data berhasil di-reload');
                                    } catch (e) {
                                      print('⚠️ Error reload data: $e');
                                      // Data sudah tersimpan, error reload tidak critical
                                    }
                                  }
                                });
                              }
                            } catch (e, stackTrace) {
                              print('❌ Error menyimpan cek sheet: $e');
                              print('Stack trace: $stackTrace');
                              
                              setModalState(() {
                                isLoadingKomponen = false;
                              });
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal menyimpan: ${e.toString()}'),
                                    backgroundColor: Color(0xFFF44336),
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              }
                            }
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
      for (var komponen in komponenList) {
        komponen.dispose();
      }
    });
  }

  Widget _buildIntervalSpinBox({
    required dynamic bagian, // Bisa BagianScheduleItem atau KomponenScheduleItem
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
                          "Interval (${bagian.selectedPeriode ?? 'Harian'})",
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

class KomponenScheduleItem {
  String? selectedKomponenId;
  String? selectedPeriode;
  final TextEditingController intervalController = TextEditingController();
  final TextEditingController jenisPekerjaanController = TextEditingController();
  final TextEditingController standarPerawatanController = TextEditingController();
  final TextEditingController alatBahanController = TextEditingController();

  void dispose() {
    intervalController.dispose();
    jenisPekerjaanController.dispose();
    standarPerawatanController.dispose();
    alatBahanController.dispose();
  }
}