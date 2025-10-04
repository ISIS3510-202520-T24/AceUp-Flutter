import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../themes/app_icons.dart';
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
                onPressed: () => _handleAddAction(context, viewModel)
            ),
            FabOption(
                icon: AppIcons.chalkboard,
                label: 'New Class',
                onPressed: () => _handleAddAction(context, viewModel)
            ),
            FabOption(
                icon: AppIcons.assignments,
                label: 'New Assignment',
                onPressed: () => _handleAddAction(context, viewModel)
            ),
          ]
      ),
    );
  }

  Widget _buildContent(BuildContext context, TodayViewModel viewModel) {
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

                // Subtitle
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
        return _buildAssignmentsList(viewModel.assignments);
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

  Widget _buildAssignmentsList(List<String> assignments) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(assignments[index]),
          ),
        );
      },
    );
  }

  void _handleAddAction(BuildContext context, TodayViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add new - Coming Soon!'),
        duration: const Duration(seconds: 2),
      ),
    );

    // TODO: Navigate to appropriate add screen or show dialog
    // Example:
    // switch (viewModel.selectedTab) {
    //   case TodayTab.exams:
    //     _showAddExamDialog(context);
    //     break;
    //   case TodayTab.timetable:
    //     _showAddClassDialog(context);
    //     break;
    //   case TodayTab.assignments:
    //     _showAddAssignmentDialog(context);
    //     break;
    // }
  }
}