import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/assignments/assignment_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/assignments/edit_assignment_viewmodel.dart';
import '../../data/repositories/academic_repository.dart';
import '../../widgets/date_time_pickers.dart';
import '../../widgets/form_field.dart';
import '../../widgets/dropdown_field.dart';
import '../../widgets/top_bar.dart';

class EditAssignmentScreen extends StatelessWidget {
  final Assignment? assignment;
  final String? subjectId;
  final String? termId;

  const EditAssignmentScreen({
    super.key,
    this.assignment,
    this.subjectId,
    this.termId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditAssignmentViewModel(
        repository: context.read<AcademicRepository>(),
        assignmentId: assignment?.id,
        subjectId: subjectId,
        termId: termId,
      ),
      child: const _EditAssignmentScreenContent(),
    );
  }
}

class _EditAssignmentScreenContent extends StatelessWidget {
  const _EditAssignmentScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditAssignmentViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: TopBar(
        title: viewModel.isEditMode ? 'Edit Assignment' : 'New Assignment',
        leftControlType: LeftControlType.cancel,
        rightControlType: RightControlType.save,
        onRightPressed: () => _saveAssignment(context, viewModel),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject Dropdown
            if (viewModel.subjects.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Loading subjects...',
                  style: AppTypography.bodyM.copyWith(color: colors.onSurface),
                ),
              )
            else
              AppDropdownField<String>(
                value: viewModel.selectedSubject,
                items: viewModel.subjects.map((s) => s.name).toList(),
                getLabel: (subject) => subject,
                onChanged: (value) => viewModel.setSubject(value),
              ),
            const SizedBox(height: 16),

            // Title Field with completion checkbox
            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    controller: viewModel.titleController,
                    hint: 'Title',
                    type: FormFieldType.text,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: viewModel.isCompleted,
                      onChanged: (value) => viewModel.toggleCompleted(),
                      activeColor: colors.primary,
                      checkColor: colors.onPrimary,
                      side: BorderSide(color: colors.primary, width: 2),
                    ),
                    Text(
                      'Done',
                      style: AppTypography.actionS.copyWith(color: colors.outline)
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description Field
            AppFormField(
              controller: viewModel.descriptionController,
              hint: 'Description',
              type: FormFieldType.multiline,
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Icon(
                  AppIcons.calendarDay,
                  size: 18,
                  color: colors.outline,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DatePickerField(
                    label: 'Due date',
                    selectedDate: viewModel.selectedDueDate,
                    onDateSelected: (date) => viewModel.setDueDate(date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TimePickerField(
                    label: 'Time',
                    selectedTime: viewModel.selectedDueTime,
                    onTimeSelected: (time) => viewModel.setDueTime(time),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reminder Row (only show if not completed)
            if (!viewModel.isCompleted) ...[
              Row(
                children: [
                  Icon(
                    AppIcons.notification,
                    size: 18,
                    color: colors.outline,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DatePickerField(
                      label: 'Reminder',
                      selectedDate: viewModel.selectedDueDate,
                      onDateSelected: (date) => viewModel.setDueDate(date),
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TimePickerField(
                      label: 'Time',
                      selectedTime: viewModel.selectedReminderTime,
                      onTimeSelected: (time) => viewModel.setDueTime(time),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Weight and Priority Row
            Row(
              children: [
                Icon(
                  AppIcons.weight,
                  size: 18,
                  color: colors.outline,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: viewModel.weightOptions.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.outline),
                          ),
                          child: Text(
                            'No weights',
                            style: AppTypography.bodyM.copyWith(color: colors.onSurfaceVariant),
                          ),
                        )
                      : AppDropdownField<String>(
                          label: 'Weight',
                          value: viewModel.selectedWeightDisplayName,
                          items: viewModel.weightOptions.map((w) => w.displayName).toList(),
                          getLabel: (weight) => weight,
                          onChanged: (value) => viewModel.setWeightByDisplayName(value),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'Priority',
                    value: viewModel.selectedPriority,
                    items: viewModel.priorities,
                    getLabel: (priority) => priority,
                    onChanged: (value) {
                      if (value != null) viewModel.setPriority(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Icon(
                  AppIcons.grade,
                  size: 18,
                  color: viewModel.isCompleted ? colors.outline : colors.shadow,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AppFormField(
                    controller: viewModel.gradeController,
                    hint: 'Grade',
                    type: FormFieldType.number,
                    enabled: viewModel.isCompleted,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: viewModel.isGraded,
                      onChanged: viewModel.isCompleted ? (value) {
                        viewModel.toggleGraded();
                      } : null,
                      activeColor: colors.primary,
                      checkColor: colors.onPrimary,
                      side: BorderSide(
                        color: viewModel.isCompleted ? colors.primary : colors.shadow,
                        width: 2,
                      ),
                    ),
                    Text(
                      'Graded',
                      style: AppTypography.actionS.copyWith(color: colors.outline)
                    ),
                  ],
                ),
              ],
            ),

            // Error Message
            if (viewModel.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.error, color: colors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.errorMessage!,
                        style: AppTypography.bodyM.copyWith(color: colors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Validation hint for create mode
            if (viewModel.isCreateMode && !viewModel.canSave) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningMedium.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.priority, color: AppColors.warningMedium),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.validationMessage,
                        style: AppTypography.bodyS.copyWith(color: AppColors.warningMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveAssignment(
      BuildContext context, EditAssignmentViewModel viewModel) async {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final success = await viewModel.saveAssignment();

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to save assignment'),
        ),
      );
    }
  }
}