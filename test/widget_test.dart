import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: KomponenPage(),
  ));
}

class KomponenPage extends StatelessWidget {
  const KomponenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text('Nomor Aset:-', style: TextStyle(fontSize: 16)),
          SizedBox(height: 6),
          Text('Bagian Mesin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ItemPanel(
            title: 'Roll Atas',
            data: [
              ['Bearing', 'SKF 6203'],
              ['Shaft', 'Stainless Ø20'],
              ['Baut Penahan', 'M8 x 25'],
            ],
          ),
          SizedBox(height: 10),
          ItemPanel(
            title: 'Roll Bawah',
            data: [
              ['Bearing', 'SKF 6204'],
              ['Gear Box', 'Ratio 1:20'],
            ],
          ),
        ],
      ),
    );
  }
}

class ItemPanel extends StatefulWidget {
  final String title;
  final List<List<String>> data;

  const ItemPanel({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  State<ItemPanel> createState() => _ItemPanelState();
}

class _ItemPanelState extends State<ItemPanel> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 10),
      title: Text(widget.title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
      children: [
        Table(
          border: TableBorder.all(color: Colors.black54, width: 1),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Bagian Komponen', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Komponen Digunakan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...widget.data.map(
              (row) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(row[0]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(row[1]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
