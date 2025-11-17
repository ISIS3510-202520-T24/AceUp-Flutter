import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/academic_repository.dart';
import '../../themes/app_icons.dart';
import '../../viewmodels/planner/subject_viewmodel.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/content_switcher.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/keep_alive_wrapper.dart';
import '../../widgets/top_bar.dart';
import '../assignments/edit_assignment_screen.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SubjectViewModel(
        repository: context.read<AcademicRepository>(),
      ),
      child: const _SubjectScreenContent(),
    );
  }
}

class _SubjectScreenContent extends StatefulWidget {
  const _SubjectScreenContent();

  @override
  State<_SubjectScreenContent> createState() => _SubjectScreenContentState();
}

class _SubjectScreenContentState extends State<_SubjectScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<SubjectViewModel>();

    _tabController = TabController(
      length: viewModel.tabLabels.length,
      vsync: this,
      initialIndex: viewModel.selectedTabIndex,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
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
    final viewModel = context.watch<SubjectViewModel>();

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(
        title: 'Subject Details',
        leftControlType: LeftControlType.back,
        rightControlType: RightControlType.edit,
      ),
      body: Column(
        children: [
          ContentSwitcher(
              controller: _tabController,
              tabs: viewModel.tabLabels
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
                KeepAliveWrapper(
                  child: _buildGradesContent(context, viewModel),
                ),
              ],
            ),
          )
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

  Widget _buildTimetableContent(BuildContext context, SubjectViewModel viewModel) {
    return const Center(
      child: Text('Timetable Content - Coming Soon!'),
    );
  }

  Widget _buildAssignmentsContent(BuildContext context, SubjectViewModel viewModel) {
    return const Center(
      child: Text('Assignments Content - Coming Soon!'),
    );
  }

  Widget _buildGradesContent(BuildContext context, SubjectViewModel viewModel) {
    return const Center(
      child: Text('Grades Content - Coming Soon!'),
    );
  }

  Future<void> _handleAddAssignmentAction(BuildContext context, SubjectViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditAssignmentScreen(assignment: null),
      ),
    );

    if (result == true && context.mounted) {
      context.read<SubjectViewModel>().refreshAssignments();
    }
  }

  void _handleAddAction(BuildContext context, SubjectViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add new - Coming Soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}