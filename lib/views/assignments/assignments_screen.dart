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
import '../../data/repositories/academic_repository.dart';
import 'edit_assignment_screen.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AssignmentsViewModel(
        repository: context.read<AcademicRepository>(),
      ),
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
                KeepAliveWrapper(
                  child: _buildTabContent(context, viewModel, AssignmentsTab.pending),
                ),
                KeepAliveWrapper(
                  child: _buildTabContent(context, viewModel, AssignmentsTab.completed),
                ),
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

  Widget _buildTabContent(
      BuildContext context,
      AssignmentsViewModel viewModel,
      AssignmentsTab tab,
      ) {
    final colors = Theme.of(context).colorScheme;

    if (viewModel.state == AssignmentsViewState.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: colors.primary,
        ),
      );
    }

    if (viewModel.state == AssignmentsViewState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.priority,
                size: 48,
                color: colors.error,
              ),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage ?? 'An unknown error occurred',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurface,
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
        ),
      );
    }

    final assignments = tab == AssignmentsTab.pending
        ? viewModel.pendingAssignments
        : viewModel.completedAssignments;

    if (assignments.isEmpty) {
      return EmptyState(
        message: tab == AssignmentsTab.pending
            ? 'No pending assignments'
            : 'No completed assignments',
        subtitle: tab == AssignmentsTab.pending
            ? 'Create a new assignment to get started'
            : 'Complete some assignments to see them here',
        icon: AppIcons.assignments,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colors.outline.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Checkbox(
              value: assignment.isCompleted,
              onChanged: (_) => viewModel.toggleAssignmentStatus(assignment),
            ),
            title: Text(
              assignment.title,
              style: AppTypography.bodyL.copyWith(
                decoration: assignment.isCompleted ? TextDecoration.lineThrough : null,
                color: assignment.isCompleted ? colors.secondary : colors.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  assignment.subjectName,
                  style: AppTypography.bodyS.copyWith(
                    color: colors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      AppIcons.calendarDay,
                      size: 14,
                      color: colors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(assignment.dueDate),
                      style: AppTypography.bodyS.copyWith(
                        color: colors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityChip(assignment.priority, colors),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${assignment.weight}%',
                  style: AppTypography.bodyM.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'weight',
                  style: AppTypography.bodyXS.copyWith(
                    color: colors.secondary,
                  ),
                ),
              ],
            ),
            onTap: () => _navigateToEditAssignment(context, assignment),
          ),
        );
      },
    );
  }

  Widget _buildPriorityChip(String priority, ColorScheme colors) {
    Color chipColor;
    switch (priority.toLowerCase()) {
      case 'high':
        chipColor = AppColors.errorDark;
        break;
      case 'medium':
        chipColor = AppColors.warningDark;
        break;
      case 'low':
        chipColor = AppColors.successDark;
        break;
      default:
        chipColor = colors.secondaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority,
        style: AppTypography.bodyXS.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _handleAddAction(BuildContext context, AssignmentsViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditAssignmentScreen(assignment: null),
      ),
    );

    if (result == true && context.mounted) {
      context.read<AssignmentsViewModel>().refreshAssignments();
    }
  }

  Future<void> _navigateToEditAssignment(BuildContext context, assignment) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditAssignmentScreen(assignment: assignment),
      ),
    );

    if (result == true && context.mounted) {
      context.read<AssignmentsViewModel>().refreshAssignments();
    }
  }
}