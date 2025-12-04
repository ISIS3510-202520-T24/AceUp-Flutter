import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/assignments/assignment_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';

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
    } else if (tab == TodayTab.timetable && viewModel.timetableItems.isNotEmpty) {
      return _buildTimetableList(context, viewModel);
    }

    return EmptyState(
      message: viewModel.emptyStateMessage,
      subtitle: viewModel.emptyStateSubtitle,
      icon: viewModel.emptyStateIcon,
    );
  }

  Widget _buildTimetableList(BuildContext context, TodayViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.timetableItems.length,
      itemBuilder: (context, index) {
        final item = viewModel.timetableItems[index];
        return _TimetableItemCard(item: item, colors: colors);
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
      context.read<TodayViewModel>().refreshTimetable();
    }
  }

  Future<void> _handleAddClassAction(BuildContext context, TodayViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditClassScreen(),
      ),
    );

    if (result == true && context.mounted) {
      context.read<TodayViewModel>().refreshTimetable();
    }
  }
}

/// Widget to display a single timetable item (class or exam)
class _TimetableItemCard extends StatelessWidget {
  final TimetableItem item;
  final ColorScheme colors;

  const _TimetableItemCard({
    required this.item,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column (left)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTime(item.startTime),
                  style: AppTypography.bodyM.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatTime(item.endTime),
                  style: AppTypography.bodyS.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Icon in colored circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.subjectColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.isExam ? AppIcons.exam : (item.classIcon ?? AppIcons.chalkboard),
                size: 20,
                color: item.subjectColor,
              ),
            ),

            const SizedBox(width: 16),

            // Content column (right)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject name
                  Text(
                    item.subjectName,
                    style: AppTypography.h5.copyWith(
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Class/Exam name and teacher
                  if (item.name.isNotEmpty || item.teacherName != null)
                    Text(
                      [
                        if (item.name.isNotEmpty) item.name,
                        if (item.teacherName != null) item.teacherName,
                      ].join(', '),
                      style: AppTypography.bodyM.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                  const SizedBox(height: 4),

                  // Building and room
                  if (item.building != null || item.room != null)
                    Text(
                      [
                        if (item.building != null) item.building,
                        if (item.room != null) item.room,
                      ].join(' '),
                      style: AppTypography.bodyS.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}