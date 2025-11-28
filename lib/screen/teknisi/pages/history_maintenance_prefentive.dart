import 'package:flutter/material.dart';

class HistoryMaintenancePreventivePage extends StatefulWidget {
  const HistoryMaintenancePreventivePage({super.key});

  @override
  State<HistoryMaintenancePreventivePage> createState() =>
      _HistoryMaintenancePreventivePageState();
}

class _HistoryMaintenancePreventivePageState
    extends State<HistoryMaintenancePreventivePage> {
  final Color _primaryColor = const Color(0xFF0A9C5D);
  final Color _backgroundLight = const Color(0xFFF6F8F7);

  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Selesai', 'Berlangsung'];

  // Static data for demonstration
  final List<Map<String, dynamic>> _tasks = [
    {
      'machineName': 'Mesin Press Hidrolik A-01',
      'date': '15 Oktober 2023',
      'type': 'Perawatan Berkala',
      'status': 'Selesai',
      'statusColor': Colors.green,
    },
    {
      'machineName': 'Mesin Milling CNC B-05',
      'date': '14 Oktober 2023',
      'type': 'Pemeriksaan Sensor',
      'status': 'Berlangsung',
      'statusColor': Colors.blue,
    },
    {
      'machineName': 'Mesin Bubut Konvensional C-02',
      'date': '12 Oktober 2023',
      'type': 'Perawatan Rutin',
      'status': 'Selesai',
      'statusColor': Colors.green,
    },
  ];

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
          'Riwayat Perawatan Terjadwal',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1.0),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                // Simple filter logic for static data
                if (_selectedFilter != 'Semua' &&
                    task['status'] != _selectedFilter) {
                  return const SizedBox.shrink();
                }
                return _buildTaskCard(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['machineName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task['date'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  task['type'],
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (task['statusColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              task['status'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: task['statusColor'],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
