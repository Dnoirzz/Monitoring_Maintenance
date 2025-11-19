import 'package:flutter/material.dart';

class DaftarKaryawanPage extends StatefulWidget {
  const DaftarKaryawanPage({super.key});

  @override
  State<DaftarKaryawanPage> createState() => _DaftarKaryawanPageState();
}

class _DaftarKaryawanPageState extends State<DaftarKaryawanPage> {
  final List<Map<String, String>> _karyawan = [
    {
      "nama": "Ramadhan F",
      "mesin": "Creeper 1",
      "telp": "08123456789",
      "email": "ramadhan@example.com",
      "password": "******",
    },
    {
      "nama": "Adityo Saputro",
      "mesin": "Mixing Machine",
      "telp": "087812345678",
      "email": "adityo@example.com",
      "password": "******",
    },
    {
      "nama": "Rama Wijaya",
      "mesin": "Creeper 2",
      "telp": "085312345678",
      "email": "rama@example.com",
      "password": "******",
    },
  ];

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

        // Button Tambah
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: _buildDaftarKaryawanTable(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaftarKaryawanTable(BuildContext context) {
    final headerStyle = const TextStyle(fontWeight: FontWeight.bold);
    const double rowHeight = 65.0;

    // Lebar kolom
    const double colNo = 60.0;
    const double col1 = 180.0;
    const double col2 = 200.0;
    const double col3 = 150.0;
    const double col4 = 200.0;
    const double col5 = 120.0;
    const double col6 = 200.0; // Kolom AKSI

    List<Widget> dataRows = [];

    for (int i = 0; i < _karyawan.length; i++) {
      var item = _karyawan[i];
      dataRows.add(
        Row(
          children: [
            _cellCenter((i + 1).toString(), colNo, rowHeight, null),
            _cellCenter(item["nama"]!, col1, rowHeight, null),
            _cellCenter(item["mesin"]!, col2, rowHeight, null),
            _cellCenter(item["telp"]!, col3, rowHeight, null),
            _cellCenter(item["email"]!, col4, rowHeight, null),
            _cellCenter(item["password"]!, col5, rowHeight, null),
            _actionCell(context, item, col6, rowHeight),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        children: [
          // HEADER ROW
          Row(
            children: [
              _cellCenter("NO", colNo, rowHeight, headerStyle, isHeader: true),
              _cellCenter(
                "NAMA PETUGAS",
                col1,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "MESIN YANG DIKERJAKAN",
                col2,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "NOMOR TELEPON",
                col3,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "ALAMAT EMAIL",
                col4,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "PASSWORD",
                col5,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter("AKSI", col6, rowHeight, headerStyle, isHeader: true),
            ],
          ),
          // DATA ROWS
          ...dataRows,
        ],
      ),
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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (childContext, setStateDialog) {
              final double fieldWidth = _dialogFieldWidth(childContext);
              return ConstrainedBox(
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
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
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
                                items:
                                    mesinOptions
                                        .map(
                                          (mesin) => DropdownMenuItem(
                                            value: mesin,
                                            child: Text(mesin),
                                          ),
                                        )
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
                              onPressed:
                                  () => Navigator.of(dialogContext).pop(),
                              child: const Text("Batal"),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }
                                setState(() {
                                  _karyawan.add({
                                    "nama": namaController.text.trim(),
                                    "mesin": selectedMesin,
                                    "telp": telpController.text.trim(),
                                    "email": emailController.text.trim(),
                                    "password": passwordController.text.trim(),
                                  });
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

  Widget _actionCell(
    BuildContext context,
    Map<String, String> item,
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
        children: [
          // Tombol Edit
          _iconButton(
            icon: Icons.edit,
            color: Colors.blue,
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Edit: ${item["nama"]}")));
            },
          ),
          const SizedBox(width: 4),
          // Tombol Hapus
          _iconButton(
            icon: Icons.delete,
            color: Colors.red,
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Hapus: ${item["nama"]}")));
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
