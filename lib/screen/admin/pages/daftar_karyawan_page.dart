import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_maintenance/controller/karyawan_controller.dart';
import 'package:monitoring_maintenance/model/karyawan_model.dart';

class DaftarKaryawanPage extends StatefulWidget {
  final KaryawanController karyawanController;
  
  const DaftarKaryawanPage({super.key, required this.karyawanController});

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

  List<KaryawanModel> _getFilteredData() {
    return widget.karyawanController.filterKaryawan(
      mesin: _filterMesin,
      searchQuery: _searchQuery,
    );
  }

  List<String> _getMesinList() {
    return widget.karyawanController.getMesinList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Daftar Karyawan",
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
                        hintText: 'Cari karyawan...',
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
                    value: _filterMesin,
                    hint: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_list, color: Color(0xFF0A9C5D), size: 20),
                          SizedBox(width: 8),
                          Text('Filter Mesin'),
                        ],
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('Semua Mesin'),
                      ),
                      ..._getMesinList().map((mesin) {
                        return DropdownMenuItem<String>(
                          value: mesin,
                          child: Text(mesin),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterMesin = value;
                      });
                    },
                    underline: SizedBox(),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    icon: Icon(Icons.arrow_drop_down, color: Color(0xFF0A9C5D)),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showTambahKaryawanModal(context),
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
            if (_filterMesin != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text('Filter: $_filterMesin'),
                    onDeleted: () {
                      setState(() {
                        _filterMesin = null;
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
    const double col3 = 150.0;
    const double col6 = 150.0;

    // Kolom tetap
    const double fixedColumnsWidth = colNo + col3 + col6;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Hitung sisa lebar untuk 3 kolom yang akan di-expand
        final availableWidth = constraints.maxWidth - fixedColumnsWidth;
        final expandedColWidth = availableWidth > 0 ? availableWidth / 4 : 200.0;

        // Pastikan lebar minimum untuk kolom yang di-expand
        final col1 = expandedColWidth < 200 ? 200.0 : expandedColWidth;
        final col2 = expandedColWidth < 200 ? 200.0 : expandedColWidth;
        final col4 = expandedColWidth < 200 ? 200.0 : expandedColWidth;
        final col5 = expandedColWidth < 200 ? 200.0 : expandedColWidth;

        Widget headerRowContent = Row(
          children: [
            _headerCell("NO", colNo, rowHeight, headerStyle),
            _headerCell("NAMA PETUGAS", col1, rowHeight, headerStyle),
            _headerCell("MESIN YANG DIKERJAKAN", col2, rowHeight, headerStyle),
            _headerCell("NOMOR TELEPON", col3, rowHeight, headerStyle),
            _headerCell("ALAMAT EMAIL", col4, rowHeight, headerStyle),
            _headerCell("PASSWORD", col5, rowHeight, headerStyle),
            _headerCell("AKSI", col6, rowHeight, headerStyle),
          ],
        );

        Widget tableBody = Padding(
          padding: const EdgeInsets.only(bottom: horizontalScrollbarPadding),
          child: _buildTableBodyDynamic(context, col1, col2, col4, col5),
        );

        final totalTableWidth = colNo + col1 + col2 + col3 + col4 + col5 + col6;
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

    List<KaryawanModel> filteredData = _getFilteredData();

    if (widget.karyawanController.getAllKaryawan().isEmpty) {
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
              Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Tidak ada data karyawan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
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
                'Tidak ada data ditemukan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Coba ubah kata kunci pencarian atau filter',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
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
          ),
        ),
      );
    }

    List<Widget> dataRows = [];

    for (int i = 0; i < filteredData.length; i++) {
      KaryawanModel item = filteredData[i];
      bool isEvenRow = i % 2 == 0;
      String rowKey = "${item.nama}_$i";
      bool isHovered = _hoveredRowKey == rowKey;

      dataRows.add(
        MouseRegion(
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
                item.nama,
                col1,
                rowHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                item.mesin,
                col2,
                rowHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                item.telp,
                col3,
                rowHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                item.email,
                col4,
                rowHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),
              _cellCenter(
                item.password,
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

  void _showTambahKaryawanModal(BuildContext context) {
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

    final List<String> mesinOptions = [
      "Creeper 1",
      "Creeper 2",
      "Mixing Machine",
      "Generator Set",
      "Excavator",
    ];
    String selectedMesin = mesinOptions.first;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (childContext, setStateDialog) {
              final double fieldWidth = _dialogFieldWidth(childContext);
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
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
                                Icons.badge_rounded,
                                color: Color(0xFF0A9C5D),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Tambah Karyawan",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF022415),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Lengkapi informasi karyawan untuk akses dashboard",
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
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
                                  if (value.trim().split(' ').length < 2) {
                                    return "Masukkan nama lengkap";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: DropdownButtonFormField<String>(
                                value: selectedMesin,
                                decoration: _modalInputDecoration(
                                  label: "Mesin yang Dikerjakan",
                                  icon: Icons.precision_manufacturing_outlined,
                                ),
                                items: mesinOptions
                                    .map((mesin) => DropdownMenuItem(
                                          value: mesin,
                                          child: Text(mesin),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setStateDialog(() => selectedMesin = value);
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
                                obscureText: true,
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
                          ],
                        ),
                        const SizedBox(height: 28),
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
                                  widget.karyawanController.addKaryawan(
                                    KaryawanModel(
                                      nama: namaController.text.trim(),
                                      mesin: selectedMesin,
                                      telp: telpController.text.trim(),
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                    ),
                                  );
                                });
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Karyawan ${namaController.text.trim()} ditambahkan",
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A9C5D),
                                foregroundColor: Colors.white,
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
          ),
        );
      },
    ).whenComplete(() {
      for (final controller in controllers) {
        controller.dispose();
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
        style: style ?? TextStyle(fontSize: 12, color: Colors.grey[800]),
        textAlign: TextAlign.center,
        maxLines: null,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _actionCell(
    BuildContext context,
    KaryawanModel item,
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
            icon: Icons.edit,
            color: Color(0xFF2196F3),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Edit: ${item.nama}"),
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
              setState(() {
                widget.karyawanController.deleteKaryawan(item.nama);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Hapus: ${item.nama}")),
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
}