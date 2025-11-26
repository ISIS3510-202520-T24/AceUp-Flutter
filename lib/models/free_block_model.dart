import 'package:flutter/material.dart';

/// Model for free time blocks in group schedules
class FreeBlock {
  final int weekday; // 1-7 (Monday-Sunday)
  final TimeOfDay start;
  final TimeOfDay end;
  final List<String> freeMembers;

  FreeBlock({
    required this.weekday,
    required this.start,
    required this.end,
    required this.freeMembers,
  });
}
