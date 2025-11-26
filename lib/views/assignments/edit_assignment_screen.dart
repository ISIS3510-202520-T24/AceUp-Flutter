import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/assignments/assignment_model.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/assignments/edit_assignment_viewmodel.dart';
import '../../data/repositories/academic_repository.dart';
import '../../widgets/form_field.dart';
import '../../widgets/dropdown_field.dart';
import '../../widgets/top_bar.dart';

class EditAssignmentScreen extends StatelessWidget {
  final Assignment? assignment;

  const EditAssignmentScreen({super.key, this.assignment});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditAssignmentViewModel(
        repository: context.read<AcademicRepository>(),
        assignment: assignment,
      ),
      child: const _EditAssignmentContent(),
    );
  }
}

class _EditAssignmentContent extends StatelessWidget {
  const _EditAssignmentContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditAssignmentViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: TopBar(
        title: 'Assignment',
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
                if (viewModel.isEditMode) ...[
                  const SizedBox(width: 8),
                  Checkbox(
                    value: viewModel.isCompleted,
                    onChanged: (value) => viewModel.toggleAssignmentStatus(),
                    activeColor: colors.primary,
                    checkColor: colors.onPrimary,
                    side: BorderSide(color: colors.primary, width: 2),
                  ),
                ],
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
                Expanded(
                  child: _DatePickerField(
                    label: 'Due date',
                    date: viewModel.selectedDueDate,
                    onTap: () => _selectDueDate(context, viewModel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimePickerField(
                    label: 'Time',
                    time: viewModel.selectedDueTime,
                    onTap: () => _selectDueTime(context, viewModel),
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
                  Expanded(
                    child: _DatePickerField(
                      label: 'Reminder',
                      date: viewModel.selectedReminderDate,
                      onTap: () => _selectReminderDate(context, viewModel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePickerField(
                      label: 'Time',
                      time: viewModel.selectedReminderTime,
                      onTap: () => _selectReminderTime(context, viewModel),
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
                Expanded(
                  child: AppDropdownField<String>(
                    value: viewModel.selectedWeightDisplayName ,
                    items: viewModel.weightOptions.map((w) => w.displayName).toList(),
                    getLabel: (weight) => '$weight%',
                    onChanged: (value) => viewModel.setWeightByDisplayName(value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdownField<String>(
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
                  color: colors.outline,
                ),
                Expanded(
                  child: AppFormField(
                    controller: viewModel.gradeController,
                    label: 'Grade',
                    hint: 'Enter grade',
                    type: FormFieldType.number,
                    enabled: viewModel.isCompleted,
                  ),
                ),
                const SizedBox(width: 8),

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
                    Icon(Icons.error_outline, color: colors.error),
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
                  color: colors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.priority, color: colors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.errorMessage!,
                        style: AppTypography.bodyS.copyWith(color: colors.secondary),
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

  Future<void> _selectDueDate(
      BuildContext context, EditAssignmentViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      viewModel.setDueDate(picked);
    }
  }

  Future<void> _selectDueTime(
      BuildContext context, EditAssignmentViewModel viewModel) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: viewModel.selectedDueTime,
    );
    if (picked != null) {
      viewModel.setDueTime(picked);
    }
  }

  Future<void> _selectReminderDate(BuildContext context, EditAssignmentViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedReminderDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      viewModel.setReminderDate(picked);
    }
  }

  Future<void> _selectReminderTime(BuildContext context, EditAssignmentViewModel viewModel) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: viewModel.selectedReminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      viewModel.setReminderTime(picked);
    }
  }

  Future<void> _saveAssignment(BuildContext context, EditAssignmentViewModel viewModel) async {
    final success = await viewModel.saveAssignment();
    if (success && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

// Custom Date Picker Field Widget
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateText = date != null ? DateFormat('MMM d, yyyy').format(date!) : label;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateText,
              style: AppTypography.bodyM.copyWith(
                color: date != null ? colors.onSurface : colors.secondary,
              ),
            ),
            Icon(
              AppIcons.calendarDay,
              size: 18,
              color: colors.outline,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Time Picker Field Widget
class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimePickerField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final timeText = time != null ? time!.format(context) : label;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeText,
              style: AppTypography.bodyM.copyWith(
                color: time != null ? colors.onSurface : colors.secondary,
              ),
            ),
            Icon(
              AppIcons.clock,
              size: 18,
              color: colors.outline,
            ),
          ],
        ),
      ),
    );
  }
}