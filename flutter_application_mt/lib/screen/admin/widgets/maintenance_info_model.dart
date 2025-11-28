import 'package:flutter/material.dart';

/// Model untuk informasi maintenance pada kalendar
class MaintenanceInfo {
  final String machine;
  final String part;
  final String type; // 'Plan' or 'Actual'
  final Color color;

  MaintenanceInfo({
    required this.machine,
    required this.part,
    required this.type,
    required this.color,
  });
}
