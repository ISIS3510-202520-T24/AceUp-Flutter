// lib/views/calendar/class_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/planner/class_template_model.dart';
import '../../themes/app_typography.dart';

class ClassDetailScreen extends StatelessWidget {
  final ClassTemplate classTemplate;
  final DateTime selectedDate;

  const ClassDetailScreen({
    super.key,
    required this.classTemplate,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Details'),
        backgroundColor: colors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and name
            Row(
              children: [
                classTemplate.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: classTemplate.imageUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                classTemplate.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            classTemplate.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classTemplate.name,
                        style: AppTypography.h3.copyWith(color: colors.onSurface),
                      ),
                      if (classTemplate.subjectName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          classTemplate.subjectName!,
                          style: AppTypography.bodyM.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Selected date
            _buildInfoCard(
              context,
              icon: Icons.calendar_today,
              title: 'Date',
              value: DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
            ),
            const SizedBox(height: 12),

            // Time
            _buildInfoCard(
              context,
              icon: Icons.access_time,
              title: 'Time',
              value: '${classTemplate.startTime} - ${classTemplate.endTime}',
            ),
            const SizedBox(height: 12),

            // Location
            if (classTemplate.building != null || classTemplate.room != null)
              _buildInfoCard(
                context,
                icon: Icons.location_on,
                title: 'Location',
                value: [
                  if (classTemplate.building != null) classTemplate.building!,
                  if (classTemplate.room != null) classTemplate.room!,
                ].join(' - '),
              ),
            if (classTemplate.building != null || classTemplate.room != null)
              const SizedBox(height: 12),

            // Recurrence pattern
            _buildInfoCard(
              context,
              icon: Icons.repeat,
              title: 'Recurrence',
              value: _getRecurrenceText(),
            ),
            const SizedBox(height: 12),

            // Duration
            _buildInfoCard(
              context,
              icon: Icons.timelapse,
              title: 'Duration',
              value: _calculateDuration(),
            ),
            const SizedBox(height: 12),

            // Period
            _buildInfoCard(
              context,
              icon: Icons.date_range,
              title: 'Class Period',
              value: '${DateFormat('MMM d, yyyy').format(classTemplate.startDate)} - ${DateFormat('MMM d, yyyy').format(classTemplate.endDate)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyS.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTypography.bodyM.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
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

  String _getRecurrenceText() {
    final days = classTemplate.recurrence.selectedDays;
    if (days.isEmpty) return 'No recurrence';

    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final selectedDayNames = days.map((d) => dayNames[d]).toList();
    
    return 'Every ${selectedDayNames.join(', ')}';
  }

  String _calculateDuration() {
    try {
      final start = TimeOfDay(
        hour: int.parse(classTemplate.startTime.split(':')[0]),
        minute: int.parse(classTemplate.startTime.split(':')[1]),
      );
      final end = TimeOfDay(
        hour: int.parse(classTemplate.endTime.split(':')[0]),
        minute: int.parse(classTemplate.endTime.split(':')[1]),
      );

      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      final durationMinutes = endMinutes - startMinutes;

      if (durationMinutes >= 60) {
        final hours = durationMinutes ~/ 60;
        final minutes = durationMinutes % 60;
        return minutes > 0 ? '$hours hour${hours > 1 ? 's' : ''} $minutes min' : '$hours hour${hours > 1 ? 's' : ''}';
      }
      return '$durationMinutes minutes';
    } catch (e) {
      return 'N/A';
    }
  }
}
