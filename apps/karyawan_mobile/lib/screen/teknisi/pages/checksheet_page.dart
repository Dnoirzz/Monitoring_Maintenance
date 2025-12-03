import 'package:flutter/material.dart';
import '../../../models/checksheet_models.dart';
import '../../../services/checksheet_service.dart';

class ChecksheetPage extends StatefulWidget {
  final String scheduleId;

  const ChecksheetPage({super.key, required this.scheduleId});

  @override
  State<ChecksheetPage> createState() => _ChecksheetPageState();
}

class _ChecksheetPageState extends State<ChecksheetPage> {
  final Color _primaryColor = const Color(0xFF0A9E5E);
  final TextEditingController _notesController = TextEditingController();

  ChecksheetScheduleDetail? _scheduleDetail;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadScheduleDetails();
  }

  Future<void> _loadScheduleDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final detail = await ChecksheetService.getScheduleDetails(
        widget.scheduleId,
      );

      setState(() {
        _scheduleDetail = detail;
        _notesController.text = detail.schedule.catatan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitChecksheet() async {
    // Validate all items have status
    final incompleteItems =
        _scheduleDetail!.templates
            .where((t) => t.status == null || t.status!.isEmpty)
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

    setState(() => _isSubmitting = true);

    try {
      await ChecksheetService.submitChecksheet(
        scheduleId: widget.scheduleId,
        results: _scheduleDetail!.templates,
        generalNotes: _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checksheet berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F7).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checksheet ${_scheduleDetail?.schedule.assetName ?? ""}',
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadScheduleDetails,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
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
      bottomNavigationBar: _isLoading || _error != null ? null : _buildFooter(),
    );
  }

  Widget _buildMachineInfo() {
    final schedule = _scheduleDetail!.schedule;
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
            _buildInfoRow('Mesin', schedule.assetName),
            const SizedBox(height: 12),
            _buildInfoRow('Kode Mesin', schedule.assetCode),
            const SizedBox(height: 12),
            _buildInfoRow('Tanggal', schedule.tglJadwal),
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
        ..._scheduleDetail!.templates.map((item) {
          return _buildChecklistItem(item);
        }),
      ],
    );
  }

  Widget _buildChecklistItem(ChecksheetTemplate item) {
    final hasIssue = item.status == 'repair' || item.status == 'replace';

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
                child: Text(
                  item.jenisPekerjaan,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_note_outlined),
                    color: hasIssue ? _primaryColor : Colors.grey,
                    onPressed: hasIssue ? () => _showNotesDialog(item) : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    color:
                        hasIssue && item.photo != null
                            ? _primaryColor
                            : Colors.grey,
                    onPressed: hasIssue ? () => _showPhotoDialog(item) : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.stdPrwtn,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
          if (hasIssue && (item.notes != null || item.photo != null)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.notes != null && item.notes!.isNotEmpty)
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
                            TextSpan(text: item.notes),
                          ],
                        ),
                      ),
                    ),
                  if (item.photo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        item.photo!,
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
    // TODO: Implement camera/gallery picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur foto akan segera hadir')),
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
          onPressed: _isSubmitting ? null : _submitChecksheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child:
              _isSubmitting
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text(
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
