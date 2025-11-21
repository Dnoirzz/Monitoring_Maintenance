import 'package:flutter/material.dart';
import 'package:monitoring_maintenance/controller/maintenance_schedule_controller.dart';
import 'package:monitoring_maintenance/model/maintenance_schedule_model.dart';
import 'package:monitoring_maintenance/screen/admin/widgets/maintenance_info_model.dart';

/// Maintenance Schedule dalam format kalender
class MaintenanceSchedulePage extends StatefulWidget {
  final MaintenanceScheduleController controller;

  const MaintenanceSchedulePage({super.key, required this.controller});

  @override
  State<MaintenanceSchedulePage> createState() =>
      _MaintenanceSchedulePageState();
}

class _MaintenanceSchedulePageState extends State<MaintenanceSchedulePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  MaintenanceCategory? _selectedCategory;

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MaintenanceScheduleEntry> _getFilteredEntries() {
    var entries = widget.controller.getEntries();

    // Filter by category
    if (_selectedCategory != null) {
      entries = entries.where((e) => e.category == _selectedCategory).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      entries =
          entries.where((e) {
            return e.machine.toLowerCase().contains(_searchQuery) ||
                e.part.toLowerCase().contains(_searchQuery);
          }).toList();
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Kalender Maintenance",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF022415),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Fitur Tambah Maintenance Schedule"),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Tambah"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A9C5D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Controls Row
          Row(
            children: [
              // Search
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari mesin atau bagian...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF0A9C5D),
                      ),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Category Filter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<MaintenanceCategory?>(
                      value: _selectedCategory,
                      isExpanded: true,
                      hint: const Text('Semua Kategori'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Semua Kategori'),
                        ),
                        ...MaintenanceCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat.displayName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Month/Year Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    if (_selectedMonth == 1) {
                      _selectedMonth = 12;
                      _selectedYear--;
                    } else {
                      _selectedMonth--;
                    }
                  });
                },
              ),
              const SizedBox(width: 16),
              Text(
                '${_monthNames[_selectedMonth - 1]} $_selectedYear',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF022415),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    if (_selectedMonth == 12) {
                      _selectedMonth = 1;
                      _selectedYear++;
                    } else {
                      _selectedMonth++;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendItem(const Color(0xFF2196F3), 'Plan'),
              _buildLegendItem(const Color(0xFF4CAF50), 'Actual'),
            ],
          ),
          const SizedBox(height: 16),

          // Calendar
          Container(
            height: 800,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _buildCalendarView(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    final entries = _getFilteredEntries();
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final firstDayOfWeek =
        DateTime(_selectedYear, _selectedMonth, 1).weekday % 7;

    return Column(
      children: [
        // Day headers
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A9C5D), Color(0xFF088A52)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children:
                ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),

        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: firstDayOfWeek + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstDayOfWeek) {
                return const SizedBox(); // Empty cells before first day
              }

              final day = index - firstDayOfWeek + 1;
              final maintenances = _getMaintenancesForDay(entries, day);

              return _buildDayCell(day, maintenances);
            },
          ),
        ),
      ],
    );
  }

  List<MaintenanceInfo> _getMaintenancesForDay(
    List<MaintenanceScheduleEntry> entries,
    int day,
  ) {
    final monthKey = monthShortNames[_selectedMonth - 1];
    final maintenances = <MaintenanceInfo>[];

    for (var entry in entries) {
      final schedule = entry.monthlySchedule[monthKey];
      if (schedule == null) continue;

      // Check each week for this day
      for (var i = 0; i < schedule.length; i++) {
        final week = schedule[i];

        // Check plan (perkiraan maintenance)
        if (week.plan == day) {
          maintenances.add(
            MaintenanceInfo(
              machine: entry.machine,
              part: entry.part,
              type: 'Plan',
              color: const Color(0xFF2196F3),
            ),
          );
        }

        // Check actual (pelaksanaan asli)
        if (week.actual == day) {
          maintenances.add(
            MaintenanceInfo(
              machine: entry.machine,
              part: entry.part,
              type: 'Actual',
              color: const Color(0xFF4CAF50),
            ),
          );
        }
      }
    }

    return maintenances;
  }

  Widget _buildDayCell(int day, List<MaintenanceInfo> maintenances) {
    final isToday =
        day == DateTime.now().day &&
        _selectedMonth == DateTime.now().month &&
        _selectedYear == DateTime.now().year;

    return InkWell(
      onTap:
          maintenances.isNotEmpty
              ? () => _showMaintenanceDetails(day, maintenances)
              : null,
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? const Color(0xFF0A9C5D).withOpacity(0.1) : null,
          border: Border.all(
            color:
                isToday
                    ? const Color(0xFF0A9C5D)
                    : Colors.grey.withOpacity(0.2),
            width: isToday ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day number
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                '$day',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? const Color(0xFF0A9C5D) : Colors.black87,
                ),
              ),
            ),

            // Maintenance indicators
            if (maintenances.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Column(
                    children:
                        maintenances.take(2).map((m) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: m.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: m.color, width: 1),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${m.machine}\n${m.part}',
                                  style: TextStyle(
                                    color: m.color,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),

            // More indicator
            if (maintenances.length > 2)
              Padding(
                padding: const EdgeInsets.all(3),
                child: FittedBox(
                  child: Text(
                    '+${maintenances.length - 2}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMaintenanceDetails(int day, List<MaintenanceInfo> maintenances) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Maintenance ${_monthNames[_selectedMonth - 1]} $day, $_selectedYear',
              style: const TextStyle(fontSize: 18),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: maintenances.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final m = maintenances[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: m.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.build, color: m.color, size: 20),
                    ),
                    title: Text(
                      m.machine,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${m.part}\n${m.type}'),
                    isThreeLine: true,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: m.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: m.color),
                      ),
                      child: Text(
                        m.type,
                        style: TextStyle(
                          color: m.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }
}
