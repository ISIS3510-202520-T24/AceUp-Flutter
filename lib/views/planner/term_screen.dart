import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/planner/term_viewmodel.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_icons.dart';
import '../../widgets/content_counter.dart';
import '../../widgets/top_bar.dart';
import 'subject_screen.dart';
import 'edit_subject_screen.dart';

class TermScreen extends StatelessWidget {
  final String termId;

  const TermScreen({super.key, required this.termId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TermViewModel(termId: termId),
      child: const _TermContent(),
    );
  }
}

class _TermContent extends StatelessWidget {
  const _TermContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TermViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: TopBar(
        title: viewModel.term?.name ?? 'Term',
        leftControlType: LeftControlType.back,
        rightControlType: RightControlType.edit,
        onRightPressed: () {
          // TODO: Navigate to edit term screen
        },
      ),
      body: _buildBody(context, viewModel, colors),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditSubjectScreen(termId: viewModel.termId),
            ),
          );
          if (result == true) {
            viewModel.refreshTerm();
          }
        },
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: colors.onPrimary),
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
              Icon(AppIcons.priority, size: 48, color: colors.error),
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

  Widget _buildGPASection(BuildContext context, TermViewModel viewModel, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            context,
            label: 'Term GPA',
            value: viewModel.termGPA?.toStringAsFixed(2) ?? '0.00',
            colors: colors,
          ),
          _buildStatItem(
            context,
            label: 'Term Credits',
            value: viewModel.termCredits.toString(),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required String label,
    required String value,
    required ColorScheme colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyM.copyWith(color: colors.onPrimaryContainer),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.h2.copyWith(color: colors.onSurface),
        ),
      ],
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
                style: AppTypography.bodyM.copyWith(color: colors.onSurfaceVariant),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: viewModel.subjects.length,
              itemBuilder: (context, index) {
                final subject = viewModel.subjects[index];
                return _buildSubjectCard(context, subject, viewModel, colors);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, subject, TermViewModel viewModel, ColorScheme colors) {
    // Parse color from hex string or use default
    Color subjectColor = colors.primary;
    try {
      if (subject.code != null) {
        // If there's a color stored, we'd parse it here
        // For now, using default colors based on index
      }
    } catch (e) {
      subjectColor = colors.primary;
    }

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
          viewModel.refreshTerm();
        }
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: subjectColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: AppTypography.h4.copyWith(color: colors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Credits: ${subject.credits}, Grade: 4.00',
                      style: AppTypography.bodyS.copyWith(color: colors.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}