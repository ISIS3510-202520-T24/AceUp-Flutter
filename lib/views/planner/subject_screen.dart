import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/enums.dart';
import '../../data/repositories/academic_repository.dart';
import '../../models/planner/class_template_model.dart';
import '../../models/planner/exam_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/planner/subject_viewmodel.dart';
import '../../widgets/content_counter.dart';
import '../../widgets/content_switcher.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/keep_alive_wrapper.dart';
import '../../widgets/top_bar.dart';
import '../assignments/edit_assignment_screen.dart';
import 'edit_class_screen.dart';
import 'edit_exam_screen.dart';
import 'edit_subject_screen.dart';

class SubjectScreen extends StatelessWidget {
  final String subjectId;
  final String termId;

  const SubjectScreen({
    super.key,
    required this.subjectId,
    required this.termId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SubjectViewModel(
        repository: context.read<AcademicRepository>(),
        subjectId: subjectId,
        termId: termId,
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
      if (!mounted) return;
      // Update whenever the index changes, not just during animation
      viewModel.selectTab(_tabController.index);
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
      appBar: TopBar(
        title: viewModel.subject?.name ?? '',
        leftControlType: LeftControlType.back,
        rightControlType: RightControlType.edit,
        onRightPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditSubjectScreen(subject: viewModel.subject, termId: viewModel.termId),
            ),
          );
          if (result == true) {
            viewModel.refreshSubject();
          }
        },
      ),
      body: viewModel.state == ViewState.loading
          ? Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      )
          : viewModel.state == ViewState.error
          ? Center(
        child: Text(
          viewModel.errorMessage ?? 'An error occurred',
          style: AppTypography.bodyM,
        ),
      )
          : Column(
        children: [
          ContentSwitcher(
            tabs: viewModel.tabLabels,
            controller: _tabController,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                KeepAliveWrapper(child: _buildTimetableTab(context, viewModel)),
                KeepAliveWrapper(child: _buildAssignmentsTab(context, viewModel)),
                KeepAliveWrapper(child: _buildGradesTab(context, viewModel)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context, viewModel),
    );
  }

  Widget? _buildFAB(BuildContext context, SubjectViewModel viewModel) {
    // Ensure the FAB rebuilds when the tab changes
    final currentTab = viewModel.selectedTab;

    switch (currentTab) {
      case SubjectTab.assignments:
        // Show only Assignment FAB
        return FAB(
          options: [
            FabOption(
              icon: AppIcons.add,
              label: 'Add Assignment',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditAssignmentScreen(
                      assignment: null,
                      subjectId: viewModel.subjectId,
                      termId: viewModel.termId,
                    ),
                  ),
                );
                if (result == true) {
                  viewModel.refreshAssignments();
                }
              },
            ),
          ],
        );

      case SubjectTab.timetable:
        // Show Class and Exam FABs
        return FAB(
          options: [
            FabOption(
              icon: AppIcons.chalkboard,
              label: 'New Class',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditClassScreen(
                      classTemplate: null,
                      subjectId: viewModel.subjectId,
                      termId: viewModel.termId,
                    ),
                  ),
                );
                if (result == true) {
                  viewModel.refreshSubject();
                }
              },
            ),
            FabOption(
              icon: AppIcons.exam,
              label: 'New Exam',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditExamScreen(
                      exam: null,
                      subjectId: viewModel.subjectId,
                      termId: viewModel.termId,
                    ),
                  ),
                );
                if (result == true) {
                  viewModel.refreshSubject();
                }
              },
            ),
          ],
        );

      case SubjectTab.grades:
        // Hide FAB on grades tab
        return null;
    }
  }

  Widget _buildTimetableTab(BuildContext context, SubjectViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;
    final subjectColor = viewModel.subject != null
        ? Color(int.parse('0xFF${viewModel.subject!.color.substring(1)}'))
        : colors.primary;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Counter
          ContentCounter(
            firstItem: CounterItem(
              title: 'Classes left: ',
              value: '${viewModel.classesLeft}',
            ),
            secondItem: CounterItem(
              title: 'Exams left: ',
              value: '${viewModel.examsLeft}',
            ),
          ),
          const SizedBox(height: 20),

          // Classes Section
          Text(
            'Classes',
            style: AppTypography.h4.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 12),

          ...viewModel.classTemplates.map((classTemplate) => _buildClassItem(
            context,
            classTemplate,
            subjectColor,
            colors,
          )),

          const SizedBox(height: 24),

          // Exams Section
          Text(
            'Exams',
            style: AppTypography.h4.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 12),

          ...viewModel.exams.map((exam) => _buildExamItem(
            context,
            exam,
            subjectColor,
            colors,
          )),
        ],
      ),
    );
  }

  Widget _buildClassItem(
    BuildContext context,
    ClassTemplate classTemplate,
    Color subjectColor,
    ColorScheme colors,
  ) {
    final dayAbbreviations = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored circle
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: subjectColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time range
                Text(
                  '${classTemplate.startTime} - ${classTemplate.endTime}',
                  style: AppTypography.bodyM.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Days
                Text(
                  classTemplate.recurrence.selectedDays.map((day) {
                    // day is 0-6 where 0=Sunday, adjust to get correct abbreviation
                    final index = day == 0 ? 6 : day - 1; // Convert Sunday from 0 to 6
                    return dayAbbreviations[index];
                  }).join('  '),
                  style: AppTypography.bodyS.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamItem(
    BuildContext context,
    Exam exam,
    Color subjectColor,
    ColorScheme colors,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored circle
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: subjectColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time range
                Text(
                  '${exam.startTime} - ${exam.endTime}',
                  style: AppTypography.bodyM.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Date
                Text(
                  dateFormat.format(exam.date),
                  style: AppTypography.bodyS.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsTab(BuildContext context, SubjectViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;

    if (viewModel.subjectAssignments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.assignments,
                size: 64,
                color: colors.onPrimaryContainer,
              ),
              const SizedBox(height: 16),
              Text(
                'No assignments yet',
                style: AppTypography.h4.copyWith(color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Add an assignment to get started',
                style: AppTypography.bodyM.copyWith(
                  color: colors.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Separate pending and completed assignments
    final pending = viewModel.subjectAssignments
        .where((a) => !a.isCompleted)
        .toList();
    final completed = viewModel.subjectAssignments
        .where((a) => a.isCompleted)
        .toList();

    // Sort both lists by due date (closest to today first)
    final today = DateTime.now();
    pending.sort((a, b) {
      final aDiff = (a.dueDate.difference(today).inDays).abs();
      final bDiff = (b.dueDate.difference(today).inDays).abs();
      return aDiff.compareTo(bDiff);
    });
    completed.sort((a, b) {
      final aDiff = (a.dueDate.difference(today).inDays).abs();
      final bDiff = (b.dueDate.difference(today).inDays).abs();
      return aDiff.compareTo(bDiff);
    });

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshAssignments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pending.length + completed.length,
        itemBuilder: (context, index) {
          final assignment = index < pending.length
              ? pending[index]
              : completed[index - pending.length];
          return _buildAssignmentCard(context, assignment, viewModel);
        },
      ),
    );
  }

  Widget _buildAssignmentCard(
      BuildContext context,
      dynamic assignment,
      SubjectViewModel viewModel,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    IconData priorityIcon = AppIcons.priority;
    Color priorityColor;
    switch (assignment.priority) {
      case 'High':
        priorityColor = AppColors.errorMedium;
        break;
      case 'Low':
        priorityColor = AppColors.successMedium;
        break;
      default: // Medium
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
      if (assignment.isCompleted) {
        dueDateText = DateFormat('MMM d, yyyy').format(assignment.dueDate);
      } else {
        dueDateText = difference == 1
            ? 'Overdue by 1 day'
            : 'Overdue by $difference days';
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

    return InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditAssignmentScreen(assignment: assignment),
          ),
        );
        if (result == true) {
          viewModel.refreshAssignments();
        }
      },
      child: Card(
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
                      assignment.subjectName ?? 'Unknown Subject',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dueDateText,
                    style: AppTypography.bodyS.copyWith(
                      color: dueDate.isBefore(today) && !assignment.isCompleted
                          ? colors.error
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
      ),
    );
  }

  Widget _buildGradesTab(BuildContext context, SubjectViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContentCounter(
            firstItem: CounterItem(
              title: 'Current Grade: ',
              value: null,
            ),
            secondItem: CounterItem(
              title: null,
              value: viewModel.currentGrade.toStringAsFixed(2),
            ),
          ),

          // Use Grades Toggle
          _buildUseGradesToggle(context, viewModel, colors),
          const SizedBox(height: 16),

          // Final Subject Grade
          _buildFinalGradeSection(context, viewModel, colors),
          const SizedBox(height: 16),

          // Weights Section
          _buildWeightsSection(context, viewModel, colors),
          const SizedBox(height: 16),

          // Credits Section
          _buildCreditsSection(context, viewModel, colors),
        ],
      ),
    );
  }

  Widget _buildUseGradesToggle(BuildContext context, SubjectViewModel viewModel, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Use Grades',
            style: AppTypography.bodyL.copyWith(color: colors.onSurface),
          ),
          Switch(
            value: viewModel.useGrades,
            onChanged: (value) => viewModel.toggleUseGrades(),
            activeTrackColor: colors.primary,
            activeColor: colors.onPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalGradeSection(BuildContext context, SubjectViewModel viewModel, ColorScheme colors) {
    return Opacity(
      opacity: viewModel.useGrades ? 1.0 : 0.5,
      child: AbsorbPointer(
        absorbing: !viewModel.useGrades,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceDim,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: viewModel.finalSubjectGrade != null,
                    onChanged: (value) => viewModel.toggleFinalGradeOverride(),
                    activeColor: colors.primary,
                    checkColor: colors.onPrimary,
                  ),
                  Text(
                    'Final Subject Grade',
                    style: AppTypography.bodyL.copyWith(color: colors.onSurface),
                  ),
                ],
              ),
              if (viewModel.finalSubjectGrade != null) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: viewModel.finalGradeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTypography.bodyM.copyWith(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Enter final grade',
                    hintStyle: AppTypography.bodyM.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => viewModel.updateFinalGrade(value),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightsSection(BuildContext context, SubjectViewModel viewModel, ColorScheme colors) {
    return Opacity(
      opacity: viewModel.useGrades ? 1.0 : 0.5,
      child: AbsorbPointer(
        absorbing: !viewModel.useGrades,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceDim,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weights',
                    style: AppTypography.bodyL.copyWith(color: colors.onSurface),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.edit, color: colors.primary, size: 20),
                    onPressed: viewModel.useGrades
                        ? () => _showWeightsDialog(context, viewModel)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (viewModel.weightsList.isEmpty)
                Text(
                  'No weights defined',
                  style: AppTypography.bodyS.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                )
              else
                ...viewModel.weightsList.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: AppTypography.bodyM.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          '${entry.value}%',
                          style: AppTypography.bodyM.copyWith(
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditsSection(BuildContext context, SubjectViewModel viewModel, ColorScheme colors) {
    return Opacity(
      opacity: viewModel.useGrades ? 1.0 : 0.5,
      child: AbsorbPointer(
        absorbing: !viewModel.useGrades,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceDim,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Credits',
                style: AppTypography.bodyL.copyWith(color: colors.onSurface),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: viewModel.creditsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  style: AppTypography.bodyM.copyWith(color: colors.onSurface),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => viewModel.updateCredits(value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeightsDialog(BuildContext context, SubjectViewModel viewModel) {
    // This would open a dialog to manage weights
    // For now, show a simple snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weight management coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}