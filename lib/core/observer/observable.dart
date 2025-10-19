// lib/core/observer/observable.dart
typedef VoidCallback = void Function();

/// Observable minimalista sin ChangeNotifier.
class Observable {
  final Set<VoidCallback> _listeners = <VoidCallback>{};

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  /// Llama a todos los observers.
  void notify() {
    // Copia defensiva por si alguien agrega/quita listeners durante la iteración
    for (final cb in List<VoidCallback>.from(_listeners)) {
      try { cb(); } catch (_) {}
    }
  }
}
