import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../themes/app_colors.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';

import '../../widgets/burger_menu.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/keep_alive_wrapper.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/content_switcher.dart';

import '../../viewmodels/today/today_viewmodel.dart';
import '../../data/repositories/academic_repository.dart';
import '../assignments/edit_assignment_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodayViewModel(
        repository: context.read<AcademicRepository>(),
      ),
      child: const _TodayScreenContent(),
    );
  }
}

class _TodayScreenContent extends StatefulWidget {
  const _TodayScreenContent();

  @override
  State<_TodayScreenContent> createState() => _TodayScreenContentState();
}

class _TodayScreenContentState extends State<_TodayScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<TodayViewModel>();

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
    final viewModel = context.watch<TodayViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(title: "Today"),
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
                  child: _buildTabContent(context, viewModel, TodayTab.timetable),
                ),
                KeepAliveWrapper(
                  child: _buildTabContent(context, viewModel, TodayTab.assignments),
                ),
              ],
            ),
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
            onPressed: () => _handleAddAssignmentAction(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, TodayViewModel viewModel, TodayTab tab) {
    final colors = Theme.of(context).colorScheme;

    if (viewModel.state == TodayViewState.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: colors.primary,
        ),
      );
    }

    if (viewModel.state == TodayViewState.error) {
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

    if (tab == TodayTab.assignments && viewModel.assignmentsDueToday.isNotEmpty) {
      return _buildAssignmentsList(viewModel);
    } else if (tab == TodayTab.timetable && viewModel.timetable.isNotEmpty) {
      return _buildTimetableList(viewModel.timetable, viewModel.exams);
    }

    return EmptyState(
      message: viewModel.emptyStateMessage,
      subtitle: viewModel.emptyStateSubtitle,
      icon: viewModel.emptyStateIcon,
    );
  }

  Widget _buildTimetableList(List<String> timetable, List<String> exams) {
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
    final colors = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.assignmentsDueToday.length,
      itemBuilder: (context, index) {
        final assignment = viewModel.assignmentsDueToday[index];

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
                      AppIcons.clock,
                      size: 14,
                      color: colors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(assignment.dueDate),
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _handleAddAssignmentAction(BuildContext context, TodayViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditAssignmentScreen(assignment: null),
      ),
    );

    if (result == true && context.mounted) {
      context.read<TodayViewModel>().refreshAssignments();
    }
  }

  Future<void> _navigateToEditAssignment(BuildContext context, assignment) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditAssignmentScreen(assignment: assignment),
      ),
    );

    if (result == true && context.mounted) {
      context.read<TodayViewModel>().refreshAssignments();
    }
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