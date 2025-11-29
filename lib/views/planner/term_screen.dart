import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/grades/gpa_calculation_service.dart';
import '../../viewmodels/planner/term_viewmodel.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_icons.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/content_counter.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/top_bar.dart';
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
      child: _TermContent(termId: termId),
    );
  }
}

class _TermContent extends StatelessWidget {
  final String termId;
  
  const _TermContent({required this.termId});

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
    if (viewModel.state == TermViewState.loading) {
      return Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    if (viewModel.state == TermViewState.error) {
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
            child: viewModel.subjects.isEmpty
                ? Center(
              child: Text(
                'No subjects yet. Add one to get started!',
                style: AppTypography.bodyM.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.subjects.length,
              itemBuilder: (context, index) {
                final subject = viewModel.subjects[index];
                return _buildSubjectCard(context, subject, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, subject, TermViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;
    final grade = viewModel.getSubjectGrade(subject.id);
    final credits = subject.credits;

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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.name,
                style: AppTypography.h4.copyWith(color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                '${subject.credits} credits',
                style: AppTypography.bodyS.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}