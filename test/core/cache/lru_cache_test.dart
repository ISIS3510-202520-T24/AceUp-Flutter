// test/core/cache/lru_cache_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:aceup_clean/core/cache/lru_cache.dart';

void main() {
  group('LRUCache', () {
    test('should store and retrieve values', () {
      final cache = LRUCache<String, int>(3);
      
      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      
      expect(cache.get('a'), 1);
      expect(cache.get('b'), 2);
      expect(cache.get('c'), 3);
      expect(cache.size, 3);
    });

    test('should evict least recently used when capacity is reached', () {
      final cache = LRUCache<String, int>(3);
      
      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      
      // Access 'a' to make it recently used
      cache.get('a');
      
      // Add 'd' - should evict 'b' (least recently used)
      cache.put('d', 4);
      
      expect(cache.get('a'), 1); // Still there
      expect(cache.get('b'), null); // Evicted
      expect(cache.get('c'), 3); // Still there
      expect(cache.get('d'), 4); // New one
      expect(cache.size, 3);
    });

    test('should update existing key without eviction', () {
      final cache = LRUCache<String, int>(2);
      
      cache.put('a', 1);
      cache.put('b', 2);
      
      // Update 'a'
      cache.put('a', 10);
      
      expect(cache.get('a'), 10);
      expect(cache.size, 2);
    });

    test('should maintain LRU order correctly', () {
      final cache = LRUCache<String, int>(3);
      
      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      
      // Access order: a, b, c (c is MRU)
      expect(cache.keys, ['a', 'b', 'c']);
      
      // Access 'a' -> order becomes: b, c, a
      cache.get('a');
      expect(cache.keys, ['b', 'c', 'a']);
      
      // Add 'd' -> evicts 'b', order becomes: c, a, d
      cache.put('d', 4);
      expect(cache.keys, ['c', 'a', 'd']);
    });

    test('should handle remove operation', () {
      final cache = LRUCache<String, int>(3);
      
      cache.put('a', 1);
      cache.put('b', 2);
      
      cache.remove('a');
      
      expect(cache.get('a'), null);
      expect(cache.size, 1);
      expect(cache.containsKey('a'), false);
    });

    test('should clear all entries', () {
      final cache = LRUCache<String, int>(3);
      
      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      
      cache.clear();
      
      expect(cache.size, 0);
      expect(cache.isEmpty, true);
      expect(cache.get('a'), null);
    });

    test('should calculate fill rate correctly', () {
      final cache = LRUCache<String, int>(5);
      
      expect(cache.fillRate, 0.0);
      
      cache.put('a', 1);
      cache.put('b', 2);
      expect(cache.fillRate, 0.4); // 2/5
      
      cache.put('c', 3);
      cache.put('d', 4);
      cache.put('e', 5);
      expect(cache.fillRate, 1.0); // 5/5
      expect(cache.isFull, true);
    });

    test('should provide correct stats', () {
      final cache = LRUCache<String, int>(10);
      
      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      
      final stats = cache.stats;
      
      expect(stats['capacity'], 10);
      expect(stats['size'], 3);
      expect(stats['fillRate'], 0.3);
      expect(stats['isEmpty'], false);
      expect(stats['isFull'], false);
    });

    test('should handle complex objects as values', () {
      final cache = LRUCache<String, List<Map<String, dynamic>>>(2);
      
      final blocks1 = [
        {'weekday': 1, 'startHour': 8, 'members': ['alice', 'bob']},
        {'weekday': 2, 'startHour': 10, 'members': ['charlie']},
      ];
      
      final blocks2 = [
        {'weekday': 3, 'startHour': 14, 'members': ['david', 'eve']},
      ];
      
      cache.put('group_1', blocks1);
      cache.put('group_2', blocks2);
      
      final retrieved = cache.get('group_1');
      expect(retrieved, blocks1);
      expect(retrieved?[0]['members'], ['alice', 'bob']);
    });
  });
}
