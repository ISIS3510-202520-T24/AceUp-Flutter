// lib/core/observer/vm_scope.dart
import 'package:flutter/widgets.dart';

class VmRegistry {
  final Map<Type, Object> _map = {};

  void put<T>(T instance) => _map[T] = instance as Object;

  T get<T>() {
    final obj = _map[T];
    if (obj == null) {
      throw FlutterError('VmRegistry: no se encontró una instancia de $T');
    }
    return obj as T;
  }

  // Útil para debug
  void debugPrintKeys() {
    // ignore: avoid_print
    print('VmRegistry keys: ${_map.keys.map((e) => e.toString()).join(', ')}');
  }
}

class VmScope extends InheritedWidget {
  final VmRegistry registry;

  const VmScope({
    super.key,
    required this.registry,
    required super.child,
  });

  static VmRegistry of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<VmScope>();
    if (scope == null) {
      throw FlutterError('VmScope no encontrado en el árbol de widgets');
    }
    return scope.registry;
  }

  @override
  bool updateShouldNotify(covariant VmScope oldWidget) =>
      !identical(oldWidget.registry, registry);
}
