import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/enums.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../models/planner/exam_model.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/planner/edit_exam_viewmodel.dart';
import '../../widgets/date_time_pickers.dart';
import '../../widgets/dropdown_field.dart';
import '../../widgets/form_field.dart';
import '../../widgets/top_bar.dart';

class EditExamScreen extends StatelessWidget {
  final Exam? exam;
  final String? subjectId;
  final String? termId;

  const EditExamScreen({
    super.key,
    this.exam,
    this.subjectId,
    this.termId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditExamViewModel(
        academicRepo: context.read<AcademicRepository>(),
        teacherRepo: context.read<TeacherRepository>(),
        examId: exam?.id,
        subjectId: subjectId,
        termId: termId,
      ),
      child: const _EditExamScreenContent(),
    );
  }
}

class _EditExamScreenContent extends StatelessWidget {
  const _EditExamScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditExamViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: TopBar(
        title: viewModel.isCreateMode ? 'New Exam' : 'Edit Exam',
        leftControlType: LeftControlType.cancel,
        rightControlType: RightControlType.save,
        onRightPressed: () => _saveExam(context, viewModel),
      ),
      body: viewModel.state == EditViewState.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                onChanged: viewModel.setSubject,
              ),
            const SizedBox(height: 16),

            // Title Field with completion checkbox
            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    controller: viewModel.titleController,
                    hint: 'Exam',
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: AppTypography.h5.copyWith(
                    color: colors.onTertiary
                  ),
                ),
                const SizedBox(height: 4),
                DatePickerField(
                  label: 'Date',
                  selectedDate: viewModel.selectedDate,
                  onDateSelected: (date) => viewModel.setDate(date)
                ),
              ],
            ),

            const SizedBox(height: 16),

            // From and To time row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From',
                        style: AppTypography.h5.copyWith(
                          color: colors.onTertiary
                        ),
                      ),
                      const SizedBox(height: 4),
                      TimePickerField(
                        label: 'From',
                        selectedTime: viewModel.selectedStartTime,
                        onTimeSelected: (time) => viewModel.setStartTime(time)
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To',
                        style: AppTypography.h5.copyWith(
                          color: colors.onTertiary
                        ),
                      ),
                      const SizedBox(height: 4),
                      TimePickerField(
                        label: 'To',
                        selectedTime: viewModel.selectedEndTime,
                        onTimeSelected: (time) => viewModel.setEndTime(time)
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Column(
              children: [
                Text('Weight'),
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
                    value: viewModel.selectedWeightDisplayName,
                    items: viewModel.weightOptions.map((w) => w.displayName).toList(),
                    getLabel: (weight) => weight,
                    onChanged: (value) => viewModel.setWeightByDisplayName(value),
                  ),
                ),
              ],
            ),

            // Grade row
            Column(
              children: [
                Text(
                  'Grade',
                  style: AppTypography.h5.copyWith(
                    color: colors.onTertiary
                  ),
                ),
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
              ],
            ),

            const SizedBox(height: 16),

            // Building and Room row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Building',
                        style: AppTypography.h5.copyWith(
                          color: colors.onTertiary
                        ),
                      ),
                      const SizedBox(height: 4),
                      AppFormField(
                        controller: viewModel.buildingController,
                        hint: 'ML',
                        type: FormFieldType.text,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room',
                        style: AppTypography.h5.copyWith(
                          color: colors.onTertiary
                        ),
                      ),
                      const SizedBox(height: 4),
                      AppFormField(
                        controller: viewModel.roomController,
                        hint: '515',
                        type: FormFieldType.text,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Teachers dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teachers',
                  style: AppTypography.h5.copyWith(
                    color: colors.onTertiary
                  ),
                ),
                const SizedBox(height: 4),
                AppDropdownField<String?>(
                  value: viewModel.selectedTeacherName,
                  items: [null, ...viewModel.teachers.map((t) => t.name)],
                  getLabel: (name) => name ?? "Teacher's name",
                  onChanged: viewModel.setTeacher,
                ),
              ]
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
          ],
        ),
      ),
    );
  }

  Future<void> _saveExam(
      BuildContext context, EditExamViewModel viewModel) async {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final success = await viewModel.saveExam();

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to save exam'),
        ),
      );
    }
  }
}