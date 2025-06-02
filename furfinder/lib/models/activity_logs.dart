// lib/models/activity_log_entry.dart
import 'package:flutter/material.dart';

class ActivityLogEntry {
  final String time;
  final String description;
  final Color dotColor;
  final String petName;

  ActivityLogEntry({
    required this.time,
    required this.description,
    required this.dotColor,
    this.petName = "Aasyifa", // Default pet name, can be overridden
  });
}