import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/enums.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../models/holidays/holiday_model.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/holidays/edit_holiday_viewmodel.dart';
import '../../widgets/form_field.dart';
import '../../widgets/top_bar.dart';

class EditHolidayScreen extends StatelessWidget {
  final Holiday? holiday;

  const EditHolidayScreen({
    super.key,
    this.holiday,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditHolidayViewModel(
        repository: context.read<HolidayRepository>(),
        holidayId: holiday?.id,
      ),
      child: const _EditHolidayScreenContent(),
    );
  }
}

class _EditHolidayScreenContent extends StatelessWidget {
  const _EditHolidayScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditHolidayViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: TopBar(
        title: viewModel.isEditMode ? 'Edit Holiday' : 'New Holiday',
        leftControlType: LeftControlType.cancel,
        rightControlType: RightControlType.save,
        onRightPressed: () => _saveHoliday(context, viewModel),
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
                  // Show warning if trying to edit API holiday
                  if (viewModel.isEditMode && !viewModel.canEdit) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: colors.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'API holidays cannot be edited',
                              style: AppTypography.bodyM.copyWith(
                                color: colors.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Holiday name
                  AppFormField(
                    controller: viewModel.nameController,
                    hint: 'Holiday Name',
                    enabled: viewModel.canEdit,
                  ),
                  const SizedBox(height: 24),

                  // Start date
                  _buildDateSection(
                    context,
                    label: 'Start Date',
                    date: viewModel.startDate,
                    onTap: viewModel.canEdit
                        ? () => _selectStartDate(context, viewModel)
                        : null,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),

                  // End date
                  _buildDateSection(
                    context,
                    label: 'End Date',
                    date: viewModel.endDate,
                    onTap: viewModel.canEdit
                        ? () => _selectEndDate(context, viewModel)
                        : null,
                    colors: colors,
                  ),
                  const SizedBox(height: 32),

                  // Saving indicator
                  if (viewModel.state == EditViewState.saving)
                    Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    ),

                  // Error message
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
    required VoidCallback? onTap,
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
          color: onTap == null ? colors.surfaceContainerHighest : null,
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
              style: AppTypography.bodyM.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(
      BuildContext context, EditHolidayViewModel viewModel) async {
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
      BuildContext context, EditHolidayViewModel viewModel) async {
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

  Future<void> _saveHoliday(
      BuildContext context, EditHolidayViewModel viewModel) async {
    final success = await viewModel.saveHoliday();
    if (success && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}