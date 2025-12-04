// lib/views/calendar/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../../data/repositories/academic_repository.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/content_switcher.dart';
import '../../models/planner/class_template_model.dart';
import '../../models/assignments/assignment_model.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel(context.read<AcademicRepository>()),
      child: const _CalendarScreenContent(),
    );
  }
}

class _CalendarScreenContent extends StatefulWidget {
  const _CalendarScreenContent();

  @override
  State<_CalendarScreenContent> createState() => _CalendarScreenContentState();
}

class _CalendarScreenContentState extends State<_CalendarScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<CalendarViewModel>().selectTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewModel>();

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          _MonthHeader(
            date: viewModel.focusedMonth,
            onPrevious: () => viewModel.changeMonth(-1),
            onNext: () => viewModel.changeMonth(1),
          ),
          _CalendarGrid(
            focusedMonth: viewModel.focusedMonth,
            selectedDate: viewModel.selectedDate,
            onDateSelected: (date) => viewModel.selectDate(date),
          ),
          const SizedBox(height: 8),
          ContentSwitcher(
            controller: _tabController,
            tabs: const ['Timetable', 'Assignments'],
          ),
          Expanded(
            child: viewModel.loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _TimetableTab(classes: viewModel.classesForDay),
                      _AssignmentsTab(assignments: viewModel.assignmentsForDay),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.refresh,
        label: const Text('Refresh'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.date,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '${_monthName(date.month)} ${date.year}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[m - 1];
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final daysInMonth = _getDaysInMonth();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          ...List.generate(
            (daysInMonth.length / 7).ceil(),
            (weekIndex) {
              final weekDays = daysInMonth.skip(weekIndex * 7).take(7).toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekDays.map((date) {
                    final isSelected = date != null && _isSameDay(date, selectedDate);
                    final isToday = date != null && _isSameDay(date, DateTime.now());
                    final isCurrentMonth = date?.month == focusedMonth.month;

                    return Expanded(
                      child: date == null
                          ? const SizedBox(height: 40)
                          : GestureDetector(
                              onTap: () => onDateSelected(date),
                              child: Container(
                                height: 40,
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primary
                                      : isToday
                                          ? colors.primaryContainer
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: isToday && !isSelected
                                      ? Border.all(color: colors.primary, width: 2)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? colors.onPrimary
                                          : isCurrentMonth
                                              ? colors.onSurface
                                              : colors.onSurfaceVariant.withOpacity(0.4),
                                      fontWeight: isSelected || isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<DateTime?> _getDaysInMonth() {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    
    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    final firstWeekday = firstDay.weekday;
    
    // Create list with null placeholders for days before the month starts
    final List<DateTime?> days = List.filled(firstWeekday - 1, null, growable: true);
    
    // Add all days of the month
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(focusedMonth.year, focusedMonth.month, day));
    }
    
    // Add null placeholders to complete the last week
    while (days.length % 7 != 0) {
      days.add(null);
    }
    
    return days;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class _TimetableTab extends StatelessWidget {
  final List<ClassTemplate> classes;

  const _TimetableTab({required this.classes});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: colors.outline),
            const SizedBox(height: 16),
            Text(
              'No classes for this day',
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classItem = classes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(classItem.icon),
            ),
            title: Text(classItem.name),
            subtitle: Text(
              '${classItem.startTime} - ${classItem.endTime}${classItem.room != null ? " • ${classItem.room}" : ""}',
            ),
            trailing: classItem.building != null
                ? Text(
                    classItem.building!,
                    style: TextStyle(color: colors.primary),
                  )
                : null,
          ),
        );
      },
    );
  }
}

class _AssignmentsTab extends StatelessWidget {
  final List<Assignment> assignments;

  const _AssignmentsTab({required this.assignments});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: colors.outline),
            const SizedBox(height: 16),
            Text(
              'No assignments for this day',
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              assignment.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: assignment.isCompleted ? Colors.green : colors.primary,
            ),
            title: Text(
              assignment.title,
              style: TextStyle(
                decoration: assignment.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text(
              assignment.dueTime != null
                  ? 'Due at ${assignment.dueTime}'
                  : 'Due today',
            ),
            trailing: _PriorityBadge(priority: assignment.priority),
          ),
        );
      },
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final dynamic priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final priorityStr = priority.toString().split('.').last;
    
    Color badgeColor;
    switch (priorityStr.toLowerCase()) {
      case 'high':
        badgeColor = Colors.red;
        break;
      case 'medium':
        badgeColor = Colors.orange;
        break;
      case 'low':
        badgeColor = Colors.blue;
        break;
      default:
        badgeColor = colors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priorityStr.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
