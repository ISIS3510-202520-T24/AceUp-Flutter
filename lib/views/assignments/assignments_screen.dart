import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../themes/app_colors.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/assignments_viewmodel.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/content_switcher.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/top_bar.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AssignmentsViewModel(),
      child: const _AssignmentsScreenContent(),
    );
  }
}

class _AssignmentsScreenContent extends StatelessWidget {
  const _AssignmentsScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AssignmentsViewModel>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(
        title: "Assignments",
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
          Expanded(
            child: _buildContent(context, viewModel),
          ),
        ],
      ),
      floatingActionButton: FAB(
        options: [
          FabOption(
            icon: AppIcons.add,
            label: 'New Assignment',
            onPressed: () => _handleAddAction(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AssignmentsViewModel viewModel) {
    if (viewModel.state == AssignmentsViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == AssignmentsViewState.error) {
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

  Widget _buildEmptyState(BuildContext context, AssignmentsViewModel viewModel) {
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

  Widget _buildContentList(AssignmentsViewModel viewModel) {
    final assignments = viewModel.selectedTab == AssignmentsTab.pending
        ? viewModel.pendingAssignments
        : viewModel.completedAssignments;

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshAssignments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return _buildAssignmentCard(context, assignment, viewModel);
        },
      ),
    );
  }

  Widget _buildAssignmentCard(
      BuildContext context,
      assignment,
      AssignmentsViewModel viewModel,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Priority icon
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

    // Format due date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      assignment.dueDate.year,
      assignment.dueDate.month,
      assignment.dueDate.day,
    );

    String dueDateText;
    if (dueDate.isAtSameMomentAs(today)) {
      dueDateText = 'Due Today';
    } else if (dueDate.isBefore(today)) {
      final difference = today.difference(dueDate).inDays;
      dueDateText = difference == 1
          ? 'Overdue by 1 day'
          : 'Overdue by $difference days';
    } else {
      final difference = dueDate.difference(today).inDays;
      if (difference == 1) {
        dueDateText = 'Due Tomorrow';
      } else if (difference <= 7) {
        dueDateText = 'Due in $difference days';
      } else {
        dueDateText = DateFormat('MMM d, yyyy').format(assignment.dueDate);
      }
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

            // Assignment details
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

                  // Description
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

            // Due date and Priority icon column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Due date
                Text(
                  dueDateText,
                  style: AppTypography.bodyS.copyWith(
                    color: dueDate.isBefore(today) && assignment.isPending
                        ? Colors.red
                        : colors.onPrimaryContainer,
                    fontWeight: dueDate.isBefore(today) && assignment.isPending
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),

                // Priority icon
                Icon(
                  priorityIcon,
                  size: 21,
                  color: priorityColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddAction(BuildContext context, AssignmentsViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add new assignment - Coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}