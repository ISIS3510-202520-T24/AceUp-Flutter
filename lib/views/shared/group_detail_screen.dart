import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/group_detail_viewmodel.dart';
import '../../models/day.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupName;

  const GroupDetailScreen({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupDetailViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFC3D2E4),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF2C3E50)),
            onPressed: () {},
          ),
          title: const Text(
            'Shared',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'Edit',
                style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: const BoxDecoration(
                color: Color(0xFFE0E7F3),
                border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Color(0xFF2C3E50), size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    groupName,
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
            const _WeekSelector(),
            const Expanded(child: _Timeline()),
          ],
        ),
      ),
    );
  }
}

class _WeekSelector extends StatelessWidget {
  const _WeekSelector();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupDetailViewModel>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: viewModel.weekDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          return GestureDetector(
            onTap: () => viewModel.selectDay(index),
            child: _DayItem(day: day),
          );
        }).toList(),
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final Day day;
  const _DayItem({required this.day});

  @override
  Widget build(BuildContext context) {
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
}

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          height: 60,
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
