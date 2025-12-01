import 'package:flutter/material.dart';
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
  
  // Mock data - in a real app this would come from a provider/API based on widget.assetType
  late List<Map<String, dynamic>> _allAssets;
  List<Map<String, dynamic>> _filteredAssets = [];

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _filteredAssets = _allAssets;
  }

  void _initializeMockData() {
    // Generate different data based on assetType
    if (widget.assetType == 'production_machine') {
      _allAssets = [
        {
          'id': '1',
          'name': 'Mesin CNC Milling',
          'code': 'CNC-001',
          'location': 'Gedung A, Lantai 1',
          'status': 'Operational',
          'last_maintenance': '2024-10-20',
          'type': 'Mesin Produksi',
          'mt_priority': 'High',
          'foto': 'https://images.unsplash.com/photo-1565439398532-39c2e0078d4d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'next_maintenance': '2024-11-20',
        },
        {
          'id': '2',
          'name': 'Mesin Bubut Manual',
          'code': 'LATHE-002',
          'location': 'Gedung A, Lantai 1',
          'status': 'Maintenance',
          'last_maintenance': '2024-10-25',
          'type': 'Mesin Produksi',
          'mt_priority': 'Medium',
          'foto': 'https://images.unsplash.com/photo-1612630553424-42cdd445037d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'next_maintenance': '2024-11-25',
        },
        {
          'id': '3',
          'name': 'Mesin Injection Molding',
          'code': 'INJ-003',
          'location': 'Gedung B, Lantai 1',
          'status': 'Rusak',
          'last_maintenance': '2024-09-15',
          'type': 'Mesin Produksi',
          'mt_priority': 'High',
          'foto': null,
          'next_maintenance': '2024-11-15',
        },
        {
          'id': '4',
          'name': 'Mesin Press Hidrolik',
          'code': 'PRS-004',
          'location': 'Gedung B, Lantai 1',
          'status': 'Operational',
          'last_maintenance': '2024-10-28',
          'type': 'Mesin Produksi',
          'mt_priority': 'Low',
          'foto': null,
          'next_maintenance': '2024-11-28',
        },
      ];
    } else if (widget.assetType == 'heavy_equipment') {
      _allAssets = [
        {
          'id': '5',
          'name': 'Forklift Toyota 3T',
          'code': 'FL-001',
          'location': 'Warehouse',
          'status': 'Operational',
          'last_maintenance': '2024-10-10',
          'type': 'Alat Berat',
          'mt_priority': 'Medium',
          'foto': 'https://images.unsplash.com/photo-1586015555751-63bb77f4322a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'next_maintenance': '2024-11-10',
        },
        {
          'id': '6',
          'name': 'Excavator Mini',
          'code': 'EXC-002',
          'location': 'Area Luar',
          'status': 'Maintenance',
          'last_maintenance': '2024-10-22',
          'type': 'Alat Berat',
          'mt_priority': 'High',
          'foto': 'https://images.unsplash.com/photo-1579623879203-5df5955684ee?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          'next_maintenance': '2024-11-22',
        },
      ];
    } else {
      // Electrical
      _allAssets = [
        {
          'id': '7',
          'name': 'Panel Distribusi Utama',
          'code': 'PNL-001',
          'location': 'Ruang Panel',
          'status': 'Operational',
          'last_maintenance': '2024-10-01',
          'type': 'Listrik',
          'mt_priority': 'High',
          'foto': null,
          'next_maintenance': '2024-11-01',
        },
        {
          'id': '8',
          'name': 'Genset 500kVA',
          'code': 'GEN-001',
          'location': 'Power House',
          'status': 'Operational',
          'last_maintenance': '2024-09-30',
          'type': 'Listrik',
          'mt_priority': 'High',
          'foto': null,
          'next_maintenance': '2024-10-30',
        },
        {
          'id': '9',
          'name': 'Trafo Step Down',
          'code': 'TRF-001',
          'location': 'Substation',
          'status': 'Rusak',
          'last_maintenance': '2024-10-15',
          'type': 'Listrik',
          'mt_priority': 'High',
          'foto': null,
          'next_maintenance': '2024-11-15',
        },
      ];
    }
  }

  void _filterAssets(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAssets = _allAssets;
      } else {
        _filteredAssets = _allAssets.where((asset) {
          return asset['name'].toLowerCase().contains(query.toLowerCase()) ||
                 asset['code'].toLowerCase().contains(query.toLowerCase());
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
            child: _filteredAssets.isEmpty
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
    Color statusColor;
    Color statusBgColor;
    
    switch (asset['status']) {
      case 'Operational':
        statusColor = const Color(0xFF0A9C5D); // Green
        statusBgColor = const Color(0xFFE7F5EE);
        break;
      case 'Maintenance':
        statusColor = const Color(0xFFF59E0B); // Amber
        statusBgColor = const Color(0xFFFEF3C7);
        break;
      case 'Rusak':
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
              builder: (context) => AssetDetailPage(assetData: asset),
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
                      asset['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      asset['code'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          asset['location'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
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
                      asset['status'],
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
