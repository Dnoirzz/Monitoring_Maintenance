import 'package:flutter/material.dart';

class DataMesinPage extends StatelessWidget {
  final List<Map<String, String>> mesinData = [
    {
      "nama": "Creeper 1",
      "kode": "CRP-001",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
    },
    {
      "nama": "Creeper 2",
      "kode": "CRP-002",
      "maintenance_terakhir": "10 Januari 2024",
      "maintenance_selanjutnya": "10 Februari 2024",
    },
    {
      "nama": "Mixing Machine",
      "kode": "MIX-001",
      "maintenance_terakhir": "5 Januari 2024",
      "maintenance_selanjutnya": "5 Februari 2024",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Data Mesin",
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
            ).showSnackBar(SnackBar(content: Text("Fitur Tambah Data Mesin")));
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
                child: _buildDataMesinTable(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataMesinTable(BuildContext context) {
    final headerStyle = const TextStyle(fontWeight: FontWeight.bold);
    const double rowHeight = 65.0;

    // Lebar kolom
    const double colNo = 60.0;
    const double col1 = 180.0;
    const double col2 = 150.0;
    const double col3 = 200.0;
    const double col4 = 200.0;
    const double col5 = 200.0; // Kolom AKSI

    List<Widget> dataRows = [];

    for (int i = 0; i < mesinData.length; i++) {
      var item = mesinData[i];
      dataRows.add(
        Row(
          children: [
            _cellCenter((i + 1).toString(), colNo, rowHeight, null),
            _cellCenter(item["nama"]!, col1, rowHeight, null),
            _cellCenter(item["kode"]!, col2, rowHeight, null),
            _cellCenter(item["maintenance_terakhir"]!, col3, rowHeight, null),
            _cellCenter(
              item["maintenance_selanjutnya"]!,
              col4,
              rowHeight,
              null,
            ),
            _actionCell(context, item, col5, rowHeight),
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
                "NAMA MESIN",
                col1,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "KODE MESIN",
                col2,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "MAINTENANCE TERAKHIR",
                col3,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter(
                "MAINTENANCE SELANJUTNYA",
                col4,
                rowHeight,
                headerStyle,
                isHeader: true,
              ),
              _cellCenter("AKSI", col5, rowHeight, headerStyle, isHeader: true),
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
