import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_maintenance/controller/maintenance_schedule_controller.dart';
import 'package:monitoring_maintenance/model/mt_schedule_model.dart';
import 'package:monitoring_maintenance/screen/admin/widgets/mdl_tambah_maintenance_schedule.dart';
import 'package:intl/intl.dart';

/// Maintenance Schedule dalam format tabel
class MaintenanceSchedulePage extends StatefulWidget {
  final MaintenanceScheduleController controller;

  const MaintenanceSchedulePage({super.key, required this.controller});

  @override
  State<MaintenanceSchedulePage> createState() =>
      _MaintenanceSchedulePageState();
}

class _MaintenanceSchedulePageState extends State<MaintenanceSchedulePage> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  bool _isSyncing = false;
  String? _hoveredRowKey;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
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
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.controller.loadSchedules();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  List<MtSchedule> _getFilteredSchedules() {
    return widget.controller.filterSchedules(searchQuery: _searchQuery);
  }

  Map<String, List<MtSchedule>> _groupByAsset() {
    return widget.controller.groupByAsset(_getFilteredSchedules());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Maintenance Schedule",
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
                    hintText: "Cari asset, bagian mesin, periode, status, catatan...",
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
              onPressed: () {
                ModalTambahMaintenanceSchedule.show(
                  context,
                  controller: widget.controller,
                  onSuccess: () {
                    setState(() {});
                  },
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
                elevation: 2,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
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

    const double colNo = 50.0;
    const double col1 = 150.0; // NAMA ASSET
    const double col2 = 130.0; // BAGIAN MESIN
    const double col3 = 100.0; // PERIODE
    const double col4 = 80.0; // INTERVAL
    const double col5 = 120.0; // TGL MULAI
    const double col6 = 120.0; // TGL JADWAL
    const double col7 = 120.0; // TGL SELESAI
    const double col8 = 120.0; // STATUS
    const double col9 = 150.0; // CATATAN
    const double col10 = 150.0; // AKSI

    const double fixedColumnsWidth = colNo + col1 + col2 + col3 + col4 + col5 + col6 + col7 + col8 + col9 + col10;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalTableWidth = fixedColumnsWidth;
        final needsScroll = totalTableWidth > constraints.maxWidth;

        Widget headerRowContent = Row(
          children: [
            _headerCell("NO", colNo, rowHeight, headerStyle),
            _headerCell("NAMA ASSET", col1, rowHeight, headerStyle),
            _headerCell("BAGIAN MESIN", col2, rowHeight, headerStyle),
            _headerCell("PERIODE", col3, rowHeight, headerStyle),
            _headerCell("INTERVAL", col4, rowHeight, headerStyle),
            _headerCell("TGL MULAI", col5, rowHeight, headerStyle),
            _headerCell("TGL JADWAL", col6, rowHeight, headerStyle),
            _headerCell("TGL SELESAI", col7, rowHeight, headerStyle),
            _headerCell("STATUS", col8, rowHeight, headerStyle),
            _headerCell("CATATAN", col9, rowHeight, headerStyle),
            _headerCell("AKSI", col10, rowHeight, headerStyle),
          ],
        );

        Widget tableBody = Padding(
          padding: const EdgeInsets.only(bottom: horizontalScrollbarPadding),
          child: _buildTableBody(context),
        );

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

  Widget _buildTableBody(BuildContext context) {
    const double rowHeight = 65.0;

    const double colNo = 50.0;
    const double col1 = 150.0;
    const double col2 = 130.0;
    const double col3 = 100.0;
    const double col4 = 80.0;
    const double col5 = 120.0;
    const double col6 = 120.0;
    const double col7 = 120.0;
    const double col8 = 120.0;
    const double col9 = 150.0;
    const double col10 = 150.0;

    Map<String, List<MtSchedule>> grouped = _groupByAsset();

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
    grouped.forEach((assetName, schedules) {
      int totalRows = schedules.length;
      double mergedHeight = rowHeight * totalRows;
      bool isEvenRow = rowIndex % 2 == 0;

      String rowKey = "${assetName}_$rowIndex";
      bool isHovered = _hoveredRowKey == rowKey;

      List<Widget> scheduleRows = [];

      for (var schedule in schedules) {
        scheduleRows.add(
          SizedBox(
            height: rowHeight,
            child: Row(
              children: [
                _cellCenter(
                  schedule.template?.bagianMesinName ?? '-',
                  col2,
                  rowHeight,
                  null,
                  isEvenRow: isEvenRow,
                  isHovered: isHovered,
                ),
                _cellCenter(
                  schedule.template?.periode ?? '-',
                  col3,
                  rowHeight,
                  null,
                  isEvenRow: isEvenRow,
                  isHovered: isHovered,
                ),
                _cellCenter(
                  schedule.template?.intervalPeriode?.toString() ?? '-',
                  col4,
                  rowHeight,
                  null,
                  isEvenRow: isEvenRow,
                  isHovered: isHovered,
                ),
                _cellCenter(
                  schedule.template?.startDate != null
                      ? DateFormat('dd MMM yyyy', 'id_ID')
                          .format(schedule.template!.startDate!)
                      : '-',
                  col5,
                  rowHeight,
                  null,
                  isEvenRow: isEvenRow,
                  isHovered: isHovered,
                ),
                _cellCenter(
                  schedule.tglJadwal != null
                      ? DateFormat('dd MMM yyyy', 'id_ID')
                          .format(schedule.tglJadwal!)
                      : '-',
                  col6,
                  rowHeight,
                  null,
                  isEvenRow: isEvenRow,
                  isHovered: isHovered,
                ),
                _cellCenter(
                  schedule.tglSelesai != null
                      ? DateFormat('dd MMM yyyy', 'id_ID')
                          .format(schedule.tglSelesai!)
                      : '-',
                  col7,
                  rowHeight,
                  null,
                  isEvenRow: isEvenRow,
                  isHovered: isHovered,
                ),
                _cellCenter(
                  _getStatusBadge(schedule.status),
                  col8,
                  rowHeight,
                  null,
                  isEvenRow: isEvenRow,
                  isHovered: isHovered,
                ),
                _cellCenter(
                  schedule.catatan ?? '-',
                  col9,
                  rowHeight,
                  null,
                  isEvenRow: isEvenRow,
                  isHovered: isHovered,
                ),
                _actionCell(
                  context,
                  schedule,
                  col10,
                  rowHeight,
                  isEvenRow: isEvenRow,
                  isHovered: isHovered,
                ),
              ],
            ),
          ),
        );
      }

      dataRows.add(
        MouseRegion(
          onEnter: (_) => setState(() => _hoveredRowKey = rowKey),
          onExit: (_) => setState(() => _hoveredRowKey = null),
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
                  assetName,
                  col1,
                  mergedHeight,
                  null,
                  isEvenRow: isEvenRow,
                  isHovered: isHovered,
                ),
                Column(children: scheduleRows),
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

  String _getStatusBadge(String status) {
    switch (status.toLowerCase()) {
      case 'perlu maintenance':
        return 'Perlu Maintenance';
      case 'sedang maintenance':
        return 'Sedang Maintenance';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
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
    MtSchedule schedule,
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
              // Navigate to schedule/calendar page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Fitur Kalender Maintenance untuk ${schedule.assetName ?? 'Asset'}"),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _iconButton(
            icon: Icons.edit,
            color: Color(0xFF2196F3),
            onPressed: () {
              _showEditScheduleModal(context, schedule);
            },
          ),
          const SizedBox(width: 8),
          _iconButton(
            icon: Icons.delete,
            color: Color(0xFFF44336),
            onPressed: () {
              _showDeleteConfirmation(context, schedule);
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


  void _showEditScheduleModal(BuildContext context, MtSchedule schedule) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Fitur Edit Maintenance Schedule untuk ${schedule.assetName ?? 'Asset'}"),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MtSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Schedule'),
        content: Text(
          'Apakah Anda yakin ingin menghapus schedule untuk ${schedule.assetName ?? 'asset ini'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (schedule.id != null) {
                try {
                  await widget.controller.deleteSchedule(schedule.id!);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Schedule berhasil dihapus'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    setState(() {});
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
