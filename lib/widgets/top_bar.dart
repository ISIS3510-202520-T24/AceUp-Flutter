import 'package:flutter/material.dart';
import '../themes/app_typography.dart';
import '../themes/app_icons.dart';

enum LeftControlType { back, menu, cancel }
enum RightControlType { edit, none, save }

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final LeftControlType leftControlType;
  final RightControlType rightControlType;
  final VoidCallback? onLeftPressed;
  final VoidCallback? onRightPressed;

  const TopBar({
    super.key,
    required this.title,
    this.leftControlType = LeftControlType.menu,
    this.rightControlType = RightControlType.none,
    this.onLeftPressed,
    this.onRightPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final rightControl = _buildRightControl(context, colors);

    return AppBar(
      backgroundColor: colors.primaryContainer,
      elevation: 0.0,
      title: Text(
        title,
        style: AppTypography.h3.copyWith(color: colors.onPrimary),
      ),
      centerTitle: true,
      leading: _buildLeftControl(context, colors),
      actions: rightControl != null ? [rightControl] : null,
      iconTheme: IconThemeData(color: colors.onPrimaryContainer),
    );
  }

  /// Left side
  Widget? _buildLeftControl(BuildContext context, ColorScheme colors) {
    switch (leftControlType) {
      case LeftControlType.back:
        return IconButton(
          icon: Icon(AppIcons.arrowLeft),
          onPressed: onLeftPressed ?? () => Navigator.of(context).maybePop(),
        );
      case LeftControlType.menu:
        return Builder(
          builder: (context) => IconButton(
            icon: Icon(AppIcons.burgerMenu),
            onPressed: onLeftPressed ?? () => Scaffold.of(context).openDrawer(),
          ),
        );
      case LeftControlType.cancel:
        return TextButton(
          onPressed: onLeftPressed ?? () => Navigator.of(context).maybePop(),
          child: Text("Cancel", style: AppTypography.actionM.copyWith(color: colors.onPrimaryContainer)),
        );
    }
  }

  /// Right side
  Widget? _buildRightControl(BuildContext context, ColorScheme colors) {
    switch (rightControlType) {
      case RightControlType.edit:
        return TextButton(
          onPressed: onRightPressed,
          child: Text("Edit", style: AppTypography.actionM.copyWith(color: colors.onPrimaryContainer)),
        );
      case RightControlType.save:
        return TextButton(
          onPressed: onRightPressed,
          child: Text("Save", style: AppTypography.actionM.copyWith(color: colors.onPrimaryContainer)),
        );
      case RightControlType.none:
        return null;
    }
  }
}
