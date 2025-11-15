import 'package:flutter/material.dart';

class DaftarKaryawanPage extends StatelessWidget {
  final List<Map<String, String>> karyawan = [
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
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Fitur Tambah Karyawan")));
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

    for (int i = 0; i < karyawan.length; i++) {
      var item = karyawan[i];
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
