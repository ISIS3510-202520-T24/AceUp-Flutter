// lib/models/cache_config.dart
// Configuración de cache almacenada en Hive

import 'package:hive/hive.dart';

part 'cache_config.g.dart';

@HiveType(typeId: 1)
class CacheConfig {
  @HiveField(0)
  final int maxCacheSize;
  
  @HiveField(1)
  final Duration cacheDuration;
  
  @HiveField(2)
  final bool enableImageCache;
  
  @HiveField(3)
  final bool enableEventsCache;
  
  @HiveField(4)
  final DateTime lastCacheCleared;

  CacheConfig({
    this.maxCacheSize = 50,
    Duration? cacheDuration,
    this.enableImageCache = true,
    this.enableEventsCache = true,
    DateTime? lastCacheCleared,
  }) : cacheDuration = cacheDuration ?? const Duration(hours: 24),
       lastCacheCleared = lastCacheCleared ?? DateTime.now();

  CacheConfig copyWith({
    int? maxCacheSize,
    Duration? cacheDuration,
    bool? enableImageCache,
    bool? enableEventsCache,
    DateTime? lastCacheCleared,
  }) {
    return CacheConfig(
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      cacheDuration: cacheDuration ?? this.cacheDuration,
      enableImageCache: enableImageCache ?? this.enableImageCache,
      enableEventsCache: enableEventsCache ?? this.enableEventsCache,
      lastCacheCleared: lastCacheCleared ?? this.lastCacheCleared,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxCacheSize': maxCacheSize,
      'cacheDurationMinutes': cacheDuration.inMinutes,
      'enableImageCache': enableImageCache,
      'enableEventsCache': enableEventsCache,
      'lastCacheCleared': lastCacheCleared.toIso8601String(),
    };
  }

  factory CacheConfig.fromJson(Map<String, dynamic> json) {
    return CacheConfig(
      maxCacheSize: json['maxCacheSize'] as int? ?? 50,
      cacheDuration: Duration(minutes: json['cacheDurationMinutes'] as int? ?? 1440),
      enableImageCache: json['enableImageCache'] as bool? ?? true,
      enableEventsCache: json['enableEventsCache'] as bool? ?? true,
      lastCacheCleared: json['lastCacheCleared'] != null 
        ? DateTime.parse(json['lastCacheCleared'] as String)
        : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'CacheConfig(maxSize: $maxCacheSize, duration: ${cacheDuration.inHours}h, images: $enableImageCache, events: $enableEventsCache)';
  }
}
