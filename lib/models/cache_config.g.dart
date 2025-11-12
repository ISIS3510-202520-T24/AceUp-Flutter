// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheConfigAdapter extends TypeAdapter<CacheConfig> {
  @override
  final int typeId = 1;

  @override
  CacheConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheConfig(
      maxCacheSize: fields[0] as int,
      cacheDuration: fields[1] as Duration?,
      enableImageCache: fields[2] as bool,
      enableEventsCache: fields[3] as bool,
      lastCacheCleared: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CacheConfig obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.maxCacheSize)
      ..writeByte(1)
      ..write(obj.cacheDuration)
      ..writeByte(2)
      ..write(obj.enableImageCache)
      ..writeByte(3)
      ..write(obj.enableEventsCache)
      ..writeByte(4)
      ..write(obj.lastCacheCleared);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
