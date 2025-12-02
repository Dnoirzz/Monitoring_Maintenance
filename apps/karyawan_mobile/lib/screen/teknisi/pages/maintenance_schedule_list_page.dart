import 'package:flutter/material.dart';
import 'package:shared/repositories/asset_supabase_repository.dart';
import 'maintenance_calendar_page.dart';

class MaintenanceScheduleListPage extends StatefulWidget {
  final String title;
  final String
  assetType; // 'production_machine', 'heavy_equipment', 'electrical'

  const MaintenanceScheduleListPage({
    super.key,
    required this.title,
    required this.assetType,
  });

  @override
  State<MaintenanceScheduleListPage> createState() =>
      _MaintenanceScheduleListPageState();
}

class _MaintenanceScheduleListPageState
    extends State<MaintenanceScheduleListPage> {
  final Color _primaryColor = const Color(0xFF0A9C5D);
  final Color _backgroundLight = const Color(0xFFF6F8F7);
  final AssetSupabaseRepository _assetRepository = AssetSupabaseRepository();

  List<Map<String, dynamic>> _allAssets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allAssets = await _assetRepository.getAllAssets();

      // Filter by asset type
      final jenisAsset = _getJenisAssetFromType(widget.assetType);
      final filteredByType =
          allAssets.where((asset) {
            final jenis = asset['jenis_assets'] as String?;
            return jenis != null &&
                jenis.toLowerCase().contains(jenisAsset.toLowerCase());
          }).toList();

      setState(() {
        _allAssets = filteredByType;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  String _getJenisAssetFromType(String type) {
    switch (type) {
      case 'production_machine':
        return 'Mesin Produksi';
      case 'heavy_equipment':
        return 'Alat Berat';
      case 'electrical':
        return 'Listrik';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0A9C5D)),
              )
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _allAssets.isEmpty
              ? const Center(child: Text('Tidak ada data asset'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allAssets.length,
                itemBuilder: (context, index) {
                  final asset = _allAssets[index];
                  return _buildMaintenanceItem(asset);
                },
              ),
    );
  }

  Widget _buildMaintenanceItem(Map<String, dynamic> asset) {
    // Dummy data for schedule since it's not in asset table yet
    final String date = '25 Okt 2024';
    final String lastMaintenanceDate =
        '20 Okt 2024'; // Changed from type to last maintenance date

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MaintenanceCalendarPage(
                      assetName: asset['nama_assets'] ?? 'Unknown Asset',
                      assetData: asset,
                    ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calendar_month, color: _primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset['nama_assets'] ?? 'Unknown Asset',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Terakhir MT: $lastMaintenanceDate',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'MT Selanjutnya: $date',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
