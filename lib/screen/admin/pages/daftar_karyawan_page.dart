import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_maintenance/controller/karyawan_controller.dart';
import 'package:monitoring_maintenance/controller/dashboard_controller.dart';

class DaftarKaryawanPage extends StatefulWidget {
  final KaryawanController karyawanController;
  final DashboardController? dashboardController;
  final VoidCallback? onKaryawanChanged;
  
  const DaftarKaryawanPage({
    super.key, 
    required this.karyawanController,
    this.dashboardController,
    this.onKaryawanChanged,
  });

  @override
  State<DaftarKaryawanPage> createState() => _DaftarKaryawanPageState();
}

class _DaftarKaryawanPageState extends State<DaftarKaryawanPage> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isSyncing = false;
  String _searchQuery = '';
  String? _filterMesin;
  String? _hoveredRowKey;
  bool _isLoading = true; // Set true untuk menampilkan loading saat pertama kali
  List<String> _mesinList = [];
  // Jabatan options untuk Maintenance: Teknisi, Kasie, Admin Staff
  List<String> _jabatanList = ['Teknisi', 'Kasie Teknisi', 'Admin Staff'];

  List<Map<String, String>> _karyawan = [];

  @override
  void initState() {
    super.initState();
    _loadData();

    // Sinkron horizontal scroll header & body
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

    // Listener search
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      await widget.karyawanController.loadKaryawan();
      final mesinList = await widget.karyawanController.getMesinList();
      
      if (mounted) {
        setState(() {
          _karyawan = widget.karyawanController.getAllKaryawan();
          _mesinList = mesinList;
        });
      }
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
        setState(() => _isLoading = false);
      }
    }
  }

  /// Helper method untuk refresh dashboard setelah perubahan data karyawan
  Future<void> _refreshDashboard() async {
    if (widget.dashboardController != null) {
      try {
        // Refresh dashboard stats
        await widget.dashboardController!.getStats();
        // Panggil callback jika ada untuk refresh dashboard UI
        if (widget.onKaryawanChanged != null) {
          widget.onKaryawanChanged!();
        }
      } catch (e) {
        print('Error refreshing dashboard: $e');
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

  // Scroll header pakai scroll wheel untuk scroll vertikal body
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

  List<Map<String, String>> _getFilteredData() {
    List<Map<String, String>> filtered = _karyawan;

    // Filter berdasarkan mesin
    if (_filterMesin != null && _filterMesin!.isNotEmpty) {
      filtered = filtered.where((item) {
        return item["mesin"] == _filterMesin;
      }).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final nama = item["nama"]?.toLowerCase() ?? '';
        final mesin = item["mesin"]?.toLowerCase() ?? '';
        final telp = item["telp"]?.toLowerCase() ?? '';
        final email = item["email"]?.toLowerCase() ?? '';
        final jabatan = item["jabatan"]?.toLowerCase() ?? '';

        return nama.contains(_searchQuery) ||
            mesin.contains(_searchQuery) ||
            telp.contains(_searchQuery) ||
            email.contains(_searchQuery) ||
            jabatan.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  List<String> _getMesinList() {
    final mesinSet = <String>{};
    for (var item in _karyawan) {
      final mesin = item["mesin"];
      if (mesin != null) {
        mesinSet.add(mesin);
      }
    }
    final list = mesinSet.toList();
    list.sort();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Daftar Karyawan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF022415),
              ),
            ),
            // Tombol Refresh
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF0A9C5D)),
              tooltip: 'Refresh Data',
              onPressed: _loadData,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Search + Filter + Tambah
        Column(
          children: [
            Row(
              children: [
                // Search
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
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari karyawan...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF0A9C5D),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
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
                          borderSide: const BorderSide(
                            color: Color(0xFF0A9C5D),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Filter Mesin (perbaikan: support null dengan String?)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButton<String?>(
                    value: _filterMesin,
                    hint: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_list,
                              color: Color(0xFF0A9C5D), size: 20),
                          SizedBox(width: 8),
                          Text('Filter Mesin'),
                        ],
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Semua Mesin'),
                      ),
                      ..._getMesinList().map(
                        (mesin) => DropdownMenuItem<String?>(
                          value: mesin,
                          child: Text(mesin),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterMesin = value;
                      });
                    },
                    underline: const SizedBox(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color(0xFF0A9C5D)),
                  ),
                ),

                const SizedBox(width: 12),

                // Tombol Tambah
                ElevatedButton.icon(
                  onPressed: () => _showTambahKaryawanModal(context),
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah"),
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: const Color(0xFF0A9C5D),
                    iconColor: Colors.white,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),

            if (_filterMesin != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text('Mesin: $_filterMesin'),
                    onDeleted: () {
                      setState(() {
                        _filterMesin = null;
                      });
                    },
                    deleteIcon: const Icon(Icons.close, size: 18),
                    backgroundColor:
                        const Color(0xFF0A9C5D).withOpacity(0.1),
                    labelStyle: const TextStyle(color: Color(0xFF0A9C5D)),
                  ),
                ],
              ),
            ],
          ],
        ),

        const SizedBox(height: 20),

        // Tabel
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
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(
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

  Widget _buildTableWithStickyHeader(BuildContext context) {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      color: Colors.white,
    );
    const double rowHeight = 65.0;
    const double horizontalScrollbarThickness = 12.0;
    const double horizontalScrollbarPadding =
        horizontalScrollbarThickness + 8.0;

    const double colNo = 60.0;
    const double col3 = 150.0;
    const double col6 = 150.0;

    // Kolom fix (no, telp, aksi)
    const double fixedColumnsWidth = colNo + col3 + col6;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Sisa lebar untuk kolom nama, mesin, email, password
        final availableWidth = constraints.maxWidth - fixedColumnsWidth;
        final expandedColWidth = availableWidth > 0 ? availableWidth / 4 : 200.0;

        final col1 = expandedColWidth < 200 ? 200.0 : expandedColWidth;
        final col2 = expandedColWidth < 200 ? 200.0 : expandedColWidth;
        final col4 = expandedColWidth < 200 ? 200.0 : expandedColWidth;
        final col5 = expandedColWidth < 200 ? 200.0 : expandedColWidth;

        final headerRowContent = Row(
          children: [
            _headerCell("NO", colNo, rowHeight, headerStyle),
            _headerCell("NAMA PETUGAS", col1, rowHeight, headerStyle),
            _headerCell("JABATAN", col2, rowHeight, headerStyle),
            _headerCell("MESIN YANG DIKERJAKAN", col2, rowHeight, headerStyle),
            _headerCell("NOMOR TELEPON", col3, rowHeight, headerStyle),
            _headerCell("ALAMAT EMAIL", col4, rowHeight, headerStyle),
            _headerCell("PASSWORD", col5, rowHeight, headerStyle),
            _headerCell("AKSI", col6, rowHeight, headerStyle),
          ],
        );

        final tableBody = Padding(
          padding: const EdgeInsets.only(bottom: horizontalScrollbarPadding),
          child: _buildTableBodyDynamic(
            context,
            col1,
            col2,
            col4,
            col5,
          ),
        );

        final totalTableWidth =
            colNo + col1 + col2 + col2 + col2 + col3 + col4 + col5 + col6;
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
                  const SizedBox(height: rowHeight),
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
                              ? const AlwaysScrollableScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A9C5D), Color(0xFF088A52)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: _headerScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: needsScroll
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
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

  Widget _buildTableBodyDynamic(
    BuildContext context,
    double col1,
    double col2,
    double col4,
    double col5,
  ) {
    const double rowHeight = 65.0;
    const double colNo = 60.0;
    const double col3 = 150.0;
    const double col6 = 150.0;

    final filteredData = _getFilteredData();

    if (widget.karyawanController.getAllKaryawan().isEmpty) {
      final screenWidth = MediaQuery.of(context).size.width;
      return Container(
        width: screenWidth,
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Tidak ada data karyawan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mulai dengan menambahkan data karyawan baru',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (filteredData.isEmpty) {
      final screenWidth = MediaQuery.of(context).size.width;
      return Container(
        width: screenWidth,
        padding: const EdgeInsets.all(60),
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
              const SizedBox(height: 16),
              Text(
                'Tidak ada data ditemukan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coba ubah kata kunci pencarian atau filter',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear, color: Color(0xFF0A9C5D)),
                label: const Text(
                  "Bersihkan Pencarian",
                  style: TextStyle(color: Color(0xFF0A9C5D)),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor:
                      const Color(0xFF0A9C5D).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<Widget> dataRows = [];

    for (int i = 0; i < filteredData.length; i++) {
      final item = filteredData[i];
      final bool isEvenRow = i % 2 == 0;
      final rowKey = "${item['nama']}_$i";
      final bool isHovered = _hoveredRowKey == rowKey;

      dataRows.add(
        MouseRegion(
          onEnter: (_) {
            setState(() {
              _hoveredRowKey = rowKey;
            });
          },
          onExit: (_) {
            setState(() {
              _hoveredRowKey = null;
            });
          },
          child: Row(
            children: [
              _cellCenter(
                (i + 1).toString(),
                colNo,
                rowHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                item["nama"] ?? '-',
                col1,
                rowHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                item["jabatan"] ?? '-',
                col2,
                rowHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                item["mesin"] ?? '-',
                col2,
                rowHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                item["telp"] ?? '-',
                col3,
                rowHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                item["email"] ?? '-',
                col4,
                rowHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                item["password"] ?? '-',
                col5,
                rowHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _actionCell(
                context,
                item,
                col6,
                rowHeight,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(children: dataRows),
    );
  }

  // Modal Tambah Karyawan
  void _showTambahKaryawanModal(BuildContext context) {
    print('DEBUG: _showTambahKaryawanModal dipanggil'); // Debug log
    final formKey = GlobalKey<FormState>();
    final TextEditingController namaController = TextEditingController();
    final TextEditingController telpController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final List<TextEditingController> controllers = [
      namaController,
      telpController,
      emailController,
      passwordController,
    ];

    List<String> selectedAssetIds = []; // Multi-select: list of asset IDs
    String selectedJabatan = 'Teknisi'; // Default jabatan untuk form tambah

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        print('DEBUG: Dialog builder dipanggil'); // Debug log
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (childContext, setStateDialog) {
              final double fieldWidth = _dialogFieldWidth(childContext);
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 26,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A9C5D).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.badge_rounded,
                                color: Color(0xFF0A9C5D),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Tambah Karyawan",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF022415),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Lengkapi informasi karyawan untuk akses dashboard",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Fields
                        Wrap(
                          spacing: 16,
                          runSpacing: 18,
                          children: [
                            SizedBox(
                              width: fieldWidth,
                              child: _modalTextField(
                                controller: namaController,
                                label: "Nama Lengkap",
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Nama wajib diisi";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: DropdownButtonFormField<String>(
                                value: selectedJabatan,
                                decoration: _modalInputDecoration(
                                  label: "Jabatan",
                                  icon: Icons.badge,
                                ),
                                items: ['Teknisi', 'KASIE Teknisi'].map((jab) => 
                                  DropdownMenuItem<String>(
                                    value: jab,
                                    child: Text(jab),
                                  ),
                                ).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setStateDialog(() {
                                      selectedJabatan = value;
                                      // Reset selectedAssetIds jika jabatan berubah ke KASIE Teknisi
                                      if (value == 'KASIE Teknisi') {
                                        selectedAssetIds.clear();
                                      }
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Jabatan wajib dipilih";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Field pemilihan mesin hanya tampil untuk jabatan Teknisi
                            if (selectedJabatan == 'Teknisi')
                              SizedBox(
                                width: fieldWidth,
                                child: FutureBuilder<List<Map<String, dynamic>>>(
                                  future: widget.karyawanController.getAllAssets(),
                                  builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  
                                  final assets = snapshot.data ?? [];
                                  if (assets.isEmpty) {
                                    return Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('Tidak ada mesin tersedia'),
                                    );
                                  }

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ExpansionTile(
                                      title: Text(
                                        selectedAssetIds.isEmpty
                                            ? "Pilih Mesin yang Dikerjakan"
                                            : "${selectedAssetIds.length} mesin dipilih",
                                        style: TextStyle(
                                          color: selectedAssetIds.isEmpty
                                              ? Colors.grey[600]
                                              : Colors.black87,
                                        ),
                                      ),
                                      leading: Icon(
                                        Icons.precision_manufacturing_outlined,
                                        color: Color(0xFF0A9C5D),
                                      ),
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(maxHeight: 200),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: assets.map((asset) {
                                                final assetId = asset['id']?.toString() ?? '';
                                                final assetName = asset['nama_assets'] as String? ?? 'Unknown';
                                                final isSelected = selectedAssetIds.contains(assetId);
                                                
                                                return CheckboxListTile(
                                                  title: Text(assetName),
                                                  value: isSelected,
                                                  onChanged: (value) {
                                                    setStateDialog(() {
                                                      if (value == true) {
                                                        if (!selectedAssetIds.contains(assetId)) {
                                                          selectedAssetIds.add(assetId);
                                                        }
                                                      } else {
                                                        selectedAssetIds.remove(assetId);
                                                      }
                                                    });
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _modalTextField(
                                controller: telpController,
                                label: "Nomor Telepon",
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _modalTextField(
                                controller: emailController,
                                label: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Email wajib diisi";
                                  }
                                  final regex = RegExp(r'^.+@.+\..+$');
                                  if (!regex.hasMatch(value.trim())) {
                                    return "Format email tidak valid";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _modalTextField(
                                controller: passwordController,
                                label: "Password",
                                icon: Icons.lock_outline,
                                obscureText: false, // Password bisa ditampilkan
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Password wajib diisi";
                                  }
                                  if (value.length < 6) {
                                    return "Minimal 6 karakter";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Department otomatis: Maintenance (tidak ditampilkan di UI)
                          ],
                        ),

                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text("Batal"),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }
                                
                                // Validasi pemilihan mesin hanya untuk jabatan Teknisi
                                if (selectedJabatan == 'Teknisi' && selectedAssetIds.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Pilih minimal 1 mesin'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  // Auto-fill department untuk admin maintenance
                                  // Jika KASIE Teknisi, assetIds bisa kosong (bisa lihat semua mesin)
                                  await widget.karyawanController.createKaryawan(
                                    nama: namaController.text.trim(),
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                    telp: telpController.text.trim(),
                                    assetIds: selectedJabatan == 'KASIE Teknisi' ? [] : selectedAssetIds,
                                    department: 'Maintenance', // Otomatis Maintenance
                                    jabatan: selectedJabatan, // Dari dropdown
                                  );
                                  
                                  if (mounted) {
                                    // Tutup dialog terlebih dahulu
                                    Navigator.of(dialogContext).pop();
                                    
                                    // Tunggu dialog benar-benar tertutup
                                    await Future.delayed(Duration(milliseconds: 100));
                                    
                                    // Refresh data dan dashboard hanya jika widget masih mounted
                                    if (mounted) {
                                      await _loadData();
                                      
                                      // Refresh dashboard setelah menambah karyawan
                                      await _refreshDashboard();
                                      
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${selectedJabatan} ${namaController.text.trim()} berhasil ditambahkan ke Department Maintenance",
                                            ),
                                            backgroundColor: Color(0xFF0A9C5D),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal menambahkan: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A9C5D),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.save),
                              label: const Text("Simpan"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      for (final c in controllers) {
        c.dispose();
      }
    });
  }

  // Modal Edit Karyawan
  void _showEditKaryawanModal(BuildContext context, int index) async {
    final item = _karyawan[index];
    final karyawanId = item["id"] ?? '';

    // Load karyawan data dengan assets
    List<String> selectedAssetIds = [];
    try {
      final karyawanData = await widget.karyawanController.getKaryawanWithAssets(karyawanId);
      if (karyawanData != null) {
        selectedAssetIds = widget.karyawanController.getAssetIds(karyawanData);
      }
    } catch (e) {
      print('Error loading karyawan data: $e');
    }

    final formKey = GlobalKey<FormState>();
    final TextEditingController namaController =
        TextEditingController(text: item["nama"]);
    final TextEditingController telpController =
        TextEditingController(text: item["telp"]);
    final TextEditingController emailController =
        TextEditingController(text: item["email"]);
    final TextEditingController passwordController =
        TextEditingController(); // Password kosong untuk edit (opsional)

    final List<TextEditingController> controllers = [
      namaController,
      telpController,
      emailController,
      passwordController,
    ];

    // Normalisasi jabatan dari database ke format dropdown
    String jabatanFromDb = item["jabatan"] ?? 'Teknisi';
    String selectedJabatan = jabatanFromDb;
    // Normalisasi jika database menggunakan format yang berbeda
    if (jabatanFromDb == 'Kasie Teknisi' || jabatanFromDb == 'Kasie') {
      selectedJabatan = 'KASIE Teknisi';
    } else if (jabatanFromDb != 'Teknisi' && jabatanFromDb != 'KASIE Teknisi') {
      selectedJabatan = 'Teknisi'; // Default jika tidak dikenal
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (childContext, setStateDialog) {
              final double fieldWidth = _dialogFieldWidth(childContext);

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 26,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A9C5D).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Color(0xFF0A9C5D),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                "Edit Karyawan",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF022415),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Wrap(
                          spacing: 16,
                          runSpacing: 18,
                          children: [
                            SizedBox(
                              width: fieldWidth,
                              child: _modalTextField(
                                controller: namaController,
                                label: "Nama Lengkap",
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Nama wajib diisi";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: DropdownButtonFormField<String>(
                                value: selectedJabatan,
                                decoration: _modalInputDecoration(
                                  label: "Jabatan",
                                  icon: Icons.badge,
                                ),
                                items: ['Teknisi', 'KASIE Teknisi'].map((jab) => 
                                  DropdownMenuItem<String>(
                                    value: jab,
                                    child: Text(jab),
                                  ),
                                ).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setStateDialog(() {
                                      selectedJabatan = value;
                                      // Reset selectedAssetIds jika jabatan berubah ke KASIE Teknisi
                                      if (value == 'KASIE Teknisi') {
                                        selectedAssetIds.clear();
                                      }
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Jabatan wajib dipilih";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Field pemilihan mesin hanya tampil untuk jabatan Teknisi
                            if (selectedJabatan == 'Teknisi')
                              SizedBox(
                                width: fieldWidth,
                                child: FutureBuilder<List<Map<String, dynamic>>>(
                                  future: widget.karyawanController.getAllAssets(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    }
                                    
                                    final assets = snapshot.data ?? [];
                                    if (assets.isEmpty) {
                                      return Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('Tidak ada mesin tersedia'),
                                      );
                                    }

                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          selectedAssetIds.isEmpty
                                              ? "Pilih Mesin yang Dikerjakan"
                                              : "${selectedAssetIds.length} mesin dipilih",
                                          style: TextStyle(
                                            color: selectedAssetIds.isEmpty
                                                ? Colors.grey[600]
                                                : Colors.black87,
                                          ),
                                        ),
                                        leading: Icon(
                                          Icons.precision_manufacturing_outlined,
                                          color: Color(0xFF0A9C5D),
                                        ),
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(maxHeight: 200),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: assets.map((asset) {
                                                  final assetId = asset['id']?.toString() ?? '';
                                                  final assetName = asset['nama_assets'] as String? ?? 'Unknown';
                                                  final isSelected = selectedAssetIds.contains(assetId);
                                                  
                                                  return CheckboxListTile(
                                                    title: Text(assetName),
                                                    value: isSelected,
                                                    onChanged: (value) {
                                                      setStateDialog(() {
                                                        if (value == true) {
                                                          if (!selectedAssetIds.contains(assetId)) {
                                                            selectedAssetIds.add(assetId);
                                                          }
                                                        } else {
                                                          selectedAssetIds.remove(assetId);
                                                        }
                                                      });
                                                    },
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            SizedBox(
                              width: fieldWidth,
                              child: _modalTextField(
                                controller: telpController,
                                label: "Nomor Telepon",
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _modalTextField(
                                controller: emailController,
                                label: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Email wajib diisi";
                                  }
                                  final regex = RegExp(r'^.+@.+\..+$');
                                  if (!regex.hasMatch(value.trim())) {
                                    return "Format email tidak valid";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _modalTextField(
                                controller: passwordController,
                                label: "Password",
                                icon: Icons.lock_outline,
                                obscureText: false, // Password bisa ditampilkan
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text("Batal"),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }

                                // Validasi pemilihan mesin hanya untuk jabatan Teknisi
                                if (selectedJabatan == 'Teknisi' && selectedAssetIds.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Pilih minimal 1 mesin'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  // Jika KASIE Teknisi, assetIds bisa kosong (bisa lihat semua mesin)
                                  await widget.karyawanController.updateKaryawan(
                                    id: karyawanId,
                                    nama: namaController.text.trim(),
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim().isNotEmpty
                                        ? passwordController.text.trim()
                                        : null,
                                    telp: telpController.text.trim(),
                                    assetIds: selectedJabatan == 'KASIE Teknisi' ? [] : selectedAssetIds,
                                    department: 'Maintenance', // Otomatis Maintenance
                                    jabatan: selectedJabatan,
                                  );
                                  
                                  if (mounted) {
                                    // Tutup dialog terlebih dahulu
                                    Navigator.of(dialogContext).pop();
                                    
                                    // Tunggu dialog benar-benar tertutup
                                    await Future.delayed(Duration(milliseconds: 100));
                                    
                                    // Refresh data dan dashboard hanya jika widget masih mounted
                                    if (mounted) {
                                      await _loadData();
                                      
                                      // Refresh dashboard setelah update karyawan
                                      await _refreshDashboard();
                                      
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Karyawan berhasil diupdate'),
                                            backgroundColor: Color(0xFF0A9C5D),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal mengupdate: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A9C5D),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.save),
                              label: const Text("Simpan Perubahan"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      for (final c in controllers) {
        c.dispose();
      }
    });
  }

  double _dialogFieldWidth(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width;
    return maxWidth > 720 ? 240 : double.infinity;
  }

  Widget _modalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator ??
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
      fillColor: const Color(0xFFF7F9FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0A9C5D), width: 1.6),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
      backgroundColor = const Color(0xFF0A9C5D).withOpacity(0.1);
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
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: style ??
            TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
            ),
        textAlign: TextAlign.center,
        maxLines: null,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _actionCell(
    BuildContext context,
    Map<String, String> item,
    double width,
    double height, {
    bool isEvenRow = true,
    bool isHovered = false,
  }) {
    Color backgroundColor;
    if (isHovered) {
      backgroundColor = const Color(0xFF0A9C5D).withOpacity(0.1);
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
            icon: Icons.edit,
            color: const Color(0xFF2196F3),
            onPressed: () {
              final index = _karyawan.indexOf(item);
              if (index == -1) return;
              _showEditKaryawanModal(context, index);
            },
          ),
          const SizedBox(width: 8),
          _iconButton(
            icon: Icons.delete,
            color: const Color(0xFFF44336),
            onPressed: () async {
              final id = item["id"];
              final nama = item["nama"];
              
              if (id == null || id.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ID karyawan tidak ditemukan'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Konfirmasi delete
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Hapus Karyawan'),
                  content: Text('Yakin ingin menghapus $nama?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                if (!mounted) return;
                
                try {
                  await widget.karyawanController.deleteKaryawan(id);
                  
                  // Tunggu sedikit untuk memastikan operasi delete selesai
                  await Future.delayed(Duration(milliseconds: 100));
                  
                  if (mounted) {
                    await _loadData();
                    
                    // Refresh dashboard setelah menghapus karyawan
                    if (mounted) {
                      await _refreshDashboard();
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Karyawan $nama berhasil dihapus"),
                            backgroundColor: Color(0xFF0A9C5D),
                          ),
                        );
                      }
                    }
                  }
                } catch (e) {
                  if (mounted) {
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
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
