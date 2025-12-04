import 'package:flutter/material.dart';
import '../../../../models/checksheet_models.dart';
import '../../../../services/checksheet_service.dart';
import 'checksheet_history_page.dart';

/// Halaman untuk menampilkan daftar pekerjaan checksheet pada asset tertentu
/// Menampilkan informasi komponen, jenis pekerjaan, standar perawatan, alat/bahan,
/// interval checksheet, dan tanggal terakhir checksheet dilakukan
class AssetJobDetailPage extends StatefulWidget {
  final String assetId;
  final String assetName;
  final String? assetCode;

  const AssetJobDetailPage({
    super.key,
    required this.assetId,
    required this.assetName,
    this.assetCode,
  });

  @override
  State<AssetJobDetailPage> createState() => _AssetJobDetailPageState();
}

class _AssetJobDetailPageState extends State<AssetJobDetailPage> {
  final Color _primaryColor = const Color(0xFF0A9C5D);
  final Color _bgColor = const Color(0xFFF6F8F7);

  List<AssetJobDetail> _jobDetails = [];
  bool _isLoading = true;
  String? _error;

  // Get color for next schedule based on date
  Color _getNextScheduleColor(String? nextDate) {
    if (nextDate == null) return Colors.grey;

    try {
      final next = DateTime.parse(nextDate);
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      final nextOnly = DateTime(next.year, next.month, next.day);

      if (nextOnly.isBefore(todayOnly)) {
        return Colors.red; // Overdue
      } else if (nextOnly.isAtSameMomentAs(todayOnly)) {
        return Colors.orange; // Today
      } else {
        return Colors.blue; // Upcoming
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final jobs = await ChecksheetService.getAssetJobTemplates(widget.assetId);

      setState(() {
        _jobDetails = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.assetName,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.assetCode != null)
              Text(
                widget.assetCode!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadJobDetails,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadJobDetails,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_jobDetails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tidak ada pekerjaan checksheet',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'untuk asset ini',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobDetails,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jobDetails.length,
        itemBuilder: (context, index) {
          final job = _jobDetails[index];
          return _buildJobCard(job);
        },
      ),
    );
  }

  Widget _buildJobCard(AssetJobDetail job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to checksheet history
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChecksheetHistoryPage(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Component Name Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: _primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        job.componentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 16),

                // Job Type
                _buildInfoRow(
                  icon: Icons.build_outlined,
                  label: 'Jenis Pekerjaan',
                  value: job.jenisPekerjaan,
                ),
                const SizedBox(height: 12),

                // Maintenance Standard (Display Only)
                // Maintenance Standard
                _buildInfoRow(
                  icon: Icons.description_outlined,
                  label: 'Standar Perawatan',
                  value: job.stdPrwtn,
                  valueColor: Colors.black,
                ),
                const SizedBox(height: 12),

                // Tools/Materials
                _buildInfoRow(
                  icon: Icons.hardware_outlined,
                  label: 'Alat/Bahan',
                  value: job.alatBahan,
                ),
                const SizedBox(height: 12),

                // Interval
                _buildInfoRow(
                  icon: Icons.schedule,
                  label: 'Periode Checksheet',
                  value: job.getIntervalString(),
                  valueColor: _primaryColor,
                ),
                const SizedBox(height: 12),

                // Last Checksheet Date
                _buildInfoRow(
                  icon: Icons.history,
                  label: 'Terakhir Dilaksanakan',
                  value: job.lastChecksheetDate ?? 'Belum pernah dilakukan',
                  valueColor:
                      job.lastChecksheetDate != null
                          ? Colors.green
                          : Colors.orange,
                ),
                const SizedBox(height: 12),

                // Next Schedule Date
                _buildInfoRow(
                  icon: Icons.event_available,
                  label: 'Jadwal Selanjutnya',
                  value: job.nextScheduleDate ?? 'Belum terjadwal',
                  valueColor: _getNextScheduleColor(job.nextScheduleDate),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
