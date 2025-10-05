import '../services/auth_service.dart';

class SignUpViewModel {
  final AuthService _auth;
  SignUpViewModel(this._auth);

  Future<(bool, String?)> signUpWithEmailPassword({
    required String nickname,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signUpEmailPassword(
        email: email,
        password: password,
        displayName: nickname,
      );
      await _auth.sendEmailVerification(); // << envía correo
      return (true, null);
    } catch (e) {
      return (false, e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
