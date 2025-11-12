// lib/models/visited_group_history.dart
// Modelo para almacenar el historial de grupos visitados usando Hive

import 'package:hive/hive.dart';

part 'visited_group_history.g.dart';

@HiveType(typeId: 0)
class VisitedGroupHistory {
  @HiveField(0)
  final String groupId;
  
  @HiveField(1)
  final String groupName;
  
  @HiveField(2)
  final DateTime lastVisited;
  
  @HiveField(3)
  final int visitCount;
  
  @HiveField(4)
  final String? groupAvatarUrl;

  VisitedGroupHistory({
    required this.groupId,
    required this.groupName,
    required this.lastVisited,
    this.visitCount = 1,
    this.groupAvatarUrl,
  });

  VisitedGroupHistory copyWith({
    String? groupId,
    String? groupName,
    DateTime? lastVisited,
    int? visitCount,
    String? groupAvatarUrl,
  }) {
    return VisitedGroupHistory(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      lastVisited: lastVisited ?? this.lastVisited,
      visitCount: visitCount ?? this.visitCount,
      groupAvatarUrl: groupAvatarUrl ?? this.groupAvatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'lastVisited': lastVisited.toIso8601String(),
      'visitCount': visitCount,
      'groupAvatarUrl': groupAvatarUrl,
    };
  }

  factory VisitedGroupHistory.fromJson(Map<String, dynamic> json) {
    return VisitedGroupHistory(
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      lastVisited: DateTime.parse(json['lastVisited'] as String),
      visitCount: json['visitCount'] as int? ?? 1,
      groupAvatarUrl: json['groupAvatarUrl'] as String?,
    );
  }

  @override
  String toString() {
    return 'VisitedGroupHistory(groupId: $groupId, groupName: $groupName, visitCount: $visitCount, lastVisited: $lastVisited)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is VisitedGroupHistory &&
      other.groupId == groupId &&
      other.groupName == groupName &&
      other.lastVisited == lastVisited &&
      other.visitCount == visitCount &&
      other.groupAvatarUrl == groupAvatarUrl;
  }

  @override
  int get hashCode {
    return groupId.hashCode ^
      groupName.hashCode ^
      lastVisited.hashCode ^
      visitCount.hashCode ^
      groupAvatarUrl.hashCode;
  }
}
