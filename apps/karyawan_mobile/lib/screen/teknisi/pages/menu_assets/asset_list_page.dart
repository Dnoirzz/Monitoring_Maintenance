import 'package:flutter/material.dart';
import 'package:shared/repositories/asset_supabase_repository.dart';
import 'asset_detail_page.dart';

class AssetListPage extends StatefulWidget {
  final String title;
  final String assetType; // 'production_machine', 'heavy_equipment', 'electrical'

  const AssetListPage({
    super.key,
    required this.title,
    required this.assetType,
  });

  @override
  State<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  final Color _primaryColor = const Color(0xFF0A9C5D);
  final Color _backgroundLight = const Color(0xFFF6F8F7);
  final TextEditingController _searchController = TextEditingController();
  final AssetSupabaseRepository _assetRepository = AssetSupabaseRepository();
  
  List<Map<String, dynamic>> _allAssets = [];
  List<Map<String, dynamic>> _filteredAssets = [];
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
      final filteredByType = allAssets.where((asset) {
        final jenis = asset['jenis_assets'] as String?;
        return jenis != null && jenis.toLowerCase().contains(jenisAsset.toLowerCase());
      }).toList();

      setState(() {
        _allAssets = filteredByType;
        _filteredAssets = filteredByType;
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

  void _filterAssets(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAssets = _allAssets;
      } else {
        _filteredAssets = _allAssets.where((asset) {
          final name = (asset['nama_assets'] as String? ?? '').toLowerCase();
          final code = (asset['kode_assets'] as String? ?? '').toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || code.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        title: Text(
          widget.title,
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
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _filteredAssets.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredAssets.length,
                            itemBuilder: (context, index) {
                              return _buildAssetCard(_filteredAssets[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _filterAssets,
        decoration: InputDecoration(
          hintText: 'Cari nama atau kode asset...',
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    // Map Supabase field names to UI
    final String name = asset['nama_assets'] ?? 'Unknown Asset';
    final String code = asset['kode_assets'] ?? '-';
    final String status = asset['status'] ?? 'Aktif';
    final String? mtPriority = asset['mt_priority'];
    
    Color statusColor;
    Color statusBgColor;
    
    switch (status) {
      case 'Aktif':
      case 'Operational':
        statusColor = const Color(0xFF0A9C5D); // Green
        statusBgColor = const Color(0xFFE7F5EE);
        break;
      case 'Maintenance':
      case 'Dalam Perbaikan':
        statusColor = const Color(0xFFF59E0B); // Amber
        statusBgColor = const Color(0xFFFEF3C7);
        break;
      case 'Rusak':
      case 'Tidak Aktif':
        statusColor = const Color(0xFFEF4444); // Red
        statusBgColor = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.shade100;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssetDetailPage(
                assetId: asset['id'],
                assetData: asset,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconForType(widget.assetType),
                  color: _primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      code,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (mtPriority != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.priority_high, size: 14, color: _getPriorityColor(mtPriority)),
                          const SizedBox(width: 4),
                          Text(
                            'Priority: $mtPriority',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getPriorityColor(mtPriority),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        return Colors.grey;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'production_machine':
        return Icons.factory;
      case 'heavy_equipment':
        return Icons.construction;
      case 'electrical':
        return Icons.electric_bolt;
      default:
        return Icons.precision_manufacturing;
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryColor),
          const SizedBox(height: 16),
          Text(
            'Memuat data asset...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAssets,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Asset tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
