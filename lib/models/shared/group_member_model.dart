import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMember {
  final String userId;
  final String nickname;
  final DateTime joinedAt;

  GroupMember({
    required this.userId,
    required this.nickname,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: json['userId'] ?? '',
      nickname: json['nickname'] ?? '',
      joinedAt: json['joinedAt'] is Timestamp
          ? (json['joinedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['joinedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  Map<String, dynamic> toJsonLocal() {
    return {
      'userId': userId,
      'nickname': nickname,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  GroupMember copyWith({
    String? userId,
    String? nickname,
    DateTime? joinedAt,
  }) {
    return GroupMember(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  String toString() {
    return 'GroupMember(userId: $userId, nickname: $nickname)';
  }
}