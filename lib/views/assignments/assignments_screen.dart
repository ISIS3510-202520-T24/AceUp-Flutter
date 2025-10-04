import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../themes/app_icons.dart';
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
              onTabSelected: (index) => viewModel.selectTab(index)
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
                onPressed: () => _handleAddAction(context, viewModel)
            )
          ]
      )
    );
  }

  Widget _buildContent(BuildContext context, AssignmentsViewModel viewModel) {
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
    );
  }

  Widget _buildContentList(AssignmentsViewModel viewModel) {
    final assignments = viewModel.selectedTab == AssignmentsTab.pending
        ? viewModel.pendingAssignments
        : viewModel.completedAssignments;

    return ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return ListTile(
          title: Text(assignment),
          // Add more details as needed
        );
      },
    );
  }

  void _handleAddAction(BuildContext context, AssignmentsViewModel viewModel) {
    //Navigator.pushNamed(context, '/add-assignment');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add new assignment - Coming soon!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}