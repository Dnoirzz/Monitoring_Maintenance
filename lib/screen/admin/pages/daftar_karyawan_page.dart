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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Daftar Karyawan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF022415),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Add your add employee logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Fitur Tambah Karyawan")),
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
                        "Nama Petugas",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Mesin yang Dikerjakan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Nomor Telepon",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Alamat Email",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Password",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows:
                      karyawan
                          .map(
                            (item) => DataRow(
                              cells: [
                                DataCell(Text(item["nama"]!)),
                                DataCell(Text(item["mesin"]!)),
                                DataCell(Text(item["telp"]!)),
                                DataCell(Text(item["email"]!)),
                                DataCell(Text(item["password"]!)),
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
