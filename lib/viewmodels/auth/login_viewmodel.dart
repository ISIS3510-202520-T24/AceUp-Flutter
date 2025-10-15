import 'package:flutter/foundation.dart';
import '../../services/auth/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _auth;
  LoginViewModel(this._auth);

  bool _loading = false;
  bool get loading => _loading;

  Future<(bool, String?)> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      _loading = true; notifyListeners();
      await _auth.signInEmailPassword(email: email, password: password);
      return (true, null);
    } catch (e) {
      return (false, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _loading = false; notifyListeners();
    }
  }
}
