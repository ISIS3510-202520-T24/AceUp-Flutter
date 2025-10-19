import 'package:flutter/widgets.dart';
import 'observable.dart';

/// Widget que se reconstruye cuando el Observable notifica.
class Observer extends StatefulWidget {
  final Observable listenable;
  final Widget Function(BuildContext context) builder;

  const Observer({
    super.key,
    required this.listenable,
    required this.builder,
  });

  @override
  State<Observer> createState() => _ObserverState();
}

class _ObserverState extends State<Observer> {
  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_onChange);
  }

  @override
  void didUpdateWidget(covariant Observer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onChange);
      widget.listenable.addListener(_onChange);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
