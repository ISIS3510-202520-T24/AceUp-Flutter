// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visited_group_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VisitedGroupHistoryAdapter extends TypeAdapter<VisitedGroupHistory> {
  @override
  final int typeId = 0;

  @override
  VisitedGroupHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisitedGroupHistory(
      groupId: fields[0] as String,
      groupName: fields[1] as String,
      lastVisited: fields[2] as DateTime,
      visitCount: fields[3] as int,
      groupAvatarUrl: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VisitedGroupHistory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.groupId)
      ..writeByte(1)
      ..write(obj.groupName)
      ..writeByte(2)
      ..write(obj.lastVisited)
      ..writeByte(3)
      ..write(obj.visitCount)
      ..writeByte(4)
      ..write(obj.groupAvatarUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitedGroupHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
