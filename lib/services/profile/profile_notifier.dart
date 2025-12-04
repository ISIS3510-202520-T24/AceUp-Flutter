import 'package:flutter/foundation.dart';

class ProfileNotifier extends ChangeNotifier {
  String _nickname = 'Student';
  String? _avatarLocalPath;

  String get nickname => _nickname;
  String? get avatarLocalPath => _avatarLocalPath;

  void setAll({
    required String nickname,
    String? avatarLocalPath,
  }) {
    _nickname = nickname;
    _avatarLocalPath = avatarLocalPath;
    notifyListeners();
  }

  void updateAvatar(String? newPath) {
    _avatarLocalPath = newPath;
    notifyListeners();
  }

  void updateNickname(String newNick) {
    _nickname = newNick;
    notifyListeners();
  }
}
