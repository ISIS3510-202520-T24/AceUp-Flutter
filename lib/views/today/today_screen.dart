import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../themes/app_colors.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';

import '../../widgets/burger_menu.dart';
import '../../widgets/content_counter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/keep_alive_wrapper.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/content_switcher.dart';

import '../../viewmodels/today/today_viewmodel.dart';
import '../../data/repositories/academic_repository.dart';
import '../assignments/edit_assignment_screen.dart';
import '../planner/edit_class_screen.dart';
import '../planner/edit_exam_screen.dart';

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

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(title: "Today"),
      body: Column(
        children: [
          ContentSwitcher(
            controller: _tabController,
            tabs: viewModel.tabLabels,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                KeepAliveWrapper(
                  child: _buildTimetableContent(context, viewModel),
                ),
                KeepAliveWrapper(
                  child: _buildAssignmentsContent(context, viewModel),
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
            onPressed: () => _handleAddExamAction(context, viewModel),
          ),
          FabOption(
            icon: AppIcons.chalkboard,
            label: 'New Class',
            onPressed: () => _handleAddClassAction(context, viewModel),
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

  Widget _buildTimetableContent(BuildContext context, TodayViewModel viewModel) {
    return _buildTabContent(context, viewModel, TodayTab.timetable);
  }

  Widget _buildAssignmentsContent(BuildContext context, TodayViewModel viewModel) {
    return Column(
        children: [
          ContentCounter(
            firstItem: CounterItem(
              title: 'Done: ',
              value: '${viewModel.completedCount}',
              color: AppColors.successDark,
            ),
            secondItem: CounterItem(
              title: 'Pending: ',
              value: ' ${viewModel.pendingCount}',
              color: AppColors.errorDark,
            ),
          ),
          Expanded(child: _buildTabContent(context, viewModel, TodayTab.assignments)),
        ]
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
    } else if (tab == TodayTab.timetable && viewModel.timetable.isNotEmpty && viewModel.exams.isNotEmpty) {
      return _buildTimetableList(viewModel.timetable, viewModel.exams);
    }

    return EmptyState(
      message: viewModel.emptyStateMessage,
      subtitle: viewModel.emptyStateSubtitle,
      icon: viewModel.emptyStateIcon,
    );
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
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.subjectName ?? 'Unknown Subject',
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
                    assignment.description ?? '',
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
            Icon(
              priorityIcon,
              color: priorityColor,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddAssignmentAction(BuildContext context, TodayViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditAssignmentScreen(),
      ),
    );

    if (result == true && context.mounted) {
      context.read<TodayViewModel>().refreshAssignments();
    }
  }

  Future<void> _handleAddExamAction(BuildContext context, TodayViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditExamScreen(),
      ),
    );

    if (result == true && context.mounted) {
      context.read<TodayViewModel>().refreshAssignments();
    }
  }

  Future<void> _handleAddClassAction(BuildContext context, TodayViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditClassScreen(),
      ),
    );

    if (result == true && context.mounted) {
      context.read<TodayViewModel>().refreshAssignments();
    }
  }
}