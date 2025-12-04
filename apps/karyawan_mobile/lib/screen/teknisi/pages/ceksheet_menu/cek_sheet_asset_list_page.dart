import 'package:flutter/material.dart';
import 'package:shared/repositories/asset_supabase_repository.dart';
import 'asset_job_detail_page.dart';

/// Halaman untuk menampilkan daftar asset berdasarkan jenis
/// Untuk keperluan checksheet
class CekSheetAssetListPage extends StatefulWidget {
  final String title;
  final String assetType;

  const CekSheetAssetListPage({
    super.key,
    required this.title,
    required this.assetType,
  });

  @override
  State<CekSheetAssetListPage> createState() => _CekSheetAssetListPageState();
}

class _CekSheetAssetListPageState extends State<CekSheetAssetListPage> {
  final Color _primaryColor = const Color(0xFF0A9C5D);
  final Color _bgColor = const Color(0xFFF6F8F7);
  final AssetSupabaseRepository _assetRepository = AssetSupabaseRepository();

  List<Map<String, dynamic>> _assets = [];
  List<Map<String, dynamic>> _filteredAssets = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _searchController.addListener(_filterAssets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final allAssets = await _assetRepository.getAllAssets();

      // Filter by asset type
      final filtered =
          allAssets.where((asset) {
            final jenisAssets = asset['jenis_assets']?.toString().toLowerCase();
            switch (widget.assetType) {
              case 'production_machine':
                return jenisAssets == 'mesin produksi';
              case 'heavy_equipment':
                return jenisAssets == 'alat berat';
              case 'electrical':
                return jenisAssets == 'listrik';
              default:
                return true;
            }
          }).toList();

      setState(() {
        _assets = filtered;
        _filteredAssets = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  void _filterAssets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredAssets = _assets;
      } else {
        _filteredAssets =
            _assets.where((asset) {
              final name = asset['nama_assets']?.toString().toLowerCase() ?? '';
              final code = asset['kode_assets']?.toString().toLowerCase() ?? '';
              return name.contains(query) || code.contains(query);
            }).toList();
      }
    });
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
        title: Text(
          'Cek Sheet - ${widget.title}',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadAssets,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari asset...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: _bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Asset List
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAssets,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                    : _filteredAssets.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Tidak ada asset'
                                : 'Asset tidak ditemukan',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadAssets,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAssets.length,
                        itemBuilder: (context, index) {
                          final asset = _filteredAssets[index];
                          return _buildAssetCard(asset);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    final name = asset['nama_assets'] ?? 'Unknown';
    final code = asset['kode_assets'] ?? '-';
    final status = asset['status'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            // Navigate to asset job detail page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AssetJobDetailPage(
                      assetId: asset['id'],
                      assetName: name,
                      assetCode: code,
                    ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment_outlined,
                    color: _primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Asset Info
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
                        'Kode: $code',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              status == 'Aktif'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                status == 'Aktif' ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
