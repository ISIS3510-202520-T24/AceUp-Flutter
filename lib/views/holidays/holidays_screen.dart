import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/enums.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../models/holidays/holiday_model.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/holidays/holidays_viewmodel.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/deletable_list_item.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/top_bar.dart';
import 'edit_holiday_screen.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HolidaysViewModel(
        holidayRepository: context.read<HolidayRepository>(),
        settingsRepository: context.read<SettingsRepository>(),
      ),
      child: const HolidaysScreenContent(),
    );
  }
}

class HolidaysScreenContent extends StatelessWidget {
  const HolidaysScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HolidaysViewModel>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(title: "Holidays"),
      body: _buildBody(context, viewModel, colors),
      floatingActionButton: FAB(
          options: [
            FabOption(
                icon: AppIcons.add,
                label: 'New Custom Holiday',
                onPressed: () => _handleAddAction(context, viewModel)
            ),
          ]
      )
    );
  }

  Widget _buildBody(BuildContext context, HolidaysViewModel viewModel, ColorScheme colors) {
    switch (viewModel.state) {
      case ViewStateWithSuccess.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case ViewStateWithSuccess.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.error,
                  size: 64,
                  color: colors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load holidays',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.errorMessage ?? 'An unknown error occurred',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => viewModel.refreshHolidays(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        );

      case ViewStateWithSuccess.success:
      case ViewStateWithSuccess.idle:
        if (viewModel.holidays.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.calendarDay,
                  size: 64,
                  color: colors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No holidays found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull down to refresh',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.refreshHolidays(),
          child: _buildHolidaysList(context, viewModel, colors),
        );
    }
  }

  Widget _buildHolidaysList(BuildContext context, HolidaysViewModel viewModel, ColorScheme colors) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: viewModel.holidays.length,
      itemBuilder: (context, index) {
        final holiday = viewModel.holidays[index];
        return _buildHolidayCard(holiday, context, colors, viewModel);
      },
    );
  }

  Widget _buildHolidayCard(Holiday holiday, BuildContext context, ColorScheme colors, HolidaysViewModel viewModel) {
    String dateText;
    dateText = holiday.fullDate;

    final card = InkWell(
      onTap: holiday.isUserCreated
          ? () => _handleEditAction(context, viewModel, holiday)
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            holiday.name,
                            style: AppTypography.bodyM.copyWith(color: colors.onSurface),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      style: AppTypography.bodyS.copyWith(color: colors.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              // Show edit icon only for user-created holidays
              if (holiday.isUserCreated)
                Icon(
                  AppIcons.edit,
                  size: 16,
                  color: colors.primary,
                ),
            ],
          ),
        ),
      ),
    );

    // Only allow delete for user-created holidays
    if (holiday.isUserCreated) {
      return DeletableListItem(
        itemType: 'Holiday',
        itemName: holiday.name,
        onDelete: () => viewModel.deleteHoliday(holiday),
        child: card,
      );
    }

    return card;
  }

  Future<void> _handleAddAction(BuildContext context, HolidaysViewModel viewModel) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditHolidayScreen(),
      ),
    );

    if (result == true && context.mounted) {
      viewModel.refreshHolidays();
    }
  }

  Future<void> _handleEditAction(
      BuildContext context, HolidaysViewModel viewModel, holiday) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditHolidayScreen(holiday: holiday),
      ),
    );

    if (result == true && context.mounted) {
      viewModel.refreshHolidays();
    }
  }
}