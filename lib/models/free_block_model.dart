import 'package:flutter/material.dart';

class FreeBlock {
  final int weekday; // 1=Monday, 7=Sunday
  final TimeOfDay start;
  final TimeOfDay end;
  final List<String> freeMembers; // Nombres de los miembros libres en ese bloque

  FreeBlock({
    required this.weekday,
    required this.start,
    required this.end,
    required this.freeMembers,
  });
}
