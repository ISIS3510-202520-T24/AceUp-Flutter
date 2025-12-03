import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/assignments/assignment_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_icons.dart';

import '../../widgets/assignment_card.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/content_counter.dart';
import '../../widgets/deletable_list_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/keep_alive_wrapper.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/content_switcher.dart';

import '../../viewmodels/today/today_viewmodel.dart';
import '../../data/repositories/academic_repository.dart';
import '../../core/constants/enums.dart';
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

    if (viewModel.state == ViewState.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: colors.primary,
        ),
      );
    }

    if (viewModel.state == ViewState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.error,
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
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return DeletableListItem(
          itemType: 'Assignment',
          itemName: assignment.title,
          onDelete: () => viewModel.deleteAssignment(assignment),
          onTap: () => _handleEditAssignmentAction(context, viewModel, assignment),
          child: AssignmentCard(
            assignment: assignment,
            showTimeInsteadOfDate: true,
            onToggleStatus: () => viewModel.toggleAssignmentStatus(assignment),
          )
        );
      },
    );
  }

  Future<void> _handleEditAssignmentAction(BuildContext context, TodayViewModel viewModel, Assignment assignment) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditAssignmentScreen(assignment: assignment),
      ),
    );

    if (result == true) {
          viewModel.refreshAssignments();
    }
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