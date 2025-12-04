import 'package:flutter/material.dart';
import '../themes/app_typography.dart';

/// Reusable confirmation dialog for delete operations
class DeleteConfirmationDialog extends StatelessWidget {
  final String itemType;
  final String itemName;
  final VoidCallback onConfirm;
  final String? cascadeWarning;

  const DeleteConfirmationDialog({
    super.key,
    required this.itemType,
    required this.itemName,
    required this.onConfirm,
    this.cascadeWarning,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(
        'Delete $itemType?',
        style: AppTypography.h4.copyWith(
          color: colors.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete "$itemName"? This action cannot be undone.',
            style: AppTypography.bodyM.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (cascadeWarning != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.error.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: colors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cascadeWarning!,
                      style: AppTypography.bodyS.copyWith(
                        color: colors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTypography.bodyM.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colors.errorContainer,
            foregroundColor: colors.onError,
          ),
          child: Text(
            'Delete',
            style: AppTypography.bodyM,
          ),
        ),
      ],
    );
  }

  /// Show the delete confirmation dialog
  static Future<void> show({
    required BuildContext context,
    required String itemType,
    required String itemName,
    required VoidCallback onConfirm,
    String? cascadeWarning,
  }) {
    return showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        itemType: itemType,
        itemName: itemName,
        onConfirm: onConfirm,
        cascadeWarning: cascadeWarning,
      ),
    );
  }
}
