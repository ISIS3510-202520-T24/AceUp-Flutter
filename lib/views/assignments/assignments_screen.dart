import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../themes/app_colors.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';

import '../../widgets/burger_menu.dart';
import '../../widgets/content_switcher.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/keep_alive_wrapper.dart';
import '../../widgets/top_bar.dart';

import '../../viewmodels/assignments/assignments_viewmodel.dart';

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

class _AssignmentsScreenContent extends StatefulWidget {
  const _AssignmentsScreenContent();

  @override
  State<_AssignmentsScreenContent> createState() =>
      _AssignmentsScreenContentState();
}

class _AssignmentsScreenContentState extends State<_AssignmentsScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<AssignmentsViewModel>();

    _tabController = TabController(
      length: viewModel.tabLabels.length,
      vsync: this,
      initialIndex: viewModel.selectedTabIndex,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        viewModel.selectTab(_tabController.index);
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
    final viewModel = context.watch<AssignmentsViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(title: "Assignments"),
      body: Column(
        children: [
          ContentSwitcher(
            tabs: viewModel.tabLabels,
            controller: _tabController,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                KeepAliveWrapper(child: _buildTabContent(context, viewModel, AssignmentsTab.pending)),
                KeepAliveWrapper(child: _buildTabContent(context, viewModel, AssignmentsTab.completed)),
              ],
            ),
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

  Widget _buildTabContent(BuildContext context, AssignmentsViewModel viewModel, AssignmentsTab tab) {
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
      return _buildContentList(context, viewModel, tab);
    } else {
      return EmptyState(
          message: viewModel.emptyStateMessage,
          subtitle: viewModel.emptyStateSubtitle,
          icon: AppIcons.assignments);
    }
  }

  Widget _buildContentList(BuildContext context, AssignmentsViewModel viewModel, AssignmentsTab tab) {
    final assignments = tab == AssignmentsTab.pending
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
      dynamic assignment,
      AssignmentsViewModel viewModel,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    IconData priorityIcon;
    Color priorityColor;
    switch (assignment.priority) {
      case 'High':
        priorityIcon = AppIcons.priority;
        priorityColor = AppColors.errorMedium;
        break;
      case 'Low':
        priorityIcon = AppIcons.priority;
        priorityColor = AppColors.successMedium;
        break;
      default: // Medium
        priorityIcon = AppIcons.priority;
        priorityColor = AppColors.warningMedium;
    }

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
      if (assignment.isPending) {
        dueDateText = difference == 1
            ? 'Overdue by 1 day'
            : 'Overdue by $difference days';
      } else {
        dueDateText = DateFormat('MMM d, yyyy').format(assignment.dueDate);
      }
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dueDateText,
                  style: AppTypography.bodyS.copyWith(
                    color: dueDate.isBefore(today) && assignment.isPending
                        ? colors.onError
                        : colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),

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