// lib/group_detail_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for FontFeature

// Simple model for a day of the week
class Day {
  final String shortName;
  final int dayNumber;
  final bool isSelected;

  Day({required this.shortName, required this.dayNumber, this.isSelected = false});
}

class GroupDetailScreen extends StatefulWidget {
  final String groupName;

  const GroupDetailScreen({super.key, required this.groupName});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  // Sample data for the week
  final List<Day> weekDays = [
    Day(shortName: 'MON', dayNumber: 19),
    Day(shortName: 'TUE', dayNumber: 20),
    Day(shortName: 'WED', dayNumber: 21),
    Day(shortName: 'THU', dayNumber: 22, isSelected: true), // Selected day
    Day(shortName: 'FRI', dayNumber: 23),
    Day(shortName: 'SAT', dayNumber: 24),
    Day(shortName: 'SUN', dayNumber: 25),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFC3D2E4), // Main app bar color
        elevation: 0,
        // Menu icon on the left
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF2C3E50)),
          onPressed: () {},
        ),
        // Main screen title
        title: const Text(
          'Shared',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // "Edit" button on the right
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Edit',
              style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16),
            ),
          ),
        ],
        // --- SECONDARY BAR WITH THE GROUP NAME ---
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // Height of the secondary bar
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: const BoxDecoration(
              color: Color(0xFFE0E7F3), // Secondary bar color
              border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50), size: 20),
                  onPressed: () => Navigator.of(context).pop(), // Go back
                ),
                Text(
                  widget.groupName,
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildWeekSelector(),
          Expanded(
            child: _buildTimeline(),
          ),
        ],
      ),
    );
  }

  // Widget for the bar with the days of the week
  Widget _buildWeekSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((day) => _buildDayItem(day)).toList(),
      ),
    );
  }

  // Widget for each individual day
  Widget _buildDayItem(Day day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: day.isSelected ? const Color(0xFF66DDC5) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day.shortName,
            style: TextStyle(
              fontSize: 12,
              color: day.isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day.dayNumber.toString(),
            style: TextStyle(
              fontSize: 18,
              color: day.isSelected ? Colors.white : const Color(0xFF2C3E50),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget for the timeline with horizontal lines
  Widget _buildTimeline() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 12, // Number of lines to display
      itemBuilder: (context, index) {
        return Container(
          height: 60, // Height of each hour block
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 1.0),
            ),
          ),
        );
      },
    );
  }
}
