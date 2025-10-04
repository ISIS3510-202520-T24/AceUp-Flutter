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

class _FABState extends State<FAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

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
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
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

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Semi-transparent overlay when expanded (only for multiple options)
          if (_isExpanded && widget.options.length > 1)
            GestureDetector(
              onTap: _toggle,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),

          if (widget.options.length > 1)
            ..._buildExpandingActionButtons(),

          _buildMainFab(colors),
        ],
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.options.length;
    final step = 90.0 / (count > 1 ? count - 1 : 1);

    for (var i = 0; i < count; i++) {
      final option = widget.options[i];
      children.add(
        _ExpandingActionButton(
          directionInDegrees: 270.0 - (i * step),
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: _buildOptionButton(option),
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
              Icon(
                option.icon,
                size: 15,
                color: colors.primary,
              ),
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

  Widget _buildMainFab(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return FloatingActionButton(
            backgroundColor: colors.primary,
            onPressed: _handleFabPress,
            child: Transform.rotate(
              // Only rotate if there are multiple options
              angle: widget.options.length > 1
                  ? _expandAnimation.value * math.pi / 4
                  : 0,
              child: Icon(
                AppIcons.add,
                size: 18,
                color: colors.onPrimary,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Animation wrapper for expanding action buttons
class _ExpandingActionButton extends StatelessWidget {
  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );

        return Positioned(
          right: 32.0 + offset.dx,
          bottom: 32.0 + offset.dy,
          child: Transform.scale(
            scale: progress.value,
            child: Opacity(
              opacity: progress.value,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}