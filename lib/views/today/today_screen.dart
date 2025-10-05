import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../themes/app_colors.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/content_switcher.dart';
import '../../viewmodels/today_viewmodel.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodayViewModel(),
      child: const _TodayScreenContent(),
    );
  }
}

class _TodayScreenContent extends StatelessWidget {
  const _TodayScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TodayViewModel>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(
        title: "Today",
        leftControlType: LeftControlType.menu,
        rightControlType: RightControlType.none,
      ),
      body: Column(
        children: [
          ContentSwitcher(
            tabs: viewModel.tabLabels,
            selectedIndex: viewModel.selectedTabIndex,
            onTabSelected: (index) => viewModel.selectTab(index),
          ),

          // Progress widget (only visible in assignments tab)
          if (viewModel.selectedTab == TodayTab.assignments)
            _buildProgressWidget(context, viewModel),

          Expanded(
            child: _buildContent(context, viewModel),
          ),
        ],
      ),
      floatingActionButton: FAB(
        options: [
          FabOption(
            icon: AppIcons.exam,
            label: 'New Exam',
            onPressed: () => _handleAddAction(context, viewModel),
          ),
          FabOption(
            icon: AppIcons.chalkboard,
            label: 'New Class',
            onPressed: () => _handleAddAction(context, viewModel),
          ),
          FabOption(
            icon: AppIcons.assignments,
            label: 'New Assignment',
            onPressed: () => _handleAddAction(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressWidget(BuildContext context, TodayViewModel viewModel) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceDim,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProgressItem(
                        context,
                        count: viewModel.completedCount,
                        label: 'Done: ',
                        color: AppColors.successDark,
                      ),
                      _buildProgressItem(
                        context,
                        count: viewModel.pendingCount,
                        label: 'Pending: ',
                        color: AppColors.errorDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      BuildContext context, {
        required int count,
        required String label,
        required Color color,
      }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: AppTypography.h4.copyWith(color: colors.onSurface),
        ),
        Text(
          '$count',
          style: AppTypography.h4.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, TodayViewModel viewModel) {
    if (viewModel.state == TodayViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == TodayViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load assignments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'An unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.refreshAssignments(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.hasContent) {
      return _buildContentList(viewModel);
    } else {
      return _buildEmptyState(context, viewModel);
    }
  }

  Widget _buildEmptyState(BuildContext context, TodayViewModel viewModel) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colors.tertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppIcons.icons,
                    size: 40,
                    color: colors.secondary,
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    viewModel.emptyStateMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  viewModel.emptyStateSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildContentList(TodayViewModel viewModel) {
    switch (viewModel.selectedTab) {
      case TodayTab.exams:
        return _buildExamsList(viewModel.exams);
      case TodayTab.timetable:
        return _buildTimetableList(viewModel.timetable);
      case TodayTab.assignments:
        return _buildAssignmentsList(viewModel);
    }
  }

  Widget _buildExamsList(List<String> exams) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(exams[index]),
          ),
        );
      },
    );
  }

  Widget _buildTimetableList(List<String> timetable) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timetable.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(timetable[index]),
          ),
        );
      },
    );
  }

  Widget _buildAssignmentsList(TodayViewModel viewModel) {
    final assignments = viewModel.assignmentsDueToday;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return _buildAssignmentCard(context, assignment, viewModel);
      },
    );
  }

  Widget _buildAssignmentCard(
      BuildContext context,
      assignment,
      TodayViewModel viewModel,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    IconData priorityIcon;
    Color priorityColor;
    switch (assignment.priority) {
      case 'High':
        priorityIcon = AppIcons.importance;
        priorityColor = AppColors.errorMedium;
        break;
      case 'Low':
        priorityIcon = AppIcons.importance;
        priorityColor = AppColors.successMedium;
        break;
      default: // Medium
        priorityIcon = AppIcons.importance;
        priorityColor = AppColors.warningMedium;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: assignment.isCompleted,
              onChanged: (value) {
                viewModel.toggleAssignmentStatus(assignment);
              },
              activeColor: colors.primary,
              checkColor: colors.onPrimary,
              side: BorderSide(color: colors.primary, width: 2),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.subjectName,
                    style: AppTypography.h5.copyWith(
                      color: colors.onSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    assignment.title,
                    style: AppTypography.bodyM.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    assignment.description,
                    style: AppTypography.bodyS.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Priority icon
            Icon(
              priorityIcon,
              size: 21,
              color: priorityColor,
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddAction(BuildContext context, TodayViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add new - Coming Soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}