import 'package:firebase_auth/firebase_auth.dart';

import '../core/observer/observable.dart';
import '../models/signup_model.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

class SignUpViewModel extends Observable {
  final AuthService _auth;

  SignUpForm _form = const SignUpForm();
  bool _loading = false;
  String? _error;
  String? _info;

  SignUpViewModel(this._auth);

  // === Getters UI ===
  SignUpForm get form => _form;
  bool get loading => _loading;
  String? get error => _error;
  String? get info => _info;

  // === Mutaciones ===
  void setNick(String v)    { _form = _form.copyWith(nickname: v); _clear(); }
  void setEmail(String v)   { _form = _form.copyWith(email: v);    _clear(); }
  void setPass(String v)    { _form = _form.copyWith(password: v); _clear(); }
  void setConfirm(String v) { _form = _form.copyWith(confirm: v);  _clear(); }
  void setAccept(bool v)    { _form = _form.copyWith(acceptTerms: v); _clear(); }

  String? get nickError    => SignUpForm.validateNick(_form.nickname);
  String? get emailError   => SignUpForm.validateEmail(_form.email);
  String? get passError    => SignUpForm.validatePassword(_form.password);
  String? get confirmError => SignUpForm.validateConfirm(_form.password, _form.confirm);
  String? get termsError   => SignUpForm.validateTerms(_form.acceptTerms);

  // === Acción ===
  Future<AuthResult> submit() async {
    if (!_form.isValid) {
      final msg = nickError ?? emailError ?? passError ?? confirmError ?? termsError ?? 'Fix the errors';
      _error = msg; notify(); return AuthResult.fail(msg);
    }

    _loading = true; _error = null; _info = null; notify();

    try {
      await _auth.signUpEmailPassword(
        email: _form.email,
        password: _form.password,
        displayName: _form.nickname,
      );
      await _auth.sendEmailVerification();
      _info = 'We sent you a verification email';
      notify();
      return AuthResult.success(_info);
    } on FirebaseAuthException catch (e) {
      final msg = _friendlyAuthMessage(e);
      _error = msg; notify();
      return AuthResult.fail(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _error = msg; notify();
      return AuthResult.fail(msg);
    } finally {
      _loading = false; notify();
    }
  }

  // === Helpers ===
  void _clear() { _error = null; _info = null; notify(); }

  String _friendlyAuthMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'That email is already registered.';
        case 'invalid-email':
          return 'Enter a valid email.';
        case 'operation-not-allowed':
          return 'Registration not allowed for this project.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'network-request-failed':
          return 'Network error. Check your connection.';
        default:
          return 'Could not complete the request.';
      }
    }
    final s = error.toString();
    return s.replaceFirst('Exception: ', '');
  }
}
