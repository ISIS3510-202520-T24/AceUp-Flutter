import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/planner/edit_term_viewmodel.dart';
import '../../data/repositories/academic_repository.dart';
import '../../themes/app_typography.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/form_field.dart';

class EditTermScreen extends StatelessWidget {
  final String? termId;

  const EditTermScreen({super.key, this.termId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditTermViewModel(
        termId: termId,
        repository: context.read<AcademicRepository>(),
      ),
      child: const _EditTermScreenContent(),
    );
  }
}

class _EditTermScreenContent extends StatelessWidget {
  const _EditTermScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditTermViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: TopBar(
        title: viewModel.isEditMode ? 'Edit Term' : 'New Term',
        leftControlType: LeftControlType.cancel,
        rightControlType: RightControlType.save,
        onRightPressed: () => _saveTerm(context, viewModel),
      ),
      body: viewModel.state == EditTermViewState.loading
          ? Center(
              child: CircularProgressIndicator(color: colors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFormField(
                    controller: viewModel.nameController,
                    hint: 'Term Name',
                  ),
                  const SizedBox(height: 24),
                  _buildDateSection(
                    context,
                    label: 'Start Date',
                    date: viewModel.startDate,
                    onTap: () => _selectStartDate(context, viewModel),
                    colors: colors,
                  ),
                  const SizedBox(height: 16),
                  _buildDateSection(
                    context,
                    label: 'End Date',
                    date: viewModel.endDate,
                    onTap: () => _selectEndDate(context, viewModel),
                    colors: colors,
                  ),
                  const SizedBox(height: 32),
                  if (viewModel.state == EditTermViewState.saving)
                    Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    ),
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        viewModel.errorMessage!,
                        style: AppTypography.bodyM.copyWith(color: colors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDateSection(
    BuildContext context, {
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required ColorScheme colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyM.copyWith(color: colors.onSurface),
            ),
            Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: AppTypography.bodyM.copyWith(color: colors.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(
      BuildContext context, EditTermViewModel viewModel) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      viewModel.setStartDate(picked);
    }
  }

  Future<void> _selectEndDate(
      BuildContext context, EditTermViewModel viewModel) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.endDate,
      firstDate: viewModel.startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      viewModel.setEndDate(picked);
    }
  }

  Future<void> _saveTerm(
      BuildContext context, EditTermViewModel viewModel) async {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final success = await viewModel.saveTerm();

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to save term'),
        ),
      );
    }
  }
}