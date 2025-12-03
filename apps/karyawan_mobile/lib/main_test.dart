import 'package:flutter/material.dart';
import 'models/checksheet_models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Checksheet',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0A9E5E),
        scaffoldBackgroundColor: const Color(0xFFF6F7F8),
        fontFamily: 'Manrope',
      ),
      themeMode: ThemeMode.light,
      home: const DummyChecksheetPage(),
    );
  }
}

class DummyChecksheetPage extends StatefulWidget {
  const DummyChecksheetPage({super.key});

  @override
  State<DummyChecksheetPage> createState() => _DummyChecksheetPageState();
}

class _DummyChecksheetPageState extends State<DummyChecksheetPage> {
  final Color _primaryColor = const Color(0xFF0A9E5E);
  final TextEditingController _notesController = TextEditingController();

  // DATA DUMMY
  final String _machineName = 'Mesin CNC-01';
  final String _machineCode = 'CNC-001';
  final String _scheduleDate = '2025-12-03';

  final List<ChecksheetTemplate> _checklistItems = [
    ChecksheetTemplate(
      id: '1',
      jenisPekerjaan: 'Pemeriksaan Level Oli Hidrolik',
      stdPrwtn:
          'Level oli harus berada di antara garis MIN dan MAX pada sight glass',
      alatBahan: 'Lap bersih, Catatan level',
      status: null,
      notes: null,
      photo: null,
    ),
    ChecksheetTemplate(
      id: '2',
      jenisPekerjaan: 'Pengecekan Suhu Bearing Spindle',
      stdPrwtn: 'Suhu bearing tidak boleh melebihi 60°C saat operasi normal',
      alatBahan: 'Thermometer infrared, Catatan suhu',
      status: null,
      notes: null,
      photo: null,
    ),
    ChecksheetTemplate(
      id: '3',
      jenisPekerjaan: 'Pemeriksaan Kebersihan Chip Conveyor',
      stdPrwtn: 'Chip conveyor harus bersih dari serpihan logam berlebih',
      alatBahan: 'Sapu, Lap, Vacuum cleaner',
      status: null,
      notes: null,
      photo: null,
    ),
    ChecksheetTemplate(
      id: '4',
      jenisPekerjaan: 'Pengecekan Tekanan Udara Kompresor',
      stdPrwtn: 'Tekanan udara harus 6-8 bar',
      alatBahan: 'Pressure gauge',
      status: null,
      notes: null,
      photo: null,
    ),
    ChecksheetTemplate(
      id: '5',
      jenisPekerjaan: 'Pemeriksaan Kondisi Coolant',
      stdPrwtn: 'Coolant harus bersih, tidak berbau, dan level mencukupi',
      alatBahan: 'Refractometer, pH meter, Catatan kualitas',
      status: null,
      notes: null,
      photo: null,
    ),
    ChecksheetTemplate(
      id: '6',
      jenisPekerjaan: 'Pengecekan Getaran Abnormal',
      stdPrwtn: 'Tidak ada getaran yang tidak normal saat mesin beroperasi',
      alatBahan: 'Vibration meter (opsional)',
      status: null,
      notes: null,
      photo: null,
    ),
    ChecksheetTemplate(
      id: '7',
      jenisPekerjaan: 'Pemeriksaan Kondisi Kabel dan Koneksi',
      stdPrwtn:
          'Semua kabel dan koneksi listrik dalam kondisi baik, tidak ada yang terkelupas',
      alatBahan: 'Visual inspection',
      status: null,
      notes: null,
      photo: null,
    ),
  ];

  void _submitChecksheet() {
    final incompleteItems =
        _checklistItems
            .where((item) => item.status == null || item.status!.isEmpty)
            .toList();

    if (incompleteItems.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua pemeriksaan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Checksheet Berhasil Dikirim!'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mesin: $_machineName'),
                  Text('Tanggal: $_scheduleDate'),
                  const SizedBox(height: 16),
                  const Text(
                    'Hasil Pemeriksaan:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ..._checklistItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            item.status == 'good'
                                ? Icons.check_circle
                                : item.status == 'repair'
                                ? Icons.build
                                : Icons.warning,
                            size: 16,
                            color:
                                item.status == 'good'
                                    ? Colors.green
                                    : item.status == 'repair'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.jenisPekerjaan}: ${item.status?.toUpperCase()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_notesController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Catatan: ${_notesController.text}'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    for (var item in _checklistItems) {
                      item.status = null;
                      item.notes = null;
                      item.photo = null;
                    }
                    _notesController.clear();
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F7).withOpacity(0.8),
        elevation: 0,
        title: Text(
          'Checksheet $_machineName',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMachineInfo(),
            const SizedBox(height: 16),
            _buildChecklistSection(),
            _buildGeneralNotes(),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  Widget _buildMachineInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            _buildInfoRow('Mesin', _machineName),
            const SizedBox(height: 12),
            _buildInfoRow('Kode Mesin', _machineCode),
            const SizedBox(height: 12),
            _buildInfoRow('Tanggal', _scheduleDate),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Daftar Pemeriksaan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...List.generate(_checklistItems.length, (index) {
          return _buildChecklistItem(_checklistItems[index], index + 1);
        }),
      ],
    );
  }

  Widget _buildChecklistItem(ChecksheetTemplate item, int number) {
    final hasIssue = item.status == 'repair' || item.status == 'replace';
    final hasNoteOrPhoto =
        (item.notes != null && item.notes!.isNotEmpty) || item.photo != null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$number',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.jenisPekerjaan,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      item.notes != null && item.notes!.isNotEmpty
                          ? Icons.edit_note
                          : Icons.edit_note_outlined,
                    ),
                    color:
                        item.notes != null && item.notes!.isNotEmpty
                            ? _primaryColor
                            : Colors.grey.shade600,
                    onPressed: () => _showNotesDialog(item),
                  ),
                  IconButton(
                    icon: Icon(
                      item.photo != null
                          ? Icons.camera_alt
                          : Icons.camera_alt_outlined,
                    ),
                    color:
                        item.photo != null
                            ? _primaryColor
                            : Colors.grey.shade600,
                    onPressed: () => _showPhotoDialog(item),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.stdPrwtn,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.build_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.alatBahan,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              _buildRadioButton('Good', 'good', item),
              _buildRadioButton('Repair', 'repair', item, isWarning: true),
              _buildRadioButton('Replace', 'replace', item, isError: true),
            ],
          ),
          if (hasNoteOrPhoto) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasIssue ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      hasIssue ? Colors.orange.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.notes != null && item.notes!.isNotEmpty)
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Catatan: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: item.notes),
                        ],
                      ),
                    ),
                  if (item.photo != null) ...[
                    if (item.notes != null && item.notes!.isNotEmpty)
                      const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Foto tersimpan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRadioButton(
    String label,
    String value,
    ChecksheetTemplate item, {
    bool isError = false,
    bool isWarning = false,
  }) {
    final isSelected = value == item.status;
    Color color = _primaryColor;
    if (isError) color = Colors.red;
    if (isWarning) color = Colors.orange;

    return GestureDetector(
      onTap: () {
        setState(() {
          item.status = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child:
                isSelected
                    ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color:
                  isSelected
                      ? (isError
                          ? Colors.red
                          : isWarning
                          ? Colors.orange
                          : Colors.black87)
                      : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(ChecksheetTemplate item) {
    final controller = TextEditingController(text: item.notes ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tambah Catatan'),
            content: TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Masukkan catatan...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    item.notes = controller.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _showPhotoDialog(ChecksheetTemplate item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tambah Foto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Ambil Foto'),
                  onTap: () {
                    setState(() {
                      item.photo = 'camera_photo_${item.id}.jpg';
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto berhasil disimpan (simulasi)'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    setState(() {
                      item.photo = 'gallery_photo_${item.id}.jpg';
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto berhasil dipilih (simulasi)'),
                      ),
                    );
                  },
                ),
                if (item.photo != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Hapus Foto'),
                    onTap: () {
                      setState(() {
                        item.photo = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildGeneralNotes() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan Umum',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan keseluruhan jika ada...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7).withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitChecksheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Kirim Laporan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
