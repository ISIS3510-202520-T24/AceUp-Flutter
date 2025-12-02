import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/enums.dart';
import '../../data/repositories/academic_repository.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/week_view/week_view_viewmodel.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/weekly_calendar_view.dart';
import '../holidays/edit_holiday_screen.dart';
import '../planner/edit_class_screen.dart';
import '../planner/edit_exam_screen.dart';

class WeekViewScreen extends StatelessWidget {
  const WeekViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeekViewViewModel(
        repository: context.read<AcademicRepository>(),
      ),
      child: _WeekViewScreenContent(),
    );
  }
}

class _WeekViewScreenContent extends StatelessWidget {
  const _WeekViewScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WeekViewViewModel>();

    return Scaffold(
      drawer: BurgerMenu(),
      appBar: TopBar(title: 'Week View'),
      body: _buildBody(context, viewModel),
      floatingActionButton: FAB(
        options: [
          FabOption(
            icon: AppIcons.chalkboard,
            label: 'New Class',
            onPressed: () => _handleAddClassAction(context, viewModel),
          ),
          FabOption(
            icon: AppIcons.exam,
            label: 'New Exam',
            onPressed: () => _handleAddExamAction(context, viewModel),
          ),
          FabOption(
            icon: AppIcons.holidays,
            label: 'New Holiday',
            onPressed: () => _handleAddHolidayAction(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeekViewViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;

    if (viewModel.state == ViewState.loading) {
      return Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    if (viewModel.state == ViewState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.error, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage ?? 'An error occurred',
                style: AppTypography.bodyM.copyWith(color: colors.onSurface),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final occurrences = viewModel.weeklyOccurrences;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Week navigation
        _buildWeekNavigation(context, viewModel),

        const SizedBox(height: 16),

        // Weekly calendar view
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: WeeklyCalendarView(
              occurrences: occurrences,
              onEventTap: (occurrence) {
                _showClassDetails(context, occurrence, viewModel);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekNavigation(BuildContext context, WeekViewViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;
    final weekStart = viewModel.currentWeekStart;
    final weekEnd = viewModel.currentWeekEnd;

    // Format date range
    final startFormatted = '${_monthName(weekStart.month)} ${weekStart.day}';
    final endFormatted = '${_monthName(weekEnd.month)} ${weekEnd.day}, ${weekEnd.year}';
    final dateRange = '$startFormatted - $endFormatted';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Your Weekly Schedule',
            style: AppTypography.h3.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Week navigation controls
          Row(
            children: [
              // Previous week button
              IconButton(
                onPressed: viewModel.goToPreviousWeek,
                icon: Icon(AppIcons.arrowLeft),
                color: colors.primary,
                tooltip: 'Previous week',
              ),

              // Current week date range
              Expanded(
                child: Text(
                  dateRange,
                  style: AppTypography.bodyM.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Next week button
              IconButton(
                onPressed: viewModel.goToNextWeek,
                icon: Icon(AppIcons.arrowRight),
                color: colors.primary,
                tooltip: 'Next week',
              ),
            ],
          ),

          // Today button (if not current week)
          if (!_isCurrentWeek(viewModel.currentWeekStart)) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: viewModel.goToCurrentWeek,
                child: Text(
                  'Go to current week',
                  style: AppTypography.bodyS.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  bool _isCurrentWeek(DateTime weekStart) {
    final now = DateTime.now();
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    return weekStart.year == currentMonday.year &&
           weekStart.month == currentMonday.month &&
           weekStart.day == currentMonday.day;
  }
  
  void _showClassDetails(
    BuildContext context,
    WeeklyClassOccurrence occurrence,
    WeekViewViewModel viewModel,
  ) {
    final colors = Theme.of(context).colorScheme;
    final classTemplate = occurrence.classTemplate;

    // Format date
    final date = occurrence.date;
    final dateFormatted = '${_dayName(date.weekday)}, ${_monthName(date.month)} ${date.day}, ${date.year}';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject name
            if (classTemplate.subjectName != null)
              Text(
                classTemplate.subjectName!,
                style: AppTypography.h4.copyWith(
                  color: colors.primary,
                ),
              ),
            const SizedBox(height: 8),

            // Class name
            Text(
              classTemplate.name,
              style: AppTypography.h3.copyWith(
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Date
            Row(
              children: [
                Icon(
                  AppIcons.calendarDay,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormatted,
                  style: AppTypography.bodyM.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${classTemplate.startTime} - ${classTemplate.endTime}',
                  style: AppTypography.bodyM.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),

            // Location
            if (classTemplate.location.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    AppIcons.location,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    classTemplate.location,
                    style: AppTypography.bodyM.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ],

            // Notes from exception
            if (occurrence.hasNotes) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        occurrence.notes!,
                        style: AppTypography.bodyM.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Actions
          ],
        ),
      ),
    );
  }

  String _dayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  Future<void> _handleAddHolidayAction(BuildContext context, WeekViewViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditHolidayScreen(),
      ),
    );

    if (result == true && context.mounted) {
      context.read<WeekViewViewModel>().refreshWeekView();
    }
  }

  Future<void> _handleAddExamAction(BuildContext context, WeekViewViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditExamScreen(),
      ),
    );

    if (result == true && context.mounted) {
      context.read<WeekViewViewModel>().refreshWeekView();
    }
  }

  Future<void> _handleAddClassAction(BuildContext context, WeekViewViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditClassScreen(),
      ),
    );

    if (result == true && context.mounted) {
      context.read<WeekViewViewModel>().refreshWeekView();
    }
  }
}

