import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';
import '../models/assignments/assignment_model.dart';
import '../themes/app_colors.dart';
import '../themes/app_icons.dart';
import '../themes/app_typography.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final bool showTimeInsteadOfDate;
  final VoidCallback onToggleStatus;

  const AssignmentCard({
    super.key,
    required this.assignment,
    this.showTimeInsteadOfDate = false,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    IconData priorityIcon;
    Color priorityColor;
    switch (assignment.priority) {
      case 'High':
        priorityIcon = AppIcons.priority;
        priorityColor = AppColors.errorMedium;
        break;
      case 'Low':
        priorityIcon = AppIcons.priority;
        priorityColor = AppColors.successMedium;
        break;
      default: // Medium
        priorityIcon = AppIcons.priority;
        priorityColor = AppColors.warningMedium;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      assignment.dueDate.year,
      assignment.dueDate.month,
      assignment.dueDate.day,
    );

    // Calculate due date/time text and color
    String dueDateText;
    Color dateTimeColor;
    bool isOverdue = false;

    if (showTimeInsteadOfDate) {
      // For Today screen: show due time
      if (assignment.dueTime != null) {
        dueDateText = 'Due ${assignment.dueTime}';

        // Check if time is overdue
        if (!assignment.isCompleted) {
          try {
            final dueTimeParts = assignment.dueTime!.split(':');
            final dueHour = int.parse(dueTimeParts[0]);
            final dueMinute = int.parse(dueTimeParts[1]);
            final dueDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              dueHour,
              dueMinute,
            );

            isOverdue = now.isAfter(dueDateTime);
          } catch (e) {
            // If parsing fails, assume not overdue
            isOverdue = false;
          }
        }
      } else {
        dueDateText = 'Due Midnight';
      }

      dateTimeColor = isOverdue && !assignment.isCompleted
          ? colors.error
          : colors.onPrimaryContainer;
    } else {
      // For other screens: show due date
      if (dueDate.isAtSameMomentAs(today)) {
        dueDateText = 'Due Today';
      } else if (dueDate.isBefore(today)) {
        final difference = today.difference(dueDate).inDays;
        if (assignment.isCompleted) {
          dueDateText = DateFormat(AppConstants.dateFormat).format(assignment.dueDate);
        } else {
          dueDateText = difference == 1
              ? 'Overdue by 1 day'
              : 'Overdue by $difference days';
        }
      } else {
        final difference = dueDate.difference(today).inDays;
        if (difference == 1) {
          dueDateText = 'Due Tomorrow';
        } else if (difference <= 7) {
          dueDateText = 'Due in $difference days';
        } else {
          dueDateText = DateFormat(AppConstants.dateFormat).format(assignment.dueDate);
        }
      }

      dateTimeColor = dueDate.isBefore(today) && !assignment.isCompleted
          ? colors.error
          : colors.onPrimaryContainer;
    }

    return Card(
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: assignment.isCompleted,
                onChanged: (value) {
                  onToggleStatus();
                },
                activeColor: colors.primary,
                checkColor: colors.onPrimary,
                side: BorderSide(color: colors.primary, width: 2),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.subjectName ?? 'Unknown Subject',
                      style: AppTypography.h5.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      assignment.title,
                      style: AppTypography.bodyM.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      assignment.description ?? '',
                      style: AppTypography.bodyS.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dueDateText,
                    style: AppTypography.bodyS.copyWith(
                      color: dateTimeColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Icon(
                    priorityIcon,
                    size: 21,
                    color: priorityColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

