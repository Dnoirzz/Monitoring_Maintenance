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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Data Mesin",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF022415),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Add your add machine logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Fitur Tambah Data Mesin")),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Tambah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A9C5D),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

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
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Color(0xFF0A9C5D).withOpacity(0.1),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        "Nama Mesin",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Kode Mesin",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Tanggal Maintenance Terakhir",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Tanggal Maintenance Selanjutnya",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows:
                      mesinData
                          .map(
                            (item) => DataRow(
                              cells: [
                                DataCell(Text(item["nama"]!)),
                                DataCell(Text(item["kode"]!)),
                                DataCell(Text(item["maintenance_terakhir"]!)),
                                DataCell(
                                  Text(item["maintenance_selanjutnya"]!),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
