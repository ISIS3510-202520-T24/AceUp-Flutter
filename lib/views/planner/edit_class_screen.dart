import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/enums.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../models/planner/class_template_model.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/planner/edit_class_viewmodel.dart';
import '../../widgets/date_time_pickers.dart';
import '../../widgets/dropdown_field.dart';
import '../../widgets/form_field.dart';
import '../../widgets/top_bar.dart';

class EditClassScreen extends StatelessWidget {
  final ClassTemplate? classTemplate;
  final String? subjectId;
  final String? termId;

  const EditClassScreen({
    super.key,
    this.classTemplate,
    this.subjectId,
    this.termId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditClassViewModel(
        academicRepo: context.read<AcademicRepository>(),
        teacherRepo: context.read<TeacherRepository>(),
        classTemplateId: classTemplate?.id,
        subjectId: subjectId,
        termId: termId,
      ),
      child: const _EditClassScreenContent(),
    );
  }
}

class _EditClassScreenContent extends StatelessWidget {
  const _EditClassScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditClassViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: TopBar(
        title: viewModel.isCreateMode ? 'New Class' : 'Edit Class',
        leftControlType: LeftControlType.cancel,
        rightControlType: RightControlType.save,
        onRightPressed: () => _saveClassTemplate(context, viewModel),
      ),
      body: viewModel.state == EditViewState.loading
            ? const Center(child: CircularProgressIndicator())
    : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject dropdown
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
                getLabel: (name) => name,
                onChanged: viewModel.setSubject,
              ),

            const SizedBox(height: 16),

            // Icon and name row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon selector
                GestureDetector(
                  onTap: () => _showIconPicker(context, viewModel),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      viewModel.selectedIcon,
                      color: colors.onPrimary,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Name text field
                Expanded(
                  child: AppFormField(
                    controller: viewModel.nameController,
                    hint: 'Name',
                    type: FormFieldType.text,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Start Date and End Date row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: AppTypography.h5.copyWith(
                          color: colors.onTertiary
                        ),
                      ),
                      const SizedBox(height: 4),
                      DatePickerField(
                        label: 'Start Date',
                        selectedDate: viewModel.startDate,
                        onDateSelected: (date) => viewModel.setStartDate(date)
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
                        'End Date',
                        style: AppTypography.h5.copyWith(
                          color: colors.onTertiary
                        ),
                      ),
                      const SizedBox(height: 4),
                      DatePickerField(
                        label: 'End Date',
                        selectedDate: viewModel.endDate,
                        onDateSelected: (date) => viewModel.setEndDate(date)
                      ),
                    ],
                  ),
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
                        selectedTime: viewModel.startTime,
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
                        selectedTime: viewModel.endTime,
                        onTimeSelected: (time) => viewModel.setEndTime(time)
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Repeats Every section
            Text(
              'Repeats Every',
              style: AppTypography.h5.copyWith(
                color: colors.onTertiary
              ),
            ),
            const SizedBox(height: 8),

            // Interval and unit row
            Row(
              children: [
                // Interval number selector
                _buildIntervalSelector(context, viewModel, colors),

                const SizedBox(width: 12),

                // Unit dropdown
                Expanded(
                  child: AppDropdownField<String>(
                    value: EditClassViewModel.recurrenceUnitOptions
                        .firstWhere((u) => u.unit == viewModel.recurrenceUnit)
                        .label,
                    items: EditClassViewModel.recurrenceUnitOptions
                        .map((u) => u.label)
                        .toList(),
                    getLabel: (label) => label,
                    onChanged: (value) {
                      if (value != null) {
                        final option = EditClassViewModel.recurrenceUnitOptions
                            .firstWhere((u) => u.label == value);
                        viewModel.setRecurrenceUnit(option.unit);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Day selector (only visible for weeks)
            if (viewModel.recurrenceUnit == RecurrenceUnit.weeks) ...[
              _buildDaySelector(context, viewModel, colors),
              const SizedBox(height: 16),
            ],

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
            
            const SizedBox(height: 16),

                  // Image URL field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image URL (optional)',
                        style: AppTypography.bodyS.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: viewModel.imageUrlController,
                        decoration: InputDecoration(
                          hintText: 'https://example.com/image.jpg',
                          hintStyle: AppTypography.bodyM.copyWith(
                            color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),

            
            const SizedBox(height: 16),

            // Error message
            if (viewModel.state == EditViewState.error &&
                viewModel.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.error, color: colors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viewModel.errorMessage!,
                      style: AppTypography.bodyS.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSelector(
    BuildContext context,
    EditClassViewModel viewModel,
    ColorScheme colors,
  ) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${viewModel.recurrenceInterval}',
            style: AppTypography.bodyM.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  if (viewModel.recurrenceInterval < 6) {
                    viewModel.setRecurrenceInterval(viewModel.recurrenceInterval + 1);
                  }
                },
                child: Icon(
                  Icons.arrow_drop_up,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (viewModel.recurrenceInterval > 1) {
                    viewModel.setRecurrenceInterval(viewModel.recurrenceInterval - 1);
                  }
                },
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(
    BuildContext context,
    EditClassViewModel viewModel,
    ColorScheme colors,
  ) {
    final days = [
      {'day': 1, 'label': 'MON'},
      {'day': 2, 'label': 'TUE'},
      {'day': 3, 'label': 'WED'},
      {'day': 4, 'label': 'THU'},
      {'day': 5, 'label': 'FRI'},
      {'day': 6, 'label': 'SAT'},
      {'day': 0, 'label': 'SUN'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((dayData) {
        final day = dayData['day'] as int;
        final label = dayData['label'] as String;
        final isSelected = viewModel.isDaySelected(day);

        return GestureDetector(
          onTap: () => viewModel.toggleDay(day),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? colors.primary : colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                label,
                style: AppTypography.bodyS.copyWith(
                  color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showIconPicker(BuildContext context, EditClassViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Icon',
                  style: AppTypography.h5.copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: EditClassViewModel.classIcons.length,
                    itemBuilder: (c, i) {
                      final iconOption = EditClassViewModel.classIcons[i];
                      final isSelected = viewModel.selectedIconName == iconOption.name;

                      return GestureDetector(
                        onTap: () {
                          viewModel.setIcon(iconOption.name);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary
                                : colors.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            iconOption.icon,
                            color: isSelected
                                ? colors.onPrimary
                                : colors.onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveClassTemplate(
    BuildContext context,
    EditClassViewModel viewModel,
  ) async {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final success = await viewModel.saveClassTemplate();

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to save class'),
        ),
      );
    }
  }
}
