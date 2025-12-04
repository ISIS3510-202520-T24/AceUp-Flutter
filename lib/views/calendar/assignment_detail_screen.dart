// lib/views/calendar/assignment_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/assignments/assignment_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/auth/auth_service.dart';
import '../../themes/app_typography.dart';

class AssignmentDetailScreen extends StatelessWidget {
  final Assignment assignment;

  const AssignmentDetailScreen({
    super.key,
    required this.assignment,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Details'),
        backgroundColor: colors.surface,
        actions: [
          IconButton(
            icon: Icon(
              assignment.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
              color: assignment.isCompleted ? Colors.green : colors.onSurface,
            ),
            onPressed: () => _toggleCompletion(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              assignment.title,
              style: AppTypography.h3.copyWith(
                color: colors.onSurface,
                decoration: assignment.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            if (assignment.subjectName != null) ...[
              const SizedBox(height: 8),
              Text(
                assignment.subjectName!,
                style: AppTypography.bodyM.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Priority badge
            Row(
              children: [
                _PriorityBadge(priority: assignment.priority),
                const Spacer(),
                if (assignment.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: AppTypography.bodyS.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Due date
            _buildInfoCard(
              context,
              icon: Icons.calendar_today,
              title: 'Due Date',
              value: DateFormat('EEEE, MMMM d, yyyy').format(assignment.dueDate),
            ),
            const SizedBox(height: 12),

            // Due time
            if (assignment.dueTime != null)
              _buildInfoCard(
                context,
                icon: Icons.access_time,
                title: 'Due Time',
                value: assignment.dueTime!,
              ),
            if (assignment.dueTime != null) const SizedBox(height: 12),

            // Description
            if (assignment.description != null && assignment.description!.isNotEmpty) ...[
              Card(
                elevation: 0,
                color: colors.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: colors.primary, size: 24),
                          const SizedBox(width: 16),
                          Text(
                            'Description',
                            style: AppTypography.bodyM.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        assignment.description!,
                        style: AppTypography.bodyM.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Grade (if exists)
            if (assignment.isGraded && assignment.grade != null)
              _buildInfoCard(
                context,
                icon: Icons.grade,
                title: 'Grade',
                value: '${assignment.grade}',
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _toggleCompletion(context),
        icon: Icon(
          assignment.isCompleted ? Icons.undo : Icons.check,
        ),
        label: Text(assignment.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
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

  Future<void> _toggleCompletion(BuildContext context) async {
    final repository = context.read<AcademicRepository>();
    
    try {
      // Get required IDs from assignment or auth service
      if (assignment.termId == null || assignment.subjectId == null) {
        throw Exception('Missing required term or subject ID');
      }
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final updatedAssignment = assignment.copyWith(
        isCompleted: !assignment.isCompleted,
        completedAt: !assignment.isCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );
      
      await repository.saveAssignment(
        updatedAssignment,
        userId,
        assignment.termId!,
        assignment.subjectId!,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedAssignment.isCompleted 
                ? 'Assignment marked as complete' 
                : 'Assignment marked as incomplete'
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating assignment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _PriorityBadge extends StatelessWidget {
  final dynamic priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final priorityStr = priority.toString().split('.').last;
    
    Color badgeColor;
    IconData icon;
    switch (priorityStr.toLowerCase()) {
      case 'high':
        badgeColor = Colors.red;
        icon = Icons.priority_high;
        break;
      case 'medium':
        badgeColor = Colors.orange;
        icon = Icons.remove;
        break;
      case 'low':
        badgeColor = Colors.blue;
        icon = Icons.arrow_downward;
        break;
      default:
        badgeColor = Theme.of(context).colorScheme.primary;
        icon = Icons.flag;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 16),
          const SizedBox(width: 4),
          Text(
            '$priorityStr Priority',
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
