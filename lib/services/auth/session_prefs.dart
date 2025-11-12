import 'package:shared_preferences/shared_preferences.dart';

class SessionPrefs {
  static const _kWasLoggedIn = 'wasLoggedIn';

  static Future<bool> getWasLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kWasLoggedIn) ?? false;
  }

  static Future<void> setWasLoggedIn(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kWasLoggedIn, value);
  }
}
