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
  late List<List<String>> rows;

  @override
  void initState() {
    super.initState();
    rows = widget.data.map((e) => [...e]).toList();
  }

  void editRow(int index) {
    final controller = TextEditingController(text: rows[index][1]);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Ubah Komponen'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Komponen Digunakan'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  rows[index][1] = controller.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('SIMPAN'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 10),
      title: Text(widget.title, style: const TextStyle(fontSize: 16)),
      children: [
        Table(
          border: TableBorder.all(color: Colors.black54, width: 1),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(1),
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
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...List.generate(rows.length, (i) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(rows[i][0]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(rows[i][1]),
                  ),
                  IconButton(
                    onPressed: () => editRow(i),
                    icon: const Icon(Icons.edit, size: 20),
                  )
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
}
