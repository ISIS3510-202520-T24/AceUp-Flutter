import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/grades/gpa_calculation_service.dart';
import '../../viewmodels/planner/planner_viewmodel.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_icons.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/content_counter.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/top_bar.dart';
import '../../core/constants/enums.dart';
import 'term_screen.dart';
import 'edit_term_screen.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlannerViewModel(
        repository: context.read<AcademicRepository>(),
        gpaService: context.read<GpaCalculationService>(), 
      ),
      child: const _PlannerScreenContent(),
    );
  }
}

class _PlannerScreenContent extends StatelessWidget {
  const _PlannerScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlannerViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: const TopBar(
        title: 'Planner',
      ),
      body: _buildBody(context, viewModel, colors),
      floatingActionButton: FAB(
        options: [
          FabOption(
            icon: AppIcons.add,
            label: 'Add Term',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditTermScreen()),
              );
              if (result == true) {
                viewModel.refreshTerms();
              }
            },
          ),
        ]
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlannerViewModel viewModel, ColorScheme colors) {
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

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshTerms(),
      child: Column(
        children: [
          SizedBox(height: 16.0),
          ContentCounter(
            firstItem: CounterItem(
              title: 'Overall GPA: ',
              value: viewModel.overallGPA?.toStringAsFixed(2) ?? 'None',
            ),
            secondItem: CounterItem(
              title: 'Total Credits: ',
              value: '${viewModel.totalCredits}',
            ),
          ),
          _buildTermsSection(context, viewModel, colors),
        ],
      ),
    );
  }

  Widget _buildTermsSection(BuildContext context, PlannerViewModel viewModel, ColorScheme colors) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Terms',
              style: AppTypography.h3.copyWith(color: colors.onSurface),
            ),
          ),
          Expanded(
            child: viewModel.terms.isEmpty
                ? Center(
              child: Text(
                'No terms yet. Add one to get started!',
                style: AppTypography.bodyM.copyWith(color: colors.onSurfaceVariant),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: viewModel.terms.length,
              itemBuilder: (context, index) {
                final term = viewModel.terms[index];
                return _buildTermCard(context, term, viewModel, colors);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermCard(BuildContext context, term, PlannerViewModel viewModel, ColorScheme colors) {
    final dateRange = viewModel.getTermDateRange(term);
    final termGPA = viewModel.getTermGPA(term.id);
    final termCredits = viewModel.getTermCredits(term.id);

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TermScreen(termId: term.id),
          ),
        );
        if (result == true) {
          viewModel.refreshTerms();
        }
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      term.name,
                      style: AppTypography.h4.copyWith(color: colors.onSurface),
                    ),
                    if (dateRange.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        dateRange,
                        style: AppTypography.bodyS.copyWith(color: colors.onPrimaryContainer),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'GPA: ${termGPA?.toStringAsFixed(2) ?? '0.00'}',
                    style: AppTypography.bodyM.copyWith(color: colors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Credits: $termCredits',
                    style: AppTypography.bodyS.copyWith(color: colors.onPrimaryContainer),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(AppIcons.arrowRight, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}