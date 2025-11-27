import 'package:flutter/material.dart';

class DetailHistoryLaporanPage extends StatefulWidget {
  const DetailHistoryLaporanPage({super.key});

  @override
  State<DetailHistoryLaporanPage> createState() =>
      _DetailHistoryLaporanPageState();
}

class _DetailHistoryLaporanPageState extends State<DetailHistoryLaporanPage> {
  final Color _backgroundLight = const Color(0xFFF6F8F7);

  // Static data for demonstration
  final Map<String, dynamic> _reportData = {
    'reportId': '#MCN-00123',
    'status': 'Selesai',
    'statusColor': Colors.green,
    'machineName': 'Mesin Press Hidrolik A',
    'date': '14 Agustus 2024',
    'reporter': 'Budi Santoso',
    'priority': 'Tinggi',
    'priorityColor': Colors.red,
    'description':
        'Mesin mengeluarkan suara bising yang tidak normal saat beroperasi pada tekanan tinggi. Terjadi kebocoran oli hidrolik minor di sekitar area piston utama.',
    'photos': [
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCdkSAfckXhL0Y5BUKAIqAKhtcJBLwG9MidQSopVoLM0zLzbLZ8Xs6kAuA3D25srhgNYPtgLBzxvb7ZFtvdxTgOq9lrVrjmYh745VtNQxY5_ynLF4oC2QTTLRJ_mRkcj9sCQzvffT1A9S6UcFEY4kYmgEoo7SG3mz6h_wHJBkVEc6VMS_1SHU6Pk7AjTgev7m65SFbZhw4bR3rS29xHk6fgz9GNZxbb9agxcU98_Q7DJgJFWJDQWBWJCjaiyb-AfpJNYyt9Nsa_HjTu',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCDwsFrPVIDwRj_R7gxHzs_JDGlFSn1Oywaasf6-u-SBf0Wq9oW9rIZ1EdoCWFFVsAgNwaEofgVfIBvEbbzfK4ZXVPXWVMdaROVxKA7k1b1Gl5eAyTBU9RfkOmmLWFVs62fUU8a4bJrsgzdFzhC-lmIq2jGYZlxVM9i96rnF9TVs9qN5R6MN79BElnj8d7zM3blZYHV39ZCnBvmzqlSJ2wzBlxdJJfDJakyKXhGqsu1cfZyRITyuPsskS-MI-5UA2gt_OlZhDN6sB2u',
    ],
    'actionTaken':
        'Penggantian seal piston utama dan pengencangan baut pada housing. Oli hidrolik telah diisi ulang sesuai standar.',
    'additionalNotes':
        'Perlu dilakukan pengecekan rutin pada level oli hidrolik untuk 1 minggu ke depan untuk memastikan tidak ada kebocoran lanjutan.',
    'completionDate': '15 Agustus 2024',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        backgroundColor: _backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Laporan',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildMachineDetails(),
            _buildDescription(),
            _buildPhotos(),
            _buildResolutionDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan ${_reportData['reportId']}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (_reportData['statusColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _reportData['status'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _reportData['statusColor'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Mesin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Nama Mesin', _reportData['machineName']),
          _buildDetailRow('Tanggal Laporan', _reportData['date']),
          _buildDetailRow('Pelapor', _reportData['reporter']),
          _buildDetailRow(
            'Prioritas',
            _reportData['priority'],
            valueColor: _reportData['priorityColor'],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Column(
      children: [
        Divider(height: 1, color: Colors.grey.shade300),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Deskripsi Kerusakan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _reportData['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Foto Bukti',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: (_reportData['photos'] as List).length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _reportData['photos'][index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Detail Penyelesaian',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildResolutionItem(
            'Tindakan yang Diambil',
            _reportData['actionTaken'],
          ),
          const SizedBox(height: 12),
          _buildResolutionItem(
            'Catatan Tambahan',
            _reportData['additionalNotes'],
          ),
          const SizedBox(height: 12),
          _buildResolutionItem(
            'Tanggal Penyelesaian',
            _reportData['completionDate'],
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
