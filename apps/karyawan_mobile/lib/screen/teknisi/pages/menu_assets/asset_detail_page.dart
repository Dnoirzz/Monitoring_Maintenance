import 'package:flutter/material.dart';
import 'package:shared/repositories/asset_supabase_repository.dart';
import '../mt_request.dart';

class AssetDetailPage extends StatefulWidget {
  final String assetId;
  final Map<String, dynamic> assetData;

  const AssetDetailPage({
    super.key,
    required this.assetId,
    required this.assetData,
  });

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  final AssetSupabaseRepository _assetRepository = AssetSupabaseRepository();
  Map<String, dynamic>? _detailedAssetData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssetDetails();
  }

  Future<void> _loadAssetDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get all assets with nested data
      final allAssets = await _assetRepository.getAllAssets();

      // Find the specific asset by ID
      final assetDetail = allAssets.firstWhere(
        (asset) => asset['id'] == widget.assetId,
        orElse: () => widget.assetData,
      );

      setState(() {
        _detailedAssetData = assetDetail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat detail: $e';
        _detailedAssetData = widget.assetData; // Fallback to basic data
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF0A9C5D);
    final bgColor = const Color(0xFFF6F8F7);

    // Use detailed data if available, otherwise use basic data
    final displayData = _detailedAssetData ?? widget.assetData;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Asset',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    const SizedBox(height: 16),
                    const Text('Memuat detail asset...'),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey.shade200,
                      child:
                          displayData['foto'] != null
                              ? Image.network(
                                displayData['foto'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  );
                                },
                              )
                              : Icon(
                                Icons.precision_manufacturing,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                    ),

                    // Main Info Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayData['nama_assets'] ??
                                          'Unknown Asset',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      displayData['kode_assets'] ?? '-',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildStatusBadge(displayData['status']),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Key Details Grid
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  'Jenis Asset',
                                  displayData['jenis_assets'] ?? '-',
                                  Icons.category,
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  'Prioritas MT',
                                  displayData['mt_priority'] ?? '-',
                                  Icons.priority_high,
                                  valueColor: _getPriorityColor(
                                    displayData['mt_priority'],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  'Terakhir MT',
                                  '-', // TODO: Field ini belum ada di database
                                  Icons.history,
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  'MT Selanjutnya',
                                  '-', // TODO: Field ini belum ada di database
                                  Icons.calendar_month,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Components / Parts Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Komponen & Bagian Mesin',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildComponentList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        FormLaporanKerusakanPage(initialAsset: displayData),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Buat Laporan Kerusakan',
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

  Widget _buildStatusBadge(String? status) {
    Color color;
    Color bgColor;

    switch (status) {
      case 'Aktif':
      case 'Operational':
        color = const Color(0xFF0A9C5D);
        bgColor = const Color(0xFFE7F5EE);
        break;
      case 'Maintenance':
      case 'Dalam Perbaikan':
        color = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFFEF3C7);
        break;
      case 'Rusak':
      case 'Tidak Aktif':
        color = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEE2E2);
        break;
      default:
        color = Colors.grey;
        bgColor = Colors.grey.shade100;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ?? 'Unknown',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.black87;
    }
  }

  Widget _buildComponentList() {
    // Get bg_mesin data from Supabase response
    final bgMesinList =
        (_detailedAssetData?['bg_mesin'] ?? []) as List<dynamic>;

    if (bgMesinList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Belum ada data komponen',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }

    // Flatten the structure: for each bg_mesin, get its komponen_assets
    final List<Map<String, dynamic>> componentsList = [];

    for (var bgMesin in bgMesinList) {
      final bgMesinData = bgMesin as Map<String, dynamic>;
      final komponenAssets =
          (bgMesinData['komponen_assets'] ?? []) as List<dynamic>;

      for (var komponen in komponenAssets) {
        final komponenData = komponen as Map<String, dynamic>;
        componentsList.add({
          'bagian': bgMesinData['nama_bagian'] ?? '-',
          'komponen':
              komponenData['nama_bagian'] ??
              '-', // komponen name stored in nama_bagian field
          'spesifikasi': komponenData['spesifikasi'] ?? '-',
        });
      }
    }

    if (componentsList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Belum ada data komponen',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: componentsList.length,
      itemBuilder: (context, index) {
        final item = componentsList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings_input_component,
                color: Colors.blue,
                size: 20,
              ),
            ),
            title: Text(
              item['komponen']!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  'Bagian: ${item['bagian']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Spec: ${item['spesifikasi']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
