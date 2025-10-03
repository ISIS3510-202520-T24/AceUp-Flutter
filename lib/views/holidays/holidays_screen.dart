import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/holidays_viewmodel.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/top_bar.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HolidaysViewModel(),
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
      appBar: TopBar(
        title: "Holidays",
        leftControlType: LeftControlType.menu,
        rightControlType: RightControlType.none,
      ),
      body: _buildBody(context, viewModel, colors),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () {
          // TODO: Add functionality to create custom holiday
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add custom holiday feature coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Icon(Icons.add, size: 28, color: colors.onPrimary),
      ),
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
                  Icons.error_outline,
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
                  Icons.calendar_today,
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
        return _buildHolidayCard(holiday, colors);
      },
    );
  }

  Widget _buildHolidayCard(holiday, ColorScheme colors) {
    String dateText;
    dateText = holiday.fullDate;

    return Card(
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
                    holiday.displayName,
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
  }
}