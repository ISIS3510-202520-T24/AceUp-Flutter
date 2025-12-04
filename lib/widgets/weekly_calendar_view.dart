import 'dart:math';
import 'package:flutter/material.dart';

import '../themes/app_typography.dart';
import '../viewmodels/week_view/week_view_viewmodel.dart';

/// Widget that displays a weekly calendar view with class occurrences
/// Shows Monday to Friday with time slots from 7:00 AM to 10:00 PM
class WeeklyCalendarView extends StatelessWidget {
  final List<WeeklyClassOccurrence> occurrences;
  final void Function(WeeklyClassOccurrence)? onEventTap;

  const WeeklyCalendarView({
    super.key,
    required this.occurrences,
    this.onEventTap,
  });

  // Constants
  static const double _kDayColumnWidth = 70.0;
  static const double _kTimeColumnWidth = 45.0;
  static const double _kEventMinHeight = 32.0;
  static const int _kStartMinutes = 7 * 60; // 7:00 AM
  static const int _kEndMinutes = 22 * 60; // 10:00 PM

  @override
  Widget build(BuildContext context) {
    // Group occurrences by weekday
    final eventsByDay = <int, List<WeeklyClassOccurrence>>{};
    for (int i = 1; i <= 5; i++) {
      eventsByDay[i] = [];
    }

    for (final occurrence in occurrences) {
      if (occurrence.weekday >= 1 && occurrence.weekday <= 5) {
        eventsByDay[occurrence.weekday]!.add(occurrence);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time column
        SizedBox(
          width: _kTimeColumnWidth,
          child: _buildTimeColumn(context),
        ),
        
        // Days columns
        _buildDayColumn(
          context,
          label: 'MON',
          weekday: 1,
          occurrences: eventsByDay[1]!,
        ),
        _buildDayColumn(
          context,
          label: 'TUE',
          weekday: 2,
          occurrences: eventsByDay[2]!,
        ),
        _buildDayColumn(
          context,
          label: 'WED',
          weekday: 3,
          occurrences: eventsByDay[3]!,
        ),
        _buildDayColumn(
          context,
          label: 'THU',
          weekday: 4,
          occurrences: eventsByDay[4]!,
        ),
        _buildDayColumn(
          context,
          label: 'FRI',
          weekday: 5,
          occurrences: eventsByDay[5]!,
        ),
      ],
    );
  }

  Widget _buildTimeColumn(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        // Header spacing
        const SizedBox(height: 28),
        
        // Time labels
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentHeight = constraints.maxHeight;
              final totalMinutes = _kEndMinutes - _kStartMinutes;
              final pixelsPerMinute = contentHeight / totalMinutes.toDouble();

              final labels = <Widget>[];
              
              // Generate labels for each hour
              for (int hour = 7; hour <= 22; hour++) {
                final minutes = hour * 60;
                final top = (minutes - _kStartMinutes) * pixelsPerMinute;

                labels.add(
                  Positioned(
                    top: top - 8,
                    left: 0,
                    right: 0,
                    child: Text(
                      _formatHour(hour),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyS.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              }

              return Stack(children: labels);
            },
          ),
        ),
      ],
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 a.m.';
    if (hour < 12) return '$hour a.m.';
    if (hour == 12) return '12 p.m.';
    final h = hour - 12;
    return '$h p.m.';
  }

  Widget _buildDayColumn(
    BuildContext context, {
    required String label,
    required int weekday,
    required List<WeeklyClassOccurrence> occurrences,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Expanded(
      child: Container(
        width: _kDayColumnWidth,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
          ),
        ),
        child: Column(
          children: [
            // Day header
            SizedBox(
              height: 28,
              child: Center(
                child: Text(
                  label,
                  style: AppTypography.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
            
            // Events
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentHeight = constraints.maxHeight;
                  final totalMinutes = _kEndMinutes - _kStartMinutes;
                  final pixelsPerMinute = contentHeight / totalMinutes.toDouble();

                  final background = _buildHourGrid(contentHeight, colors);

                  final tiles = <Widget>[];

                  for (final occurrence in occurrences) {
                    final startMinutes = max(occurrence.startMinutes, _kStartMinutes);
                    final endMinutes = min(occurrence.endMinutes, _kEndMinutes);

                    final top = (startMinutes - _kStartMinutes) * pixelsPerMinute.toDouble();

                    final computedHeight = (endMinutes - startMinutes) * pixelsPerMinute.toDouble();

                    final height = max(_kEventMinHeight, computedHeight.roundToDouble());

                    tiles.add(
                      Positioned(
                        top: top,
                        left: 4,
                        right: 4,
                        height: height,
                        child: GestureDetector(
                          onTap: () {
                            if (onEventTap != null) {
                              onEventTap!(occurrence);
                            }
                          },
                          child: _buildEventTile(
                            context,
                            occurrence,
                            height,
                          ),
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [background, ...tiles],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourGrid(double totalHeight, ColorScheme colors) {
    final totalMinutes = _kEndMinutes - _kStartMinutes;
    final pixelsPerMinute = totalHeight / totalMinutes.toDouble();

    final lines = <Widget>[];
    
    // Generate lines for each hour
    for (int hour = 7; hour <= 22; hour++) {
      final minutes = hour * 60;
      final top = (minutes - _kStartMinutes) * pixelsPerMinute;

      lines.add(
        Positioned(
          top: top,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            color: colors.outline.withValues(alpha: 0.1),
          ),
        ),
      );
    }

    return Stack(children: lines);
  }

  Widget _buildEventTile(
    BuildContext context,
    WeeklyClassOccurrence occurrence,
    double height,
  ) {
    final colors = Theme.of(context).colorScheme;
    final classTemplate = occurrence.classTemplate;

    // Determine if we have space for multiple lines
    final hasSpace = height >= 60;

    // Parse subject color or fallback to primary
    Color borderColor = colors.primary;
    if (classTemplate.subjectColor != null) {
      try {
        borderColor = Color(int.parse('0xFF${classTemplate.subjectColor!.substring(1)}'));
      } catch (e) {
        // If color parsing fails, use primary color
        borderColor = colors.primary;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subject name (if available and space permits)
          if (hasSpace && classTemplate.subjectName != null) ...[
            Text(
              classTemplate.subjectName!,
              style: AppTypography.bodyS.copyWith(
                fontSize: 9,
                color: borderColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
          ],
          
          // Class name
          Text(
            classTemplate.name,
            style: AppTypography.bodyS.copyWith(
              fontSize: 10,
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
            maxLines: hasSpace ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Location (if space permits)
          if (hasSpace && classTemplate.location.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              classTemplate.location,
              style: AppTypography.bodyS.copyWith(
                fontSize: 8,
                color: colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}