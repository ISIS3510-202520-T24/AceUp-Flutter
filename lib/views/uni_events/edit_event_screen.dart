import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/uni_events/university_event_model.dart';
import '../../themes/app_typography.dart';
import '../../themes/app_icons.dart';
import '../../widgets/top_bar.dart';

/// Full screen for editing event customizations when adding to calendar
class EditEventScreen extends StatefulWidget {
  final UniversityEvent event;
  final bool isNewAddition; // true if adding, false if editing

  const EditEventScreen({
    super.key,
    required this.event,
    this.isNewAddition = true,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    // Initialize with existing user data or original data
    _locationController = TextEditingController(
      text: widget.event.userLocation ?? widget.event.location ?? '',
    );
    _notesController = TextEditingController(
      text: widget.event.userNotes ?? '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _resetToDefaults() {
    setState(() {
      _locationController.text = widget.event.location ?? '';
      _notesController.clear();
    });
  }

  void _save() {
    Navigator.of(context).pop({
      'userLocation': _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      'userNotes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: TopBar(
        title: widget.isNewAddition ? 'Add to Calendar' : 'Edit Event',
        leftControlType: LeftControlType.back,
        rightControlType: RightControlType.save,
        onRightPressed: _save,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.isNewAddition ? Icons.add_circle_outline : Icons.edit,
                        color: colors.onPrimaryContainer,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.event.title,
                          style: AppTypography.h4.copyWith(
                            color: colors.onPrimaryContainer,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (widget.event.category != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.event.category!,
                        style: AppTypography.bodyS.copyWith(
                          color: colors.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Form Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Details (Read-only)
                  Text(
                    'Event Details',
                    style: AppTypography.h5.copyWith(color: colors.onSurface),
                  ),
                  const SizedBox(height: 12),

                  // Date & Time
                  _buildReadOnlyField(
                    context,
                    icon: AppIcons.calendarDay,
                    label: 'Date & Time',
                    value: widget.event.getDateTimeRangeString(),
                  ),
                  const SizedBox(height: 12),

                  // Original Location
                  if (widget.event.location != null)
                    _buildReadOnlyField(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'Original Location',
                      value: widget.event.location!,
                    ),

                  const SizedBox(height: 24),
                  Divider(color: colors.outlineVariant),
                  const SizedBox(height: 24),

                  // Customization Section
                  Text(
                    'Your Customizations',
                    style: AppTypography.h5.copyWith(color: colors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your own notes and location details',
                    style: AppTypography.bodyS.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),

                  // Custom Location
                  Text(
                    'Custom Location',
                    style: AppTypography.bodyM.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: widget.event.location ?? 'Enter location',
                      prefixIcon: Icon(Icons.location_on_outlined, color: colors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainerHighest,
                    ),
                    maxLines: 1,
                  ),
                  if (_locationController.text.isNotEmpty &&
                      _locationController.text != widget.event.location)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 12),
                      child: Text(
                        'Original: ${widget.event.location ?? "Not specified"}',
                        style: AppTypography.bodyS.copyWith(
                          color: colors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Personal Notes
                  Text(
                    'Personal Notes',
                    style: AppTypography.bodyM.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'Add personal notes or reminders',
                      prefixIcon: Icon(Icons.note_outlined, color: colors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainerHighest,
                    ),
                    maxLines: 4,
                    maxLength: 500,
                  ),

                  const SizedBox(height: 12),

                  // Reset button
                  if (!widget.isNewAddition)
                    Center(
                      child: TextButton.icon(
                        onPressed: _resetToDefaults,
                        icon: const Icon(Icons.restore, size: 18),
                        label: const Text('Reset to defaults'),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: colors.outlineVariant, width: 1),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: Icon(
                    widget.isNewAddition ? Icons.add : Icons.save,
                    size: 20,
                  ),
                  label: Text(widget.isNewAddition ? 'Add to Calendar' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyS.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyM.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to navigate to edit event screen
Future<Map<String, dynamic>?> showEditEventScreen(
  BuildContext context,
  UniversityEvent event, {
  bool isNewAddition = true,
}) {
  return Navigator.of(context).push<Map<String, dynamic>>(
    MaterialPageRoute(
      builder: (context) => EditEventScreen(
        event: event,
        isNewAddition: isNewAddition,
      ),
    ),
  );
}
