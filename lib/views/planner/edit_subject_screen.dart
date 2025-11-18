import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/planner/edit_subject_viewmodel.dart';
import '../../themes/app_typography.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/form_field.dart';

class EditSubjectScreen extends StatelessWidget {
  final String termId;
  final String? subjectId;

  const EditSubjectScreen({
    super.key,
    required this.termId,
    this.subjectId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditSubjectViewModel(termId: termId),
      child: const _EditSubjectContent(),
    );
  }
}

class _EditSubjectContent extends StatelessWidget {
  const _EditSubjectContent();

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormField(
              controller: viewModel.nameController,
              hint: 'Subject Name',
            ),
            const SizedBox(height: 24),
            _buildColorSection(context, viewModel, colors),
            const SizedBox(height: 32),
            if (viewModel.state == EditSubjectViewState.saving)
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

  Widget _buildColorSection(BuildContext context, EditSubjectViewModel viewModel, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: AppTypography.h4.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: viewModel.colorOptions.map((colorHex) {
            final isSelected = viewModel.selectedColor == colorHex;
            final color = _parseColor(colorHex);

            return GestureDetector(
              onTap: () => viewModel.setColor(colorHex),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? colors.onSurface : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? Icon(
                  Icons.check,
                  color: _getContrastColor(color),
                  size: 24,
                )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  Color _getContrastColor(Color color) {
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Future<void> _saveSubject(BuildContext context, EditSubjectViewModel viewModel) async {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subject name')),
      );
      return;
    }

    final success = await viewModel.saveSubject();
    if (success && context.mounted) {
      Navigator.pop(context, true);
    }
  }
}