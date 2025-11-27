import 'package:flutter/material.dart';

class CekHarianPage extends StatefulWidget {
  const CekHarianPage({super.key});

  @override
  State<CekHarianPage> createState() => _CekHarianPageState();
}

class _CekHarianPageState extends State<CekHarianPage> {
  // Static data for demonstration
  final Color _primaryColor = const Color(0xFF0A9E5E);

  // Form state (mocking static initial values)
  String _oliLevel = 'ok';
  String _vbeltCondition = 'bermasalah';
  String _hidrolikPressure = 'ok';
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7), // background-light
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F7).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Checklist Harian Mesin Press A',
          style: TextStyle(
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
        padding: const EdgeInsets.only(bottom: 100), // Space for footer
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
            _buildInfoRow('Nama Mesin', 'Mesin Press A'),
            const SizedBox(height: 12),
            _buildInfoRow('Kode Mesin', 'MP-001'),
            const SizedBox(height: 12),
            _buildInfoRow('Tanggal', '24 Oktober 2023'),
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
        _buildChecklistItem(
          title: 'Pengecekan Level Oli',
          description: 'Pastikan level oli berada di antara batas min-max.',
          groupValue: _oliLevel,
          onChanged: (val) => setState(() => _oliLevel = val!),
        ),
        _buildChecklistItem(
          title: 'Kondisi V-Belt',
          description: 'Periksa adanya retakan atau keausan pada V-Belt.',
          groupValue: _vbeltCondition,
          onChanged: (val) => setState(() => _vbeltCondition = val!),
          hasIssue: true, // Example of issue state
          issueNote: 'V-Belt terlihat retak, perlu penggantian segera.',
          issueImageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDKaLva8VnOJDAQ0MFPhVYl8o00UmvAGxF2qHRazNeB7m12jRWZpzrEE2QyHX8MvWHasIbZfd6fBq-Mw1cuhHq3IYVxAifemzGpa_ccUlFtXo4c5B74-MC7s7ruGbtOCVCkGETUg5xCroD-zxIzrIGvh4FXEM6rW4w2ig1NV5-XDxqPYM-s-abC--F5vEXLt-EiX4A4M85gMH_hKYeCDxiIDMg73heZg2nK78uVP5l9W1Y-qOo4JgT3Ye3dVXD826RGcDXG3WZLy7lV',
        ),
        _buildChecklistItem(
          title: 'Tekanan Hidrolik',
          description: 'Pastikan tekanan hidrolik sesuai standar operasi.',
          groupValue: _hidrolikPressure,
          onChanged: (val) => setState(() => _hidrolikPressure = val!),
        ),
      ],
    );
  }

  Widget _buildChecklistItem({
    required String title,
    required String description,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    bool hasIssue = false,
    String? issueNote,
    String? issueImageUrl,
  }) {
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_note_outlined),
                    color: Colors.grey,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    color: hasIssue ? Colors.red : Colors.grey,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildRadioButton('OK', 'ok', groupValue, onChanged),
              const SizedBox(width: 24),
              _buildRadioButton(
                'Tidak OK',
                'bermasalah',
                groupValue,
                onChanged,
                isError: true,
              ),
            ],
          ),
          if (hasIssue && (issueNote != null || issueImageUrl != null)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (issueNote != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: RichText(
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
                            TextSpan(text: issueNote),
                          ],
                        ),
                      ),
                    ),
                  if (issueImageUrl != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            issueImageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
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
    String groupValue,
    ValueChanged<String?> onChanged, {
    bool isError = false,
  }) {
    final isSelected = value == groupValue;
    final color = isError ? Colors.red : _primaryColor;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
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
              color: isSelected && isError ? Colors.red : Colors.black87,
              fontWeight:
                  isSelected && isError ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
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
          onPressed: () {
            // Handle submit
          },
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
}
