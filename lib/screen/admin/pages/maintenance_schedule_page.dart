import 'package:flutter/material.dart';
import 'dart:async';

import 'package:monitoring_maintenance/controller/maintenance_schedule_controller.dart';
import 'package:monitoring_maintenance/model/maintenance_schedule_model.dart';

class MaintenanceSchedulePage extends StatefulWidget {
  final MaintenanceScheduleController controller;

  const MaintenanceSchedulePage({super.key, required this.controller});

  @override
  State<MaintenanceSchedulePage> createState() =>
      _MaintenanceSchedulePageState();
}

class _MaintenanceSchedulePageState extends State<MaintenanceSchedulePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late List<MaintenanceCategory> _categories;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  static const Color _planAccent = Color(0xFF2196F3);
  static const Color _actualAccent = Color(0xFFFF9800);

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  @override
  void initState() {
    super.initState();
    _categories = widget.controller.getAvailableCategories();
    _tabController = TabController(length: _categories.length, vsync: this);

    // Debounced search
    _searchController.addListener(() {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _searchQuery = _searchController.text.toLowerCase();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Maintenance Schedule",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF022415),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Fitur Tambah Maintenance Schedule")),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Tambah"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A9C5D),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama mesin atau bagian...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Color(0xFF0A9C5D)),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFF0A9C5D), width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildLegendChip('Plan', _planAccent),
            _buildLegendChip('Actual', _actualAccent),
          ],
        ),
        SizedBox(height: 16),
        // Tab Bar untuk kategori
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color(0xFFE0E0E0)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFF0A9C5D),
            indicator: BoxDecoration(
              color: Color(0xFF0A9C5D),
              borderRadius: BorderRadius.circular(10),
            ),
            tabs:
                _categories
                    .map((category) => Tab(text: category.displayName))
                    .toList(),
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children:
                _categories.map((category) {
                  return _buildCategoryView(category);
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryView(MaintenanceCategory category) {
    final scheduleEntries = widget.controller.getEntriesByCategory(category);

    // Filter berdasarkan search query
    final filteredEntries =
        _searchQuery.isEmpty
            ? scheduleEntries
            : scheduleEntries.where((entry) {
              return entry.machine.toLowerCase().contains(_searchQuery) ||
                  entry.part.toLowerCase().contains(_searchQuery);
            }).toList();

    if (filteredEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? "Belum ada data untuk ${category.displayName}"
                  : "Tidak ada hasil untuk '$_searchQuery'",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            if (_searchQuery.isNotEmpty) ...[
              SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
                child: Text(
                  'Bersihkan pencarian',
                  style: TextStyle(color: Color(0xFF0A9C5D)),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: filteredEntries.length,
      separatorBuilder: (_, __) => SizedBox(height: 20),
      itemBuilder: (context, index) {
        final entry = filteredEntries[index];
        return _buildScheduleCard(entry);
      },
    );
  }

  Widget _buildScheduleCard(MaintenanceScheduleEntry entry) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF132A13),
                    ),
                    children: [
                      ..._highlightText(entry.machine, _searchQuery),
                      TextSpan(text: ' • '),
                      ..._highlightText(entry.part, _searchQuery),
                    ],
                  ),
                ),
              ),
              Text(
                entry.liftTime,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  entry.monthlySchedule.entries
                      .map(
                        (monthEntry) =>
                            _buildMonthTile(monthEntry.key, monthEntry.value),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTile(String month, List<WeekMetric> weeks) {
    final monthIndex = monthShortNames.indexOf(month);

    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFF8F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFECECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF0A9C5D),
                ),
              ),
              Icon(Icons.calendar_month, size: 16, color: Color(0xFF0A9C5D)),
            ],
          ),
          SizedBox(height: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (weekInMonth) {
              final globalWeekNumber = getGlobalWeekNumber(
                monthIndex,
                weekInMonth,
              );
              final metric = weeks[weekInMonth];
              return _buildWeekRow('W$globalWeekNumber', metric);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekRow(String label, WeekMetric metric) {
    final bool hasData = metric.plan != null || metric.actual != null;

    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: hasData ? Colors.white : Colors.grey[50],
        border: Border.all(color: Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 10,
              color: hasData ? Color(0xFF132A13) : Colors.grey[400],
            ),
          ),
          SizedBox(height: 3),
          Row(
            children: [
              Expanded(child: _buildMetricBadge("P", metric.plan, _planAccent)),
              SizedBox(width: 3),
              Expanded(
                child: _buildMetricBadge("A", metric.actual, _actualAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String label, int? value, Color color) {
    final bool hasValue = value != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: hasValue ? color.withOpacity(0.15) : Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: hasValue ? color : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2),
          Flexible(
            child: Text(
              hasValue ? "$label:$value" : "$label:-",
              style: TextStyle(
                fontSize: 9,
                color: hasValue ? Colors.grey[700] : Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk highlight text yang dicari
  List<TextSpan> _highlightText(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matches = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          matches.add(TextSpan(text: text.substring(start)));
        }
        break;
      }

      if (index > start) {
        matches.add(TextSpan(text: text.substring(start, index)));
      }

      matches.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            backgroundColor: Color(0xFF0A9C5D).withOpacity(0.3),
            color: Color(0xFF0A9C5D),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + query.length;
    }

    return matches;
  }

  Widget _buildLegendChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
