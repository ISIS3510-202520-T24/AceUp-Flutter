import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String nickname;
  final String? avatar;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.uid,
    required this.email,
    required this.nickname,
    this.avatar,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      avatar: data['avatar'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      avatar: json['avatar'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      lastLogin: json['lastLogin'] is Timestamp
          ? (json['lastLogin'] as Timestamp).toDate()
          : DateTime.tryParse(json['lastLogin']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      // Note: uid is the document ID, not stored as a field
      'email': email,
      'nickname': nickname,
      if (avatar != null) 'avatar': avatar,
      'createdAt': Timestamp.fromDate(createdAt),
      if (lastLogin != null) 'lastLogin': Timestamp.fromDate(lastLogin!),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      if (avatar != null) 'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? nickname,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, nickname: $nickname)';
  }
}