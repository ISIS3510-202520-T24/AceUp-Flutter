import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/enums.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../services/auth/auth_service.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/settings/settings_viewmodel.dart';
import '../../widgets/dropdown_field.dart';
import '../../widgets/form_field.dart';
import '../../widgets/top_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().currentUserId;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view settings')),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(
        repository: SettingsRepository(
          database: context.read<AppDatabase>(),
          firestore: FirebaseFirestore.instance,
        ),
        holidayRepository: context.read<HolidayRepository>(),
        userId: userId,
      ),
      child: const SettingsScreenContent(),
    );
  }
}

class SettingsScreenContent extends StatelessWidget {
  const SettingsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: TopBar(
        title: 'Settings',
        leftControlType: LeftControlType.back,
      ),
      body: _buildBody(context, viewModel, colors),
    );
  }

  Widget _buildBody(BuildContext context, SettingsViewModel viewModel, ColorScheme colors) {
    switch (viewModel.state) {
      case SettingsViewState.loading:
        return const Center(child: CircularProgressIndicator());

      case SettingsViewState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.error, size: 64, color: colors.error),
                const SizedBox(height: 16),
                Text(
                  'Failed to load settings',
                  style: AppTypography.h4.copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.errorMessage ?? 'An unknown error occurred',
                  style: AppTypography.bodyM.copyWith(color: colors.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => viewModel.loadSettings(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );

      case SettingsViewState.idle:
      case SettingsViewState.success:
      case SettingsViewState.saving:
        return _buildSettingsForm(context, viewModel, colors);
    }
  }

  Widget _buildSettingsForm(BuildContext context, SettingsViewModel viewModel, ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'General Settings',
            style: AppTypography.h3.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your academic preferences',
            style: AppTypography.bodyS.copyWith(color: colors.onSecondaryContainer),
          ),
          const SizedBox(height: 24),

          // Default Class Duration
          _buildSectionHeader('Class Settings', colors),
          const SizedBox(height: 12),
          AppFormField(
            label: 'Default Class Duration (minutes)',
            hint: 'e.g., 60',
            controller: viewModel.defaultClassDurationController,
            type: FormFieldType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a duration';
              }
              final duration = int.tryParse(value);
              if (duration == null || duration <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Active Weekdays
          _buildSectionHeader('Active Weekdays', colors),
          const SizedBox(height: 8),
          Text(
            'Select your school/work days',
            style: AppTypography.bodyS.copyWith(color: colors.onSecondaryContainer),
          ),
          const SizedBox(height: 12),
          _buildWeekdaySelector(viewModel, colors),
          const SizedBox(height: 24),

          // Grading Scale
          _buildSectionHeader('Grading System', colors),
          const SizedBox(height: 12),
          AppDropdownField<GradingScaleType>(
            label: 'Grading Scale Type',
            value: viewModel.selectedGradingScaleType,
            items: GradingScaleType.values,
            getLabel: (type) => _getGradingScaleLabel(type),
            onChanged: (type) {
              if (type != null) {
                viewModel.updateGradingScaleType(type);
              }
            },
          ),
          const SizedBox(height: 16),
          _buildGradingScaleInfo(viewModel, colors),
          const SizedBox(height: 24),

          // Holiday Country
          _buildSectionHeader('Holidays', colors),
          const SizedBox(height: 12),
          viewModel.isLoadingCountries
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : AppDropdownField<String>(
                  label: 'Holiday Country',
                  value: viewModel.selectedCountryCode,
                  items: viewModel.availableCountries
                      .map((country) => country['code']!)
                      .toList(),
                  getLabel: (code) {
                    final country = viewModel.availableCountries
                        .firstWhere((c) => c['code'] == code);
                    return country['name']!;
                  },
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.updateCountryCode(value);
                    }
                  },
                ),
          const SizedBox(height: 8),
          Text(
            'Used to fetch public holidays from the API',
            style: AppTypography.bodyS.copyWith(color: colors.onSecondaryContainer),
          ),
          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: viewModel.state == SettingsViewState.saving
                  ? null
                  : () => _handleSave(context, viewModel),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: viewModel.state == SettingsViewState.saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Save Settings',
                      style: AppTypography.h5.copyWith(color: colors.onPrimary),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colors) {
    return Text(
      title,
      style: AppTypography.h4.copyWith(color: colors.onSurface),
    );
  }

  Widget _buildWeekdaySelector(SettingsViewModel viewModel, ColorScheme colors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final isSelected = viewModel.selectedWeekdays.contains(index);
        return FilterChip(
          label: Text(viewModel.getShortWeekdayName(index)),
          selected: isSelected,
          onSelected: (selected) => viewModel.toggleWeekday(index),
          backgroundColor: colors.surface,
          selectedColor: colors.primaryContainer,
          checkmarkColor: colors.onPrimaryContainer,
          labelStyle: AppTypography.bodyM.copyWith(
            color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
          ),
          side: BorderSide(
            color: isSelected ? colors.primary : colors.outline,
          ),
        );
      }),
    );
  }

  Widget _buildGradingScaleInfo(SettingsViewModel viewModel, ColorScheme colors) {
    switch (viewModel.selectedGradingScaleType) {
      case GradingScaleType.percentage:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Grades will be displayed as percentages (0-100)',
                  style: AppTypography.bodyS.copyWith(color: colors.onSurface),
                ),
              ),
            ],
          ),
        );

      case GradingScaleType.letter:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Using standard US letter grading scale (A-F)',
                      style: AppTypography.bodyS.copyWith(color: colors.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...viewModel.letterGrades.map((grade) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      grade.letter,
                      style: AppTypography.bodyM.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${grade.minPercentage.toInt()}% - ${grade.maxPercentage.toInt()}%',
                      style: AppTypography.bodyS.copyWith(color: colors.onSecondaryContainer),
                    ),
                  ),
                  Text(
                    'GPA: ${grade.gpaValue}',
                    style: AppTypography.bodyS.copyWith(color: colors.onSecondaryContainer),
                  ),
                ],
              ),
            )),
          ],
        );

      case GradingScaleType.points:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Grades will be displayed as points',
                      style: AppTypography.bodyS.copyWith(color: colors.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    label: 'Min Points',
                    hint: '0',
                    controller: viewModel.minPointsController,
                    type: FormFieldType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final val = double.tryParse(value);
                      if (val == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppFormField(
                    label: 'Max Points',
                    hint: '100',
                    controller: viewModel.maxPointsController,
                    type: FormFieldType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final val = double.tryParse(value);
                      if (val == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  String _getGradingScaleLabel(GradingScaleType type) {
    switch (type) {
      case GradingScaleType.percentage:
        return 'Percentage (0-100)';
      case GradingScaleType.letter:
        return 'Letter Grades (A-F)';
      case GradingScaleType.points:
        return 'Points';
    }
  }

  Future<void> _handleSave(BuildContext context, SettingsViewModel viewModel) async {
    await viewModel.saveSettings();

    if (viewModel.state == SettingsViewState.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (viewModel.state == SettingsViewState.error && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to save settings'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}