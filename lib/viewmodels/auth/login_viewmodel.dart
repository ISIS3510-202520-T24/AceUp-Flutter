import 'package:firebase_auth/firebase_auth.dart'; //ignore: uri_does_not_exist
import '../../core/observer/observable.dart';
import '../../models/auth_model.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/biometric_service.dart';
import '../../services/auth/secure_store.dart';
import '../../services/auth/offline_auth_service.dart';

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
    // ONLINE primero
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

    // === Opt-in automático: habilitar offline + cachear settings ===
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await OfflineAuthService.enableOfflineForCredentials(
        email: _form.email,
        password: _form.password,
        uid: uid,
      );

      // puedes ajustar estos defaults; son livianos y seguros
      await OfflineAuthService.cacheUserSettings(
        uid: uid,
        settings: {
          "theme": "system",
          "notifications": true,
          "favoriteGroups": <String>[],
        },
      );
    }

    return AuthResult.success();
  } catch (e) {
    // Fallback OFFLINE por red caída: email + password (PBKDF2 local)
    final ok = await OfflineAuthService.tryOfflinePassword(
      email: _form.email,
      password: _form.password,
    );
    if (ok) {
      final info = await OfflineAuthService.offlineSessionInfo();
      if (info.uid != null && info.email != null) {
        _auth.startOfflineSession(uid: info.uid!, email: info.email!);
        return const AuthResult(ok: true, message: 'Signed in offline');
        }
    }

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
  if (!supported) return AuthResult.fail('Biometrics not supported/enrolled');

  final okBio = await _bio.authenticate();
  if (!okBio) return AuthResult.fail('Biometric cancelled / failed');

  final creds = await SecureStore.biometricCredentials();
  final email = creds.email;
  final pass  = creds.password;
  if (email == null || pass == null) {
    return AuthResult.fail('No saved credentials. Sign in once with email & password.');
  }

  _loading = true;
  _error = null;
  notify();

  try {
    // ONLINE primero
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

    // === Opt-in automático: habilitar offline + cachear settings ===
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await OfflineAuthService.enableOfflineForCredentials(
        email: email,
        password: pass,
        uid: uid,
      );

      await OfflineAuthService.cacheUserSettings(
        uid: uid,
        settings: {
          "theme": "system",
          "notifications": true,
          "favoriteGroups": <String>[],
        },
      );
    }

    return AuthResult.success();
  } catch (e) {
    // Fallback OFFLINE por red caída: biometría + sesión local habilitada
    final can = await OfflineAuthService.tryOfflineBiometric();
    if (can) {
      final info = await OfflineAuthService.offlineSessionInfo();
      if (info.uid != null && info.email != null) {
        _auth.startOfflineSession(uid: info.uid!, email: info.email!);
        return const AuthResult(ok: true, message: 'Signed in offline');
      }
    }

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
    /// Llamar tras un login ONLINE exitoso, si el usuario acepta el prompt.
  Future<void> enableOfflineWithCurrentCredentials() async {
    final uid = _auth.currentUser?.uid;
    final email = _form.email;
    final password = _form.password;
    if (uid != null && email.isNotEmpty && password.isNotEmpty) {
      await OfflineAuthService.enableOfflineForCredentials(
        email: email,
        password: password,
        uid: uid,
      );
    }
  }

  /// Guarda user settings en SharedPreferences (JSON) para mejor UX offline.
  Future<void> cacheUserSettingsOffline(Map<String, dynamic> settings) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    await OfflineAuthService.cacheUserSettings(uid: uid, settings: settings);
  }
    /// Limpia toda la huella de sesión offline (SecureStorage + estado en AuthService).
  Future<void> clearOfflineSession() async {
    _auth.clearOfflineSession();                 // borra uid/email offline en AuthService
    await OfflineAuthService.disableOffline();   // borra claves/salt/hash/flags en SecureStorage
    notify();                                    // por si alguna UI muestra estado de sesión
  }

  /// Cierra sesión completa respetando MVVM (online + offline).
  Future<void> signOutAll() async {
    await _auth.signOut();       // tu signOut normal (Firebase)
    await clearOfflineSession(); // y luego limpieza offline
  }


}
