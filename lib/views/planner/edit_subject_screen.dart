import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/academic_repository.dart';
import '../../models/planner/subject_model.dart';
import '../../viewmodels/planner/edit_subject_viewmodel.dart';
import '../../themes/app_typography.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/form_field.dart';
import '../../core/constants/enums.dart';

class EditSubjectScreen extends StatelessWidget {
  final Subject? subject;
  final String termId;

const EditSubjectScreen({
  super.key,
  this.subject,
  required this.termId
});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditSubjectViewModel(
        repository: context.read<AcademicRepository>(),
        subjectId: subject?.id,
        termId: termId,
      ),
      child: const _EditSubjectScreenContent(),
    );
  }
}

class _EditSubjectScreenContent extends StatelessWidget {
  const _EditSubjectScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditSubjectViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: TopBar(
        title: viewModel.isEditMode ? 'Edit Subject' : 'New Subject',
        leftControlType: LeftControlType.cancel,
        rightControlType: RightControlType.save,
        onRightPressed: () => _saveSubject(context, viewModel),
      ),
      body: viewModel.state == EditViewState.loading
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
              hint: 'Subject Name',
            ),
            const SizedBox(height: 24),
            Text(
              'Color',
              style: AppTypography.bodyL.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 12),
            _buildColorPicker(context, viewModel, colors),
            const SizedBox(height: 32),
            if (viewModel.state == EditViewState.saving)
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

  Widget _buildColorPicker(BuildContext context, EditSubjectViewModel viewModel, ColorScheme colors) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: viewModel.colorOptions.map((colorHex) {
        final color = Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
        final isSelected = viewModel.selectedColor == colorHex;

        return GestureDetector(
          onTap: () => viewModel.setColor(colorHex),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colors.primary : colors.outline,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _saveSubject(
      BuildContext context, EditSubjectViewModel viewModel) async {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subject name')),
      );
      return;
    }

    final success = await viewModel.saveSubject();

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