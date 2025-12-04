import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/assignments/assignment_model.dart';
import '../../themes/app_icons.dart';

import '../../widgets/assignment_card.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/content_switcher.dart';
import '../../widgets/deletable_list_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/keep_alive_wrapper.dart';
import '../../widgets/top_bar.dart';

import '../../viewmodels/assignments/assignments_viewmodel.dart';
import '../../data/repositories/academic_repository.dart';
import '../../core/constants/enums.dart';
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

    if (viewModel.state == ViewState.loading) {
      return Center(
        child: CircularProgressIndicator(),
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
          return DeletableListItem(
            itemType: 'Assignment',
            itemName: assignment.title,
            onDelete: () => viewModel.deleteAssignment(assignment),
            onTap: () => _handleEditAction(context, viewModel, assignment),
            child: AssignmentCard(
              assignment: assignment,
              onToggleStatus: () => viewModel.toggleAssignmentStatus(assignment),
            )
          );
        },
      ),
    );
  }


  Future<void> _handleEditAction(BuildContext context, AssignmentsViewModel viewModel, Assignment assignment) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditAssignmentScreen(assignment: assignment),
      ),
    );

    if (result == true) {
          viewModel.refreshAssignments();
    }
  }

  Future<void> _handleAddAction(BuildContext context, AssignmentsViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditAssignmentScreen(assignment: null),
      ),
    );

    if (result == true) {
      viewModel.refreshAssignments();
    }
  }
}