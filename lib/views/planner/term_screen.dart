import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/grades/gpa_calculation_service.dart';
import '../../viewmodels/planner/term_viewmodel.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_icons.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/content_counter.dart';
import '../../widgets/deletable_list_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/top_bar.dart';
import '../../core/constants/enums.dart';
import 'subject_screen.dart';
import 'edit_subject_screen.dart';
import 'edit_term_screen.dart';

class TermScreen extends StatelessWidget {
  final String termId;

  const TermScreen({super.key, required this.termId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TermViewModel(
        termId: termId,
        repository: context.read<AcademicRepository>(),
        gpaService: context.read<GpaCalculationService>(),
        ),
      child: _TermScreenContent(termId: termId),
    );
  }
}

class _TermScreenContent extends StatelessWidget {
  final String termId;
  
  const _TermScreenContent({required this.termId});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TermViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: BurgerMenu(),
      appBar: TopBar(
        title: 'Planner',
        rightControlType: RightControlType.edit,
        onRightPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditTermScreen(termId: termId),
            ),
          );
          if (result == true) {
            viewModel.refreshTerm();
          }
        },
      ),
      body: _buildBody(context, viewModel, colors),
      floatingActionButton: FAB(
        options: [
          FabOption(
            icon: AppIcons.add,
            label: 'Add Subject',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditSubjectScreen(termId: termId),
                ),
              );
              if (result == true) {
                viewModel.refreshTerm();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, TermViewModel viewModel, ColorScheme colors) {
    if (viewModel.state == ViewState.loading) {
      return Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    if (viewModel.state == ViewState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.error, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage ?? 'An error occurred',
                style: AppTypography.bodyM.copyWith(color: colors.onSurface),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.subjects.isEmpty) {
      return EmptyState(
        message: 'No subjects for this term yet',
        subtitle: 'Tap the + button to add one!',
        icon: AppIcons.assignments,
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshTerm(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            color: colors.tertiary,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(AppIcons.arrowLeft, size: 20),
                  color: colors.onTertiary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    viewModel.term?.name ?? 'Term',
                    style: AppTypography.h4.copyWith(
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          ContentCounter(
            firstItem: CounterItem(
              title: 'Term GPA: ',
              value: viewModel.termGPA?.toStringAsFixed(2) ?? '0.00',
            ),
            secondItem: CounterItem(
              title: 'Term Credits: ',
              value: '${viewModel.termCredits}',
            ),
          ),
          _buildSubjectsSection(context, viewModel, colors),
        ],
      ),
    );
  }

  Widget _buildSubjectsSection(BuildContext context, TermViewModel viewModel, ColorScheme colors) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Subjects',
              style: AppTypography.h3.copyWith(color: colors.onSurface),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.subjects.length,
              itemBuilder: (context, index) {
                final subject = viewModel.subjects[index];
                return DeletableListItem(
                  itemType: 'Subject',
                  itemName: subject.name,
                  onDelete: () => viewModel.deleteSubject(subject.id),
                  child: _buildSubjectCard(context, subject, viewModel),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, subject, TermViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;
    final credits = subject.credits;
    final subjectColor = Color(int.parse('0xFF${subject.color.substring(1)}'));

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectScreen(
              subjectId: subject.id,
              termId: viewModel.termId,
            ),
          ),
        );
        if (result == true) {
          viewModel.refreshSubjects();
        }
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // Colored vertical line on the left
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: subjectColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: AppTypography.h4.copyWith(color: colors.onSurface),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<double?>(
                            future: viewModel.getSubjectGrade(subject.id),
                            builder: (context, snapshot) {
                              final grade = snapshot.data;
                              return Text(
                                'Credits: $credits, Grade: ${grade?.toStringAsFixed(2) ?? '0.00'}',
                                style: AppTypography.bodyS.copyWith(
                                  color: colors.onPrimaryContainer,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(AppIcons.arrowRight, color: colors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}