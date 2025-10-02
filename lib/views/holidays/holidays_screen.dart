import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                    color: colors.onSurface.withOpacity(0.7),
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
                  color: colors.primary.withOpacity(0.5),
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
                    color: colors.onSurface.withOpacity(0.7),
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
    final holidaysByYear = viewModel.getHolidaysByYear();
    final years = holidaysByYear.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: years.length + 1, // +1 for the header card
      itemBuilder: (context, index) {
        // First item is the summary card
        if (index == 0) {
          return _buildSummaryCard(viewModel, colors);
        }

        // Subsequent items are year sections
        final yearIndex = index - 1;
        final year = years[yearIndex];
        final yearHolidays = holidaysByYear[year]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: colors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    year.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${yearHolidays.length} holidays',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...yearHolidays.map((holiday) => _buildHolidayCard(holiday, colors)),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(HolidaysViewModel viewModel, ColorScheme colors) {
    final currentYear = DateTime.now().year;
    final nextYear = currentYear + 1;
    final currentYearCount = viewModel.getHolidayCountForYear(currentYear);
    final nextYearCount = viewModel.getHolidayCountForYear(nextYear);
    final upcomingHolidays = viewModel.getUpcomingHolidays();

    // Map country codes to names
    const countryNames = {
      'CO': 'Colombia',
      'US': 'United States',
      'MX': 'Mexico',
      'ES': 'Spain',
      'AR': 'Argentina',
      'BR': 'Brazil',
      'GB': 'United Kingdom',
      'CA': 'Canada',
      'FR': 'France',
      'DE': 'Germany',
    };

    String countryName = countryNames[viewModel.countryCode] ?? viewModel.countryCode;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Holidays Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Country',
              countryName,
              Icons.flag,
              colors,
            ),
            const Divider(height: 20),
            _buildSummaryRow(
              '$currentYear Holidays',
              currentYearCount.toString(),
              Icons.event,
              colors,
            ),
            const Divider(height: 20),
            _buildSummaryRow(
              '$nextYear Holidays',
              nextYearCount.toString(),
              Icons.event_available,
              colors,
            ),
            const Divider(height: 20),
            _buildSummaryRow(
              'Upcoming',
              upcomingHolidays.length.toString(),
              Icons.upcoming,
              colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon, ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colors.onSurface.withOpacity(0.6)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHolidayCard(holiday, ColorScheme colors) {
    final now = DateTime.now();
    final isUpcoming = holiday.date.isAfter(now) ||
        (holiday.date.year == now.year &&
            holiday.date.month == now.month &&
            holiday.date.day == now.day);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isUpcoming
              ? colors.primary.withOpacity(0.3)
              : const Color(0xFFEDEAE4),
          width: isUpcoming ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isUpcoming
                ? colors.primaryContainer
                : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                holiday.date.day.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isUpcoming
                      ? colors.onPrimaryContainer
                      : colors.onSurface,
                ),
              ),
              Text(
                _getMonthAbbreviation(holiday.date.month),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isUpcoming
                      ? colors.onPrimaryContainer.withOpacity(0.8)
                      : colors.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          holiday.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isUpcoming ? colors.primary : const Color(0xFF201E1B),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(
                Icons.label_outline,
                size: 14,
                color: colors.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                holiday.typeString,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.today,
                size: 14,
                color: colors.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                holiday.weekDay,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurface.withOpacity(0.6),
                ),
              ),
              if (!holiday.isNationwide) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: colors.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Regional',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: isUpcoming
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Upcoming',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.onPrimary,
            ),
          ),
        )
            : Icon(
          Icons.check_circle_outline,
          size: 20,
          color: colors.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }
}