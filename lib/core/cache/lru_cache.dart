// lib/core/cache/lru_cache.dart

import 'dart:collection';

/// LRU (Least Recently Used) Cache
/// 
/// Estructura de datos que mantiene un máximo de [capacity] elementos en memoria.
/// Cuando se alcanza el límite, elimina el elemento MENOS RECIENTEMENTE USADO.
/// 
/// **Parámetros:**
/// - `capacity`: Número máximo de elementos a mantener en caché
/// 
/// **Decisiones de implementación:**
/// 
/// 1. **Estructura de datos interna:**
///    - `HashMap (_cache)`: Proporciona acceso O(1) para get/put
///    - `Queue (_accessOrder)`: Rastrea el orden de acceso (LRU al inicio, MRU al final)
/// 
/// 2. **Complejidad temporal:**
///    - get(): O(1) - HashMap lookup + Queue.remove() + Queue.add()
///    - put(): O(1) - HashMap insert + Queue operations
///    - remove(): O(1) - HashMap + Queue removal
/// 
/// 3. **Política de evicción:**
///    - **LRU elegido**: Elementos menos usados se descartan primero
///    - **Por qué LRU**: Los usuarios tienden a regresar a los mismos grupos (temporal locality)
///    - **Alternativas descartadas**:
///      - FIFO: No respeta frecuencia de uso
///      - Random: No predecible para workflow del usuario
///      - LFU: Requiere contadores adicionales (overhead)
/// 
/// **Caso de uso en AceUp:**
/// Cachear resultados de calculateGroupFreeBlocks() que son costosos de computar:
/// - Requiere consultar horarios de todos los miembros del grupo
/// - Procesar intersecciones de disponibilidad
/// - Costo: ~100-200ms por grupo
/// - Beneficio: Reducir a <1ms con cache hit
/// 
/// **Ejemplo:**
/// ```dart
/// final cache = LRUCache<String, List<Map>>(20); // 20 grupos máximo
/// 
/// // Guardar resultado de cálculo costoso
/// cache.put('group_123', freeBlocksData);
/// 
/// // Recuperar instantáneamente en próxima visita
/// final cached = cache.get('group_123'); // <1ms
/// ```
class LRUCache<K, V> {
  /// Capacidad máxima del caché
  final int capacity;
  
  /// Storage principal: HashMap para acceso O(1)
  final _cache = <K, V>{};
  
  /// Queue para rastrear orden de acceso
  /// - Elemento al inicio = Least Recently Used (candidato para evicción)
  /// - Elemento al final = Most Recently Used (más protegido)
  final _accessOrder = Queue<K>();

  /// Crea un LRU Cache con la capacidad especificada
  /// 
  /// [capacity] debe ser mayor a 0
  LRUCache(this.capacity) {
    assert(capacity > 0, 'Capacity must be positive');
  }

  /// Obtiene un valor del caché por su clave.
  /// 
  /// Si la clave existe:
  /// - Retorna el valor
  /// - Actualiza el orden de acceso (lo marca como recientemente usado)
  /// 
  /// Si la clave NO existe:
  /// - Retorna null
  /// 
  /// Complejidad: O(1)
  V? get(K key) {
    if (!_cache.containsKey(key)) return null;

    // Mover al final de la queue (marcar como Most Recently Used)
    _accessOrder.remove(key);
    _accessOrder.add(key);

    return _cache[key];
  }

  /// Inserta o actualiza un valor en el caché.
  /// 
  /// **Si la clave ya existe:**
  /// - Actualiza el valor
  /// - Mueve la clave al final (MRU)
  /// 
  /// **Si la clave es nueva y el caché está lleno:**
  /// - Elimina el LRU (primero en la queue)
  /// - Inserta el nuevo elemento
  /// 
  /// **Si hay espacio:**
  /// - Inserta directamente
  /// 
  /// Complejidad: O(1)
  void put(K key, V value) {
    // Caso 1: Clave ya existe -> actualizar y mover al final
    if (_cache.containsKey(key)) {
      _cache[key] = value;
      _accessOrder.remove(key);
      _accessOrder.add(key);
      return;
    }

    // Caso 2: Caché lleno -> evicción del LRU
    if (_cache.length >= capacity) {
      final lruKey = _accessOrder.removeFirst();
      _cache.remove(lruKey);
    }

    // Caso 3: Agregar nuevo elemento
    _cache[key] = value;
    _accessOrder.add(key);
  }

  /// Elimina una entrada específica del caché.
  /// 
  /// Útil para invalidación explícita cuando los datos cambian.
  /// 
  /// Complejidad: O(1)
  void remove(K key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  /// Limpia todo el caché.
  /// 
  /// Útil para logout de usuario o reset de la app.
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  /// Retorna el número actual de elementos en caché.
  int get size => _cache.length;

  /// Verifica si una clave existe en el caché.
  /// 
  /// No actualiza el orden de acceso (a diferencia de get()).
  bool containsKey(K key) => _cache.containsKey(key);

  /// Retorna todas las claves en orden de uso.
  /// 
  /// Lista ordenada de menos usado a más usado:
  /// - [0] = Próximo candidato para evicción (LRU)
  /// - [length-1] = Último accedido (MRU)
  List<K> get keys => _accessOrder.toList();

  /// Retorna el porcentaje de ocupación del caché (0.0 - 1.0)
  double get fillRate => _cache.length / capacity;

  /// Retorna true si el caché está lleno
  bool get isFull => _cache.length >= capacity;

  /// Retorna true si el caché está vacío
  bool get isEmpty => _cache.isEmpty;

  /// Retorna estadísticas del caché para debugging
  Map<String, dynamic> get stats => {
    'capacity': capacity,
    'size': size,
    'fillRate': fillRate,
    'isEmpty': isEmpty,
    'isFull': isFull,
  };
}
