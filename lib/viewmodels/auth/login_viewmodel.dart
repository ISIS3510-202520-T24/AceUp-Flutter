import 'package:firebase_auth/firebase_auth.dart'; //ignore: uri_does_not_exist
import '../../core/observer/observable.dart';
import '../../models/auth_model.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/biometric_service.dart';
import '../../services/auth/secure_store.dart';

// ignore_for_file: type_test_with_undefined_name

class LoginViewModel extends Observable {
  final AuthService _auth;
  final BiometricService _bio;

  LoginViewModel(this._auth, this._bio);

  LoginForm _form = const LoginForm();
  bool _loading = false;
  String? _error;

  // ==== Getters para la UI ====
  LoginForm get form => _form;
  bool get loading => _loading;
  String? get error => _error;

  /// Texto de saludo
  String get displayNameOrEmail {
    final u = _auth.currentUser;
    if (u == null) return '';
    final name = (u.displayName ?? '').trim();
    if (name.isNotEmpty) return name;
    final email = u.email ?? '';
    return email.contains('@') ? email.split('@').first : email;
  }

  /// Lo usa el FutureBuilder del botón biométrico
  Future<bool> canUseBiometrics() => _bio.canUseBiometrics();

  // ==== Mutaciones ====
  void setEmail(String v) {
    _form = _form.copyWith(email: v);
    _error = null;
    notify();
  }

  void setPassword(String v) {
    _form = _form.copyWith(password: v);
    _error = null;
    notify();
  }

  // ==== Acciones ====
  Future<AuthResult> login() async {
    final e1 = LoginForm.validateEmail(_form.email);
    final e2 = LoginForm.validatePassword(_form.password);
    if (e1 != null || e2 != null) {
      final msg = e1 ?? e2 ?? 'Fix the errors';
      _error = msg;
      notify();
      return AuthResult.fail(msg);
    }

    _loading = true;
    _error = null;
    notify();

    try {
      await _auth.signInEmailPassword(
        email: _form.email,
        password: _form.password,
      );
      await _auth.reloadUser();

      if (!_auth.isEmailVerified) {
        await _auth.signOut();
        return const AuthResult(
          ok: false,
          message: 'Please verify your email to continue',
          needsEmailVerification: true,
        );
      }
      return AuthResult.success();
    } catch (e) {
      final msg = _friendlyAuthMessage(e);
      _error = msg;
      notify();
      return AuthResult.fail(msg);
    } finally {
      _loading = false;
      notify();
    }
  }

  Future<AuthResult> forgotPassword(String email) async {
    final err = LoginForm.validateEmail(email);
    if (err != null) return AuthResult.fail(err);
    try {
      await _auth.requestPasswordReset(email.trim());
      return AuthResult.success('We sent you a reset link');
    } catch (e) {
      return AuthResult.fail(_friendlyAuthMessage(e));
    }
  }

  Future<void> resendVerificationEmail() => _auth.sendEmailVerification();

  Future<AuthResult> loginWithBiometrics() async {
    final supported = await _bio.canUseBiometrics();
    if (!supported) {
      return AuthResult.fail('Biometrics not supported/enrolled');
    }
    final ok = await _bio.authenticate();
    if (!ok) return AuthResult.fail('Biometric cancelled / failed');

    final creds = await SecureStore.biometricCredentials();
    final email = creds.email;
    final pass = creds.password;
    if (email == null || pass == null) {
      return AuthResult.fail(
        'No saved credentials. Sign in once with email & password.',
      );
    }

    _loading = true;
    _error = null;
    notify();

    try {
      await _auth.signInEmailPassword(email: email, password: pass);
      await _auth.reloadUser();
      if (!_auth.isEmailVerified) {
        await _auth.signOut();
        return const AuthResult(
          ok: false,
          message: 'Please verify your email to continue',
          needsEmailVerification: true,
        );
      }
      return AuthResult.success();
    } catch (e) {
      final msg = _friendlyAuthMessage(e);
      _error = msg;
      notify();
      return AuthResult.fail(msg);
    } finally {
      _loading = false;
      notify();
    }
  }

  Future<String?> debugBiometricSummary() => _bio.debugSummary();

  Future<BiometricCheck> biometricPostLoginCheck(String newEmail) async {
    final supported = await _bio.canUseBiometrics();
    if (!supported) {
      return BiometricCheck(supported: false, enabled: false);
    }
    final enabled = await SecureStore.biometricEnabled();
    final stored = await SecureStore.biometricCredentials();
    return BiometricCheck(
      supported: true,
      enabled: enabled,
      storedEmail: stored.email,
    );
  }

  Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    await SecureStore.setBiometricEnabled(true);
    await SecureStore.setLastEmail(email);
    await SecureStore.setBiometricCredentials(email, password);
  }

  Future<void> clearBiometricCredentials() async {
    await SecureStore.setBiometricEnabled(false);
    await SecureStore.clearBiometricCredentials();
  }

  Future<void> signOut() => _auth.signOut();

  // ==== Helpers ====
  String _friendlyAuthMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
          return 'Wrong email or password.';
        case 'user-not-found':
          return 'No account found with that email.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Try again in a moment.';
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
