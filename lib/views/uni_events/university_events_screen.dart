import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // ignore: uri_does_not_exist

import '../../core/constants/enums.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_icons.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/content_counter.dart';
import '../../widgets/connectivity_indicator.dart';
import '../../viewmodels/uni_events/university_events_viewmodel.dart';
import '../../services/uni_events/university_events_service.dart';
import '../../services/auth/auth_service.dart';
import '../../data/repositories/event_repository.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../models/uni_events/university_event_model.dart';
import 'edit_event_screen.dart';

/// Wrapper to provide dependencies to UniversityEventsScreen
class UniversityEventsScreenWrapper extends StatelessWidget {
  const UniversityEventsScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UniversityEventsViewModel(
        eventsService: UniversityEventsService(),
        eventRepository: context.read<EventRepository>(),
        connectivity: context.read<ConnectivityManager>(),
        authService: context.read<AuthService>(),
      ),
      child: const UniversityEventsScreen(),
    );
  }
}

class UniversityEventsScreen extends StatelessWidget {
  const UniversityEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const TopBar(
        title: 'Uni Events',
      ),
      drawer: const BurgerMenu(),
      body: Column(
        children: [
          const ConnectivityIndicator(),
          Expanded(
            child: Consumer<UniversityEventsViewModel>(
              builder: (context, viewModel, _) {
                return _buildBody(context, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, UniversityEventsViewModel viewModel) {
    switch (viewModel.state) {
      case OfflineViewState.loading:
        return _buildLoading(context);

      case OfflineViewState.error:
        return _buildError(context, viewModel);

      case OfflineViewState.offline:
        return _buildOffline(context, viewModel);

      case OfflineViewState.success:
        if (viewModel.filteredEvents.isEmpty) {
          return _buildEmpty(context, viewModel);
        }
        return _buildEventsList(context, viewModel);

      case OfflineViewState.idle:
        return _buildLoading(context);
    }
  }

  Widget _buildLoading(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading university events...',
            style: AppTypography.bodyM.copyWith(color: colors.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, UniversityEventsViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.error, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'Error Loading Events',
              style: AppTypography.h3.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'An unexpected error occurred',
              style: AppTypography.bodyM.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.fetchEvents(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffline(BuildContext context, UniversityEventsViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No Internet Connection',
              style: AppTypography.h3.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Please check your connection and try again',
              style: AppTypography.bodyM.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.fetchEvents(),
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
  }

  Widget _buildEmpty(BuildContext context, UniversityEventsViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.calendarDay, size: 64, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No Events Found',
              style: AppTypography.h3.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.selectedCategory != 'All'
                  ? 'No events in this category'
                  : 'No events available at the moment',
              style: AppTypography.bodyM.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (viewModel.selectedCategory != 'All') ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => viewModel.filterByCategory('All'),
                child: const Text('Show All Events'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, UniversityEventsViewModel viewModel) {
    return Column(
      children: [
        _buildFilterBar(context, viewModel),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.fetchEvents(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.filteredEvents.length,
              itemBuilder: (context, index) {
                return _EventCard(event: viewModel.filteredEvents[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, UniversityEventsViewModel viewModel) {
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 20, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: viewModel.categories.map((category) {
                  final isSelected = category == viewModel.selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => viewModel.filterByCategory(category),
                      backgroundColor: colors.surface,
                      selectedColor: colors.primaryContainer,
                      labelStyle: AppTypography.bodyS.copyWith(
                        color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual event card widget
class _EventCard extends StatelessWidget {
  final UniversityEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final viewModel = context.watch<UniversityEventsViewModel>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image with customization indicator
          Stack(
            children: [
              if (event.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    event.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: colors.primaryContainer,
                      child: Icon(
                        AppIcons.calendarMonth,
                        size: 64,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Icon(
                      AppIcons.calendarMonth,
                      size: 64,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              
              // Customization indicator
              if (event.hasCustomizations)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.tertiary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 14, color: colors.onTertiary),
                        const SizedBox(width: 4),
                        Text(
                          'Customized',
                          style: AppTypography.bodyS.copyWith(
                            color: colors.onTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Badge
                if (event.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.category!,
                      style: AppTypography.bodyS.copyWith(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 8),

                // Event Title
                Text(
                  event.title,
                  style: AppTypography.h4.copyWith(color: colors.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Date - shows effective date (user's or original)
                Row(
                  children: [
                    Icon(AppIcons.calendarDay, size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      event.getDateTimeRangeString(),
                      style: AppTypography.bodyM.copyWith(color: colors.onSurfaceVariant),
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ],
                ),

                // Location - shows effective location (user's or original)
                if (event.effectiveLocation != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(AppIcons.location, size: 16, color: colors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.effectiveLocation!,
                          style: AppTypography.bodyM.copyWith(color: colors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (event.userLocation != null)
                        Icon(AppIcons.edit, size: 12, color: colors.tertiary),
                    ],
                  ),
                ],

                // User notes preview
                if (event.userNotes != null && event.userNotes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.tertiaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.tertiary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, size: 14, color: colors.onTertiaryContainer),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.userNotes!,
                            style: AppTypography.bodyS.copyWith(
                              color: colors.onTertiaryContainer,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Description
                Text(
                  event.description,
                  style: AppTypography.bodyM.copyWith(color: colors.onSurfaceVariant),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // More Info Button
                    if (event.eventUrl != null)
                      TextButton.icon(
                        onPressed: () => _launchUrl(event.eventUrl!),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('More Info'),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.primary,
                        ),
                      )
                    else
                      const SizedBox(),

                    // Calendar Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button (only if added to calendar)
                        if (event.isAddedToCalendar)
                          IconButton(
                            onPressed: () => _editEvent(context, event, viewModel),
                            icon: Icon(AppIcons.edit, size: 20),
                            tooltip: 'Edit event',
                            color: colors.tertiary,
                          ),
                        
                        const SizedBox(width: 8),
                        
                        // Add/Remove button
                        FilledButton.icon(
                          onPressed: () => _toggleCalendar(context, event, viewModel),
                          icon: Icon(
                            event.isAddedToCalendar
                                ? Icons.check_circle
                                : AppIcons.add,
                            size: 18,
                          ),
                          label: Text(event.isAddedToCalendar ? 'Added' : 'Add'),
                          style: FilledButton.styleFrom(
                            backgroundColor: event.isAddedToCalendar
                                ? colors.tertiaryContainer
                                : colors.primary,
                            foregroundColor: event.isAddedToCalendar
                                ? colors.onTertiaryContainer
                                : colors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCalendar(
    BuildContext context,
    UniversityEvent event,
    UniversityEventsViewModel viewModel,
  ) async {
    if (event.isAddedToCalendar) {
      // Remove from calendar
      await viewModel.removeEventFromCalendar(event.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event removed from calendar'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Show edit screen before adding
      final result = await showEditEventScreen(context, event, isNewAddition: true);
      if (result != null && context.mounted) {
        await viewModel.addEventToCalendar(
          event.id,
          userNotes: result['userNotes'],
          userLocation: result['userLocation'],
          userStartDate: result['userStartDate'],
          userEndDate: result['userEndDate'],
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event added to calendar'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _editEvent(
    BuildContext context,
    UniversityEvent event,
    UniversityEventsViewModel viewModel,
  ) async {
    final result = await showEditEventScreen(context, event, isNewAddition: false);
    if (result != null && context.mounted) {
      await viewModel.updateUserEvent(
        event.id,
        userNotes: result['userNotes'],
        userLocation: result['userLocation'],
        userStartDate: result['userStartDate'],
        userEndDate: result['userEndDate'],
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) { // ignore: undefined_method
      await launchUrl(url, mode: LaunchMode.externalApplication); // ignore: undefined_identifier, undefined_method
    }
  }
}