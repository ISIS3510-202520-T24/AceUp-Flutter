// lib/services/cache/lru_cache.dart
// Simple LRU cache for CalendarEvent lists keyed by day (yyyy-MM-dd)

class LruCache<V> {
  final int capacity;
  final _map = <String, V>{};
  final _order = <String>[]; // most recent at end

  LruCache({this.capacity = 100});

  V? get(String key) {
    final v = _map[key];
    if (v != null) {
      _order.remove(key);
      _order.add(key);
    }
    return v;
  }

  void set(String key, V value) {
    if (_map.containsKey(key)) {
      _map[key] = value;
      _order.remove(key);
      _order.add(key);
      return;
    }
    if (_map.length >= capacity) {
      final evictKey = _order.isNotEmpty ? _order.first : null;
      if (evictKey != null) {
        _order.removeAt(0);
        _map.remove(evictKey);
      }
    }
    _map[key] = value;
    _order.add(key);
  }

  void clear() {
    _map.clear();
    _order.clear();
  }
}
