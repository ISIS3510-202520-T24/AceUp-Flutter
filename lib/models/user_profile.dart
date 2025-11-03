// lib/models/user_profile.dart
import 'dart:convert';

class UserProfile {
  final String email;
  final String nickname;

  /// Puede ser:
  /// "asset:assets/avatars/avatar_1.png"
  /// ó ruta local en disco /data/user/.../profiles/<email_sanitizado>_avatar.jpg
  final String? avatarLocalPath;

  const UserProfile({
    required this.email,
    required this.nickname,
    this.avatarLocalPath,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'nickname': nickname,
        'avatarLocalPath': avatarLocalPath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      avatarLocalPath: json['avatarLocalPath'],
    );
  }

  static UserProfile? fromJsonString(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  String toJsonString() => jsonEncode(toJson());

  UserProfile copyWith({
    String? email,
    String? nickname,
    String? avatarLocalPath,
  }) {
    return UserProfile(
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
    );
  }
}
