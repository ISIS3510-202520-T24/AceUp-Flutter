import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/holidays/holidays_viewmodel.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/deletable_list_item.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/top_bar.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HolidaysViewModel(
        holidayRepository: context.read<HolidayRepository>(),
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
      case HolidayViewState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case HolidayViewState.error:
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

      case HolidayViewState.success:
      case HolidayViewState.idle:
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
          child: _buildHolidaysList(viewModel, colors),
        );
    }
  }

  Widget _buildHolidaysList(HolidaysViewModel viewModel, ColorScheme colors) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: viewModel.holidays.length,
      itemBuilder: (context, index) {
        final holiday = viewModel.holidays[index];
        return _buildHolidayCard(holiday, colors, viewModel);
      },
    );
  }

  Widget _buildHolidayCard(holiday, ColorScheme colors, HolidaysViewModel viewModel) {
    String dateText;
    dateText = holiday.fullDate;

    final card = Card(
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
                  Text(
                    holiday.name,
                    style: AppTypography.bodyM.copyWith(color: colors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    style: AppTypography.bodyS.copyWith(color: colors.onPrimaryContainer),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.edit,
              size: 12,
              color: colors.inversePrimary,
            ),
          ],
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

  void _handleAddAction(BuildContext context, HolidaysViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add custom holiday - Coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}