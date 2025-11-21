import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/planner/edit_term_viewmodel.dart';
import '../../themes/app_typography.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/form_field.dart';

class EditTermScreen extends StatelessWidget {
  final String? termId;

  const EditTermScreen({super.key, this.termId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditTermViewModel(termId: termId),
      child: const _EditTermContent(),
    );
  }
}

class _EditTermContent extends StatelessWidget {
  const _EditTermContent();

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
                  style: AppTypography.bodyS.copyWith(color: colors.error),
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
              label,
              style: AppTypography.bodyM.copyWith(color: colors.onSurface),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: AppTypography.bodyM.copyWith(color: colors.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context, EditTermViewModel viewModel) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      viewModel.setStartDate(picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context, EditTermViewModel viewModel) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.endDate,
      firstDate: viewModel.startDate,
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      viewModel.setEndDate(picked);
    }
  }

  Future<void> _saveTerm(BuildContext context, EditTermViewModel viewModel) async {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final success = await viewModel.saveTerm();
    if (success && context.mounted) {
      Navigator.pop(context, true);
    }
  }
}