import 'package:flutter/material.dart';
import '../themes/app_icons.dart';
import '../themes/app_typography.dart';
import 'delete_confirmation_dialog.dart';

/// Wrapper widget that adds long-press delete functionality to list items
class DeletableListItem extends StatelessWidget {
  final Widget child;
  final String itemType;
  final String itemName;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final String? cascadeWarning;

  const DeletableListItem({
    super.key,
    required this.child,
    required this.itemType,
    required this.itemName,
    required this.onDelete,
    this.onTap,
    this.cascadeWarning,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (details) {
        _showDeleteMenu(context, details.globalPosition);
      },
      child: child,
    );
  }

  void _showDeleteMenu(BuildContext context, Offset position) {
    final colors = Theme.of(context).colorScheme;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Rect.fromLTWH(0, 0, overlay.size.width, overlay.size.height),
      ),
      items: [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                AppIcons.delete,
                color: colors.onError,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Delete $itemType',
                style: AppTypography.bodyM.copyWith(
                  color: colors.onError,
                ),
              ),
            ],
          ),
        ),
      ],
      elevation: 8,
    ).then((value) {
      if (value == 'delete') {
        DeleteConfirmationDialog.show(
          context: context,
          itemType: itemType,
          itemName: itemName,
          onConfirm: onDelete,
          cascadeWarning: cascadeWarning,
        );
      }
    });
  }
}
