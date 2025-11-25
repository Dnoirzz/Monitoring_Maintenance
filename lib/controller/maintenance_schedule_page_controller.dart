import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../repositories/asset_repository.dart';
import '../repositories/maintenance_schedule_repository.dart';
import '../model/mt_schedule_model.dart';
import '../model/mt_template_model.dart';

class MaintenanceSchedulePageController {
  final ScrollController verticalScrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController headerScrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  bool isSyncing = false;
  final AssetRepository _assetRepository = AssetRepository();
  final MaintenanceScheduleRepository _scheduleRepository = MaintenanceScheduleRepository();

  void init({required void Function(String) onSearchChange}) {
    horizontalScrollController.addListener(() {
      if (!isSyncing && headerScrollController.hasClients) {
        isSyncing = true;
        headerScrollController.jumpTo(horizontalScrollController.offset);
        Future.microtask(() => isSyncing = false);
      }
    });
    headerScrollController.addListener(() {
      if (!isSyncing && horizontalScrollController.hasClients) {
        isSyncing = true;
        horizontalScrollController.jumpTo(headerScrollController.offset);
        Future.microtask(() => isSyncing = false);
      }
    });
    searchController.addListener(() {
      onSearchChange(searchController.text);
    });
  }

  void handleHeaderPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!verticalScrollController.hasClients) return;
    final double targetOffset = (verticalScrollController.offset + event.scrollDelta.dy).clamp(
      verticalScrollController.position.minScrollExtent,
      verticalScrollController.position.maxScrollExtent,
    );
    if (targetOffset != verticalScrollController.offset) {
      verticalScrollController.jumpTo(targetOffset);
    }
  }

  Future<List<Map<String, dynamic>>> getAssetsOptions() async {
    final assets = await _assetRepository.getAllAssets();
    return assets.map((asset) => {
          'id': asset.id ?? '',
          'nama': asset.namaAset,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> getBagianMesinOptions(String assetId) async {
    final bagianList = await _assetRepository.getBagianByAssetId(assetId);
    return bagianList.map((bagian) => {
          'id': bagian.id ?? '',
          'nama': bagian.namaBagian,
        }).toList();
  }

  Future<MtSchedule> createSchedule(MtSchedule schedule) async {
    return await _scheduleRepository.createSchedule(schedule);
  }

  Future<MtTemplate> createTemplate(MtTemplate template) async {
    return await _scheduleRepository.createTemplate(template);
  }

  DateTime? computeNextOccurrenceInYear({
    required DateTime startDate,
    required int interval,
    required String periode,
    required int targetYear,
  }) {
    if (interval <= 0) return null;
    DateTime current = startDate;
    while (current.year < targetYear) {
      switch (periode) {
        case 'Hari':
          current = current.add(Duration(days: interval));
          break;
        case 'Minggu':
          current = current.add(Duration(days: interval * 7));
          break;
        case 'Bulan':
          current = DateTime(current.year, current.month + interval, current.day);
          break;
        default:
          return null;
      }
    }
    if (current.year == targetYear) {
      return current;
    }
    return null;
  }

  void dispose() {
    verticalScrollController.dispose();
    horizontalScrollController.dispose();
    headerScrollController.dispose();
    searchController.dispose();
  }
}
