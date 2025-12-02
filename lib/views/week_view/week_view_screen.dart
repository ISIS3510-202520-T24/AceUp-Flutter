import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    if (viewModel.state == WeekViewViewState.loading) {
      return Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    if (viewModel.state == WeekViewViewState.error) {
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
        // Header with info
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Your Weekly Schedule',
            style: AppTypography.h3.copyWith(
              color: colors.onSurface,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Classes from Monday to Friday (7:00 a.m. – 10:00 p.m.)',
            style: AppTypography.bodyS.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
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
  
  void _showClassDetails(
    BuildContext context,
    WeeklyClassOccurrence occurrence,
    WeekViewViewModel viewModel,
  ) {
    final colors = Theme.of(context).colorScheme;
    final classTemplate = occurrence.classTemplate;

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
            
            // Time
            Row(
              children: [
                Icon(
                  AppIcons.calendarDay,
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
            
            const SizedBox(height: 24),
            
            // Actions
          ],
        ),
      ),
    );
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

