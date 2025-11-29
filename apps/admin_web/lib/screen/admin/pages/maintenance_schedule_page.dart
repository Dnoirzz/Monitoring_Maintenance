import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared/controllers/maintenance_schedule_page_controller.dart';
import 'package:shared/models/mt_schedule_model.dart';
import 'package:admin_web/screen/admin/widgets/mdl_tambah_maintenance_schedule.dart';
import 'package:shared/repositories/maintenance_schedule_repository.dart';
import 'package:shared/services/maintenance_schedule/calendar_service.dart';
import 'package:shared/services/maintenance_schedule/maintenance_dialog_service.dart';
import 'package:shared/services/maintenance_schedule/maintenance_date_service.dart';
import 'package:shared/services/maintenance_schedule/maintenance_edit_service.dart';

/// Maintenance Schedule dalam format kalender tahunan (mirip Excel)
class MaintenanceSchedulePage extends StatefulWidget {
  const MaintenanceSchedulePage({super.key});

  @override
  State<MaintenanceSchedulePage> createState() =>
      _MaintenanceSchedulePageState();
}

class _MaintenanceSchedulePageState extends State<MaintenanceSchedulePage> {
  final MaintenanceSchedulePageController _pageController = MaintenanceSchedulePageController();
  String? _hoveredRowKey;
  String _searchQuery = '';
  bool _isLoading = false;
  int _selectedYear = DateTime.now().year;
  String? _filterJenisAset;
  final MaintenanceScheduleRepository _repository = MaintenanceScheduleRepository();
  List<MtSchedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _pageController.init(onSearchChange: (text) {
      setState(() {
        _searchQuery = text;
      });
    });
  }

  Future<void> _loadSchedules() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    try {
      _schedules = await _repository.getAllSchedules();
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
    _pageController.dispose();
    super.dispose();
  }

  void _handleHeaderPointerSignal(PointerSignalEvent event) {
    _pageController.handleHeaderPointerSignal(event);
  }

  List<MtSchedule> _getFilteredSchedules() {
    return CalendarService.filterSchedules(
      _schedules,
      _searchQuery,
      _filterJenisAset,
    );
  }

  // Group schedules by asset and bagian mesin
  Map<String, Map<String, List<MtSchedule>>> _groupSchedules() {
    return CalendarService.groupSchedules(
      _getFilteredSchedules(),
      _selectedYear,
    );
  }

  double _measureTextWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return tp.size.width;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Maintenance Schedule - $_selectedYear",
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
              onPressed: () async {
                await _loadSchedules();
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        if (_filterJenisAset != null) ...[
          Row(
            children: [
              Chip(
                label: Text('Kategori: ${_filterJenisAset}'),
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
          SizedBox(height: 12),
        ],

        // Search bar dan controls
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
                  controller: _pageController.searchController,
                  decoration: InputDecoration(
                    hintText: "Cari mesin...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF0A9C5D)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _pageController.searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
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
              child: DropdownButton<String> (
                value: _filterJenisAset,
                hint: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list, color: Color(0xFF0A9C5D), size: 20),
                      SizedBox(width: 8),
                      Text('Filter Kategori'),
                    ],
                  ),
                ),
                items: const [
                  DropdownMenuItem<String> (value: null, child: Text('Semua Kategori')),
                  DropdownMenuItem<String> (value: 'Mesin Produksi', child: Text('Mesin Produksi')),
                  DropdownMenuItem<String> (value: 'Alat Berat', child: Text('Alat Berat')),
                  DropdownMenuItem<String> (value: 'Listrik', child: Text('Listrik')),
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
            // Year selector
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
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: Color(0xFF0A9C5D)),
                    onPressed: () {
                      setState(() {
                        _selectedYear--;
                      });
                    },
                  ),
                  Text(
                    '$_selectedYear',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF022415),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: Color(0xFF0A9C5D)),
                    onPressed: () {
                      setState(() {
                        _selectedYear++;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                ModalTambahMaintenanceSchedule.show(
                  context,
                  pageController: _pageController,
                  selectedYear: _selectedYear,
                  onSuccess: () async {
                    await _loadSchedules();
                  },
                );
              },
              icon: Icon(Icons.add),
              label: Text("Tambah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A9C5D),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        // Calendar table
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
                  child: _buildCalendarTable(context),
                ),
        ),
      ],
    );
  }

  Widget _buildCalendarTable(BuildContext context) {
    const double rowHeight = 40.0;
    final filtered = _getFilteredSchedules();

    final headerStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11);
    final bodyStyle = TextStyle(fontSize: 10, color: Colors.grey[800]);
    final weekHeaderStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9);

    double colName = 0;
    double colBagian = 0;
    double colPeriode = 0;
    double colAction = 0;
    double colPlanActual = 0;
    double cellWidth = 0;

    colName = [
      _measureTextWidth('NAMA MESIN', headerStyle),
      ...filtered.map((s) => _measureTextWidth(s.assetName ?? '', bodyStyle)),
    ].fold<double>(0, (p, c) => c > p ? c : p) + 24;

    colBagian = [
      _measureTextWidth('BAGIAN MESIN', headerStyle),
      ...filtered.map((s) => _measureTextWidth(s.template?.bagianMesinName ?? '', bodyStyle)),
    ].fold<double>(0, (p, c) => c > p ? c : p) + 24;

    colPeriode = [
      _measureTextWidth('LIFT TIME\nMESIN / HARI', headerStyle),
      ...filtered.map((s) => _measureTextWidth('${s.template?.intervalPeriode ?? '-'} ${(s.template?.periode ?? '-').toLowerCase()}', bodyStyle)),
    ].fold<double>(0, (p, c) => c > p ? c : p) + 24;

    colAction = 24 + 28 + 8 + 28; // padding + 2 icon buttons + spacing

    colPlanActual = [
      _measureTextWidth('PVL', headerStyle),
      _measureTextWidth('PLAN', bodyStyle),
      _measureTextWidth('ACTUAL', bodyStyle),
    ].fold<double>(0, (p, c) => c > p ? c : p) + 24;

    cellWidth = _measureTextWidth('W48', weekHeaderStyle) + 12;

    final months = [
      'JANUARI', 'FEBRUARI', 'MARET', 'APRIL', 'MEI', 'JUNI',
      'JULI', 'AGUSTUS', 'SEPTEMBER', 'OKTOBER', 'NOVEMBER', 'DESEMBER'
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: _pageController.horizontalScrollController,
          thumbVisibility: true,
          child: Stack(
            children: [
              Column(
                children: [
                  // Header spacing
                  SizedBox(height: rowHeight * 2),
                  // Body
                  Expanded(
                    child: Scrollbar(
                      controller: _pageController.verticalScrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _pageController.verticalScrollController,
                        child: SingleChildScrollView(
                          controller: _pageController.horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: _buildTableBody(
                            colName, colBagian, colPeriode, colAction, colPlanActual, cellWidth, rowHeight,
                          ),
                          ),
                      ),
                    ),
                  ),
                ],
              ),
              // Fixed header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerSignal: _handleHeaderPointerSignal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      controller: _pageController.headerScrollController,
                      scrollDirection: Axis.horizontal,
                      child: _buildHeader(
                        months, colName, colBagian, colPeriode, colAction, colPlanActual, cellWidth, rowHeight,
                      ),
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

  Widget _buildHeader(List<String> months, double colName, double colBagian,
      double colPeriode, double colAction, double colPlanActual, double cellWidth, double rowHeight) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A9C5D), Color(0xFF088A52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fixed columns (rowspan 2)
            Column(
              children: [
                _fixedHeaderCell('NAMA MESIN', colName, rowHeight * 2, rowSpan: 2),
              ],
            ),
            Column(
              children: [
                _fixedHeaderCell('BAGIAN MESIN', colBagian, rowHeight * 2, rowSpan: 2),
              ],
            ),
            Column(
              children: [
                _fixedHeaderCell('LIFT TIME\nMESIN / HARI', colPeriode, rowHeight * 2, rowSpan: 2),
              ],
            ),
            Column(
              children: [
                _fixedHeaderCell('AKSI', colAction, rowHeight * 2, rowSpan: 2),
              ],
            ),
            Column(
              children: [
                _fixedHeaderCell('PVL', colPlanActual, rowHeight * 2, rowSpan: 2),
              ],
            ),
            // Month columns (each with 4 weeks)
            ...List.generate(12, (monthIndex) {
              int weekStart = monthIndex * 4 + 1;
              return Column(
                children: [
                  _monthHeaderCell(
                    '${months[monthIndex]}\n$_selectedYear',
                    cellWidth * 4,
                    rowHeight,
                  ),
                  Row(
                    children: List.generate(4, (weekIndex) {
                      int weekNumber = weekStart + weekIndex;
                      return _dayHeaderCell('W$weekNumber', cellWidth, rowHeight);
                    }),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _fixedHeaderCell(String text, double width, double height, {int rowSpan = 1}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
          bottom: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
        ),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _monthHeaderCell(String text, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
          bottom: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
        ),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _dayHeaderCell(String text, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
          bottom: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
        ),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableBody(double colName, double colBagian, double colPeriode,
      double colAction, double colPlanActual, double cellWidth, double rowHeight) {
    final grouped = _groupSchedules();

    if (grouped.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                "Tidak ada jadwal untuk tahun $_selectedYear",
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    List<Widget> rows = [];
    int rowIndex = 0;

    grouped.forEach((assetName, bagianMap) {
      bagianMap.forEach((bagianMesin, schedules) {
        bool isEvenRow = rowIndex % 2 == 0;
        String rowKey = "${assetName}_${bagianMesin}_$rowIndex";
        bool isHovered = _hoveredRowKey == rowKey;

        // Get periode info
        String periode = schedules.first.template?.periode ?? '-';
        int? intervalPeriode = schedules.first.template?.intervalPeriode;

        // Build PLAN row
        rows.add(
          MouseRegion(
            onEnter: (_) => setState(() => _hoveredRowKey = rowKey),
            onExit: (_) => setState(() => _hoveredRowKey = null),
            child: Row(
              children: [
                _dataCell(assetName, colName, rowHeight * 2, isEvenRow, isHovered, rowSpan: 2), // Merge 2 rows
                _dataCell(bagianMesin, colBagian, rowHeight * 2, isEvenRow, isHovered, rowSpan: 2), // Merge 2 rows
                _dataCell(
                  '${intervalPeriode ?? '-'} ${periode.toLowerCase()}',
                  colPeriode,
                  rowHeight * 2,
                  isEvenRow,
                  isHovered,
                  rowSpan: 2,
                ), // Merge 2 rows
                _actionCell(colAction, rowHeight * 2, isEvenRow, isHovered, schedules),
                Column(
                  children: [
                    _dataCell('PLAN', colPlanActual, rowHeight, isEvenRow, isHovered),
                    _dataCell('ACTUAL', colPlanActual, rowHeight, isEvenRow, isHovered),
                  ],
                ),
                // Calendar cells for PLAN and ACTUAL
                Column(
                  children: [
                    // PLAN row
                    Row(
                      children: List.generate(12, (monthIndex) {
                        return Row(
                          children: List.generate(4, (weekIndex) {
                            int startDay = weekIndex * 7 + 1;
                            int endDay = (weekIndex + 1) * 7;
                            
                            MtSchedule? scheduleInWeek;
                            for (var schedule in schedules) {
                              if (schedule.tglJadwal != null &&
                                  schedule.tglJadwal!.year == _selectedYear &&
                                  schedule.tglJadwal!.month == monthIndex + 1 &&
                                  schedule.tglJadwal!.day >= startDay &&
                                  schedule.tglJadwal!.day <= endDay) {
                                scheduleInWeek = schedule;
                                break;
                              }
                            }

                            return _calendarCell(
                              cellWidth,
                              rowHeight,
                              isEvenRow,
                              isHovered,
                              scheduleInWeek,
                              DateTime(_selectedYear, monthIndex + 1, startDay),
                              isPlan: true,
                            );
                          }),
                        );
                      }),
                    ),
                    // ACTUAL row
                    Row(
                      children: List.generate(12, (monthIndex) {
                        return Row(
                          children: List.generate(4, (weekIndex) {
                            // Cari schedule dengan ACTUAL date dalam minggu ini
                            // ACTUAL bisa berada di bulan berbeda dengan month display saat ini
                            MtSchedule? scheduleInWeek;
                            for (var schedule in schedules) {
                              if (schedule.tglSelesai != null && schedule.status.toLowerCase() == 'selesai') {
                                // Hitung minggu ke berapa dalam tahun untuk actual date
                                final actualDate = schedule.tglSelesai!;
                                
                                // Hanya tampilkan jika dalam tahun yang sama
                                if (actualDate.year != _selectedYear) continue;
                                
                                // Hitung minggu dalam bulan untuk actual date
                                int actualMonth = actualDate.month;
                                int actualDay = actualDate.day;
                                
                                // Hitung minggu (0-3) dari hari dalam bulan
                                int actualWeekInMonth = (actualDay - 1) ~/ 7;
                                
                                // Jika month yang ditampilkan sama dengan bulan actual, cek minggu
                                if (actualMonth == monthIndex + 1) {
                                  if (actualWeekInMonth == weekIndex) {
                                    scheduleInWeek = schedule;
                                    break;
                                  }
                                }
                              }
                            }

                            return _calendarCell(
                              cellWidth,
                              rowHeight,
                              isEvenRow,
                              isHovered,
                              scheduleInWeek,
                              DateTime(_selectedYear, monthIndex + 1, weekIndex * 7 + 1),
                              isPlan: false,
                            );
                          }),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        rowIndex++;
      });
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(children: rows),
    );
  }

  Widget _dataCell(String text, double width, double height, bool isEvenRow, bool isHovered, {int rowSpan = 1}) {
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
          right: BorderSide(color: Colors.grey[400]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[400]!, width: 0.5),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[800],
          fontWeight: text == 'PLAN' || text == 'ACTUAL' ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _actionCell(double width, double height, bool isEvenRow, bool isHovered, List<MtSchedule> schedules) {
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
          right: BorderSide(color: Colors.grey[400]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[400]!, width: 0.5),
        ),
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _iconButton(
            icon: Icons.edit,
            color: Color(0xFF2196F3),
            onPressed: () {
              if (schedules.isNotEmpty) {
                _showEditScheduleModal(context, schedules.first);
              }
            },
          ),
          SizedBox(width: 8),
          _iconButton(
            icon: Icons.delete,
            color: Color(0xFFF44336),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Konfirmasi Hapus'),
                  content: Text('Hapus semua jadwal untuk baris ini di tahun $_selectedYear?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600], foregroundColor: Colors.white),
                      child: Text('Hapus'),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              
              try {
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Menghapus jadwal...'),
                      ],
                    ),
                  ),
                );

                // Collect all IDs to delete
                final idsToDelete = schedules
                    .where((s) => s.id != null)
                    .map((s) => s.id!)
                    .toList();

                // Batch delete menggunakan optimized method
                if (idsToDelete.isNotEmpty) {
                  // Get template IDs sebelum delete schedules
                  final templateIds = await _repository.getTemplateIdsByScheduleIds(idsToDelete);
                  
                  // Delete schedules
                  await _repository.batchDeleteSchedulesByIds(idsToDelete);
                  
                  // Delete templates yang tidak punya schedule lain
                  for (final templateId in templateIds) {
                    await _repository.deleteTemplateIfNoSchedules(templateId);
                  }
                }

                await _loadSchedules();
                
                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${idsToDelete.length} jadwal berhasil dihapus')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
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
          width: 28,
          height: 28,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  Widget _calendarCell(double width, double height, bool isEvenRow,
      bool isHovered, MtSchedule? schedule, DateTime cellDate, {bool isPlan = true}) {
    Color backgroundColor;
    String text = '';
    bool isClickable = false;
    
    if (schedule != null) {
      if (isPlan) {
        // PLAN row - warna berdasarkan apakah sudah dikerjakan (selesai)
        if (schedule.tglSelesai != null && schedule.status.toLowerCase() == 'selesai') {
          // Sudah dikerjakan - BIRU
          backgroundColor = Colors.blue[600]!;
          text = '${schedule.tglJadwal?.day ?? ''}';
        } else {
          // Belum dikerjakan - KUNING
          backgroundColor = Colors.yellow[600]!;
          text = '${schedule.tglJadwal?.day ?? ''}';
        }
        isClickable = true;
      } else {
        // ACTUAL row - menampilkan tanggal realisasi (HIJAU) atau kosong (edit)
        if (schedule.tglSelesai != null && schedule.status.toLowerCase() == 'selesai') {
          // Sudah ada actual date - tampilkan hijau dengan tanggal
          backgroundColor = Colors.green[600]!;
          text = '${schedule.tglSelesai!.day}';
          isClickable = true;
        } else {
          // Belum ada actual date - cell kosong, bisa di-klik untuk input
          backgroundColor = isEvenRow ? Colors.grey[100]! : Colors.white;
          text = '';
          isClickable = true;
        }
      }
    } else {
      // No schedule - alternate row colors (tidak clickable)
      backgroundColor = isEvenRow ? Colors.grey[100]! : Colors.white;
      isClickable = false;
    }

    return InkWell(
      onTap: (schedule != null && isClickable)
          ? () {
              if (isPlan) {
                // PLAN: buka context menu untuk edit tanggal
                _showPlanContextMenu(context, schedule);
              } else {
                // ACTUAL: buka context menu untuk set/edit/hapus actual date
                _showActualContextMenu(context, schedule);
              }
            }
          : null,
      onSecondaryTap: (schedule != null && isClickable)
          ? () {
              if (isPlan) {
                _showPlanContextMenu(context, schedule);
              } else {
                _showActualContextMenu(context, schedule);
              }
            }
          : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.grey[400]!, width: 0.5),
        ),
        alignment: Alignment.center,
        child: schedule != null && schedule.tglSelesai != null
            ? Text(
                text,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : (schedule != null && isPlan)
                ? Text(
                    text,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : (schedule != null && !isPlan)
                    ? Icon(Icons.edit, size: 12, color: Colors.grey[600])
                    : SizedBox(),
      ),
    );
  }

  

  void _showEditScheduleModal(BuildContext context, MtSchedule schedule) {
    final editService = MaintenanceEditService(
      repository: _repository,
      context: context,
    );

    editService.showEditIntervalModal(
      schedule: schedule,
      selectedYear: _selectedYear,
      onSuccess: () {
        _loadSchedules();
      },
    );
  }

  /// Context menu untuk PLAN row - edit tanggal plan atau set actual
  void _showPlanContextMenu(BuildContext context, MtSchedule schedule) {
    final dialogService = MaintenanceDialogService(
      repository: _repository,
      context: context,
    );
    final dateService = MaintenanceDateService(
      repository: _repository,
      context: context,
    );

    dialogService.showPlanContextMenu(
      schedule: schedule,
      onTambahActual: () {
        dateService.pickAndSetActualDate(
          schedule: schedule,
          selectedYear: _selectedYear,
          onSuccess: () {
            _loadSchedules();
          },
        );
      },
      onUbahTanggal: () {
        dateService.pickAndEditPlanDate(
          schedule: schedule,
          selectedYear: _selectedYear,
          onSuccess: () {
            _loadSchedules();
          },
        );
      },
    );
  }

  /// Context menu untuk ACTUAL row - set/edit/hapus tanggal actual
  void _showActualContextMenu(BuildContext context, MtSchedule schedule) {
    final dialogService = MaintenanceDialogService(
      repository: _repository,
      context: context,
    );
    final dateService = MaintenanceDateService(
      repository: _repository,
      context: context,
    );

    dialogService.showActualContextMenu(
      schedule: schedule,
      onSetActual: () {
        dateService.pickAndSetActualDate(
          schedule: schedule,
          selectedYear: _selectedYear,
          onSuccess: () {
            _loadSchedules();
          },
        );
      },
      onDeleteActual: () async {
        final confirmed = await dialogService.showDeleteConfirmation(
          title: 'Konfirmasi Hapus',
          message: 'Hapus tanggal actual untuk ${schedule.assetName}?',
        );
        if (confirmed == true) {
          await dateService.deleteActualDate(
            schedule: schedule,
            onSuccess: () {
              _loadSchedules();
            },
          );
        }
      },
    );
  }
}
