import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../themes/app_icons.dart';

class FabOption {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const FabOption({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

class FAB extends StatefulWidget {
  final List<FabOption> options;
  final double distance;

  const FAB({
    super.key,
    required this.options,
    this.distance = 80.0,
  });

  @override
  State<FAB> createState() => _FABState();
}

class _FABState extends State<FAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        _showOverlay();
      } else {
        _controller.reverse();
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;

        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                child: Container(color: colors.surface.withValues(alpha: 0.5)),
              ),
            ),

            ..._buildExpandingActionButtons(),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleFabPress() {
    if (widget.options.length == 1) {
      widget.options.first.onPressed();
    } else {
      _toggle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FloatingActionButton(
      backgroundColor: colors.primary,
      onPressed: _handleFabPress,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: widget.options.length > 1
                ? _expandAnimation.value * math.pi / 4
                : 0,
            child: Icon(
              AppIcons.add,
              size: 18,
              color: colors.onPrimary,
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.options.length;

    for (var i = 0; i < count; i++) {
      final option = widget.options[i];
      final verticalOffset = (i + 2) * (56.0 + 8.0);
      children.add(
        Positioned(
          right: 16,
          bottom: verticalOffset, // just above the FAB
          child: _ExpandingActionButton(
            progress: _expandAnimation,
            child: _buildOptionButton(option),
          ),
        ),
      );
    }
    return children;
  }

  Widget _buildOptionButton(FabOption option) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      elevation: 4.0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          _toggle();
          option.onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(option.icon, size: 15, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                option.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  final Animation<double> progress;
  final Widget child;

  const _ExpandingActionButton({
    required this.progress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        return Transform.scale(
          scale: progress.value,
          alignment: Alignment.centerRight,
          child: Opacity(
            opacity: progress.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
