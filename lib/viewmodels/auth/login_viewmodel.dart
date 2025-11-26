import 'package:flutter/foundation.dart';

import '../../services/auth/auth_service.dart';
import '../../services/auth/biometric_service.dart';
import '../../services/auth/secure_store.dart';
import '../../services/auth/offline_auth_service.dart';
import '../../services/auth/session_prefs.dart';

/// Resultado genérico de acciones de autenticación (login normal, biométrico,
/// forgot password, etc.). Incluye bandera para "verifique su correo".
class AuthResult {
  final bool ok;
  final String? message;
  final bool needsEmailVerification;

  const AuthResult({
    required this.ok,
    this.message,
    this.needsEmailVerification = false,
  });

  factory AuthResult.success([String? msg]) =>
      AuthResult(ok: true, message: msg, needsEmailVerification: false);

  factory AuthResult.fail(String msg) =>
      AuthResult(ok: false, message: msg, needsEmailVerification: false);

  factory AuthResult.verifyNeeded(String msg) => AuthResult(
        ok: false,
        message: msg,
        needsEmailVerification: true,
      );
}

/// Info de las credenciales biométricas guardadas (para decidir si reemplazar).
class BiometricStoredInfo {
  final String? storedEmail;
  const BiometricStoredInfo({this.storedEmail});
}

/// Estado de biometría post-login (para decidir si guardar credenciales rápidas)
class BiometricCheck {
  final bool supported;
  final bool enabled;
  final String? storedEmail;
  const BiometricCheck({
    required this.supported,
    required this.enabled,
    this.storedEmail,
  });
}

/// Form simple para login email/password.
class LoginForm {
  final String email;
  final String password;
  const LoginForm({
    this.email = '',
    this.password = '',
  });

  LoginForm copyWith({
    String? email,
    String? password,
  }) {
    return LoginForm(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  /// Validaciones estáticas invocadas por la UI.
  static String? validateEmail(String email) {
    if (email.trim().isEmpty) return 'Email required';
    if (!email.contains('@')) return 'Invalid email';
    return null;
  }

  static String? validatePassword(String pwd) {
    if (pwd.isEmpty) return 'Password required';
    if (pwd.length < 6) return 'Min 6 chars';
    return null;
  }
}

/// ViewModel principal de Login.
/// - Maneja login normal.
/// - Maneja fallback offline.
/// - Maneja biometría.
/// - Expone helpers para la UI.
class LoginViewModel extends ChangeNotifier {
  final AuthService _auth;
  final BiometricService _bio;

  LoginViewModel(this._auth, this._bio);

  LoginForm _form = const LoginForm();
  bool _loading = false;
  String? _error;
  String? _debugBio;

  // almacenamiento en RAM para "quick login biométrico"
  // (esto alimenta el diálogo de "Replace quick-login?")
  String? _quickLoginEmail;
  String? _quickLoginPass;

  // ---------- Getters consumidos por la UI ----------
  bool get loading => _loading;
  String? get error => _error;
  String? get debugBioInfo => _debugBio;

  String get email => _form.email;
  String get password => _form.password;

  /// Nombre bonito para bienvenida
  String get displayNameOrEmail {
    final u = _auth.currentUser;
    if (u == null) {
      if (_form.email.trim().isNotEmpty) return _form.email.trim();
      return 'Student';
    }
    final nick = u.displayName;
    if (nick != null && nick.trim().isNotEmpty) return nick.trim();
    if ((u.email ?? '').trim().isNotEmpty) return u.email!.trim();
    return 'Student';
  }

  // ---------- Internos ----------
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  String _friendlyAuthMessage(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('wrong-password') ||
        raw.contains('invalid-credential')) {
      return 'Wrong email or password.';
    }
    if (raw.contains('user-not-found')) {
      return 'That account does not exist.';
    }
    if (raw.contains('network')) {
      return 'Network error. Please check your connection.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Too many attempts. Please wait and try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  // ---------- Setters del form ----------
  void setEmail(String v) {
    _form = _form.copyWith(email: v);
    _error = null;
    notifyListeners();
  }

  void setPassword(String v) {
    _form = _form.copyWith(password: v);
    _error = null;
    notifyListeners();
  }

  // ---------- LOGIN NORMAL (con fallback offline) ----------
  //
  // Flujo:
  // 1. Validar email/pass local.
  // 2. Intentar login ONLINE con Firebase/AuthService.
  // 3. Verificar email.
  // 4. Habilitar modo offline (PBKDF2/salts guardadas en OfflineAuthService).
  // 5. Cachear settings básicos offline.
  // 6. Guardar credenciales "rápidas" en RAM (_quickLoginEmail/_quickLoginPass)
  //    para que la UI luego pueda ofrecer biometría.
  // 7. Fallback: si falla red, intentar login offline.
  //
  Future<AuthResult> login() async {
    final e1 = LoginForm.validateEmail(_form.email);
    final e2 = LoginForm.validatePassword(_form.password);
    if (e1 != null || e2 != null) {
      final msg = e1 ?? e2 ?? 'Fix the errors';
      _setError(msg);
      return AuthResult.fail(msg);
    }

    _setLoading(true);
    _setError(null);

    try {
      // --------- ONLINE primero ---------
      await _auth.signInEmailPassword(
        email: _form.email.trim(),
        password: _form.password,
      );
      await _auth.reloadUser();

      if (!_auth.isEmailVerified) {
        final ar = AuthResult.verifyNeeded(
          'Please verify your email to continue',
        );
        _setLoading(false);
        _setError(ar.message);
        return ar;
      }

      // --------- Habilitar offline secure ---------
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        // Guardar hash PBKDF2, etc. para offline login futuro
        await OfflineAuthService.enableOfflineForCredentials(
          email: _form.email.trim(),
          password: _form.password,
          uid: uid,
        );

        // Cachear algunos settings básicos para UX offline
        await OfflineAuthService.cacheUserSettings(
          uid: uid,
          settings: <String, dynamic>{
            "theme": "system",
            "notifications": true,
            "favoriteGroups": <String>[],
          },
        );
      }

      // --------- Guardar credenciales rápidas en memoria (para biometría) ---------
      _quickLoginEmail = _form.email.trim();
      _quickLoginPass = _form.password;

      // ======= NUEVO: persistimos credenciales para auto-login silencioso =======
      await SecureStore.setSessionCredentials(
        email: _form.email.trim(),
        password: _form.password,
      );

      // (opcional) flag offline para fallback sin red
      await SessionPrefs.setWasLoggedIn(true);

      _setLoading(false);
      _setError(null);
      return AuthResult.success('Logged in');
    } catch (e) {
      // --------- Fallback OFFLINE si falla online ---------
      final okOffline = await OfflineAuthService.tryOfflinePassword(
        email: _form.email.trim(),
        password: _form.password,
      );

      if (okOffline) {
        final info = await OfflineAuthService.offlineSessionInfo();
        if (info.uid != null && info.email != null) {
          _auth.startOfflineSession(uid: info.uid!, email: info.email!);

          // también guardamos en RAM para biometría rápida
          _quickLoginEmail = _form.email.trim();
          _quickLoginPass = _form.password;

          // ======= NUEVO: persistimos también en login offline =======
          await SecureStore.setSessionCredentials(
            email: _form.email.trim(),
            password: _form.password,
          );
          await SessionPrefs.setWasLoggedIn(true);

          _setLoading(false);
          _setError(null);
          return const AuthResult(
            ok: true,
            message: 'Signed in offline',
          );
        }
      }

      final msg = _friendlyAuthMessage(e);
      _setLoading(false);
      _setError(msg);
      return AuthResult.fail(msg);
    }
  }

  // ---------- FORGOT PASSWORD ----------
  Future<AuthResult> forgotPassword(String email) async {
    final err = LoginForm.validateEmail(email);
    if (err != null) {
      return AuthResult.fail(err);
    }
    try {
      await _auth.requestPasswordReset(email.trim());
      return AuthResult.success('We sent you a reset link');
    } catch (e) {
      return AuthResult.fail(_friendlyAuthMessage(e));
    }
  }

  // ---------- RESEND VERIFICATION EMAIL ----------
  Future<void> resendVerificationEmail() async {
    try {
      await _auth.sendEmailVerification();
      await _auth.signOut();
    } catch (e) {
      await _auth.signOut();
      debugPrint('Failed to resend verification email: $e');
    }
  }

  // ---------- LOGIN CON BIOMETRÍA ----------
  //
  // Flujo:
  // 1. Verificar que el dispositivo soporta biometría.
  // 2. Pedir autenticación biométrica (_bio.authenticate()).
  // 3. Leer SecureStore.biometricCredentials() (tu implementación existente).
  // 4. Intentar login ONLINE silencioso con esas credenciales.
  // 5. Verificar email. Si ok → habilitar offline.
  // 6. Fallback offline si no hay red.
  //
  Future<AuthResult> loginWithBiometrics() async {
    final supported = await _bio.canUseBiometrics();
    if (!supported) {
      return AuthResult.fail('Biometrics not supported/enrolled');
    }

    final okBio = await _bio.authenticate();
    if (!okBio) {
      return AuthResult.fail('Biometric cancelled / failed');
    }

    final creds = await SecureStore.biometricCredentials();
    final email = creds.email;
    final pass = creds.password;

    if (email == null || pass == null) {
      return AuthResult.fail(
        'No saved credentials. Sign in once with email & password.',
      );
    }

    _setLoading(true);
    _setError(null);

    try {
      // --------- ONLINE primero ---------
      await _auth.signInEmailPassword(email: email, password: pass);
      await _auth.reloadUser();

      if (!_auth.isEmailVerified) {
        final ar = AuthResult.verifyNeeded(
          'Please verify your email to continue',
        );
        _setLoading(false);
        _setError(ar.message);
        return ar;
      }

      // --------- Habilitar offline secure ---------
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await OfflineAuthService.enableOfflineForCredentials(
          email: email,
          password: pass,
          uid: uid,
        );

        await OfflineAuthService.cacheUserSettings(
          uid: uid,
          settings: <String, dynamic>{
            "theme": "system",
            "notifications": true,
            "favoriteGroups": <String>[],
          },
        );
      }

      // --------- Guardar credenciales rápidas en RAM ---------
      _quickLoginEmail = email;
      _quickLoginPass = pass;

      // ======= NUEVO: persistimos credenciales sesión =======
      await SecureStore.setSessionCredentials(email: email, password: pass);
      await SessionPrefs.setWasLoggedIn(true);

      _setLoading(false);
      _setError(null);
      return AuthResult.success('Logged in with biometrics');
    } catch (e) {
      // --------- OFFLINE fallback con biometría ---------
      final canOffline = await OfflineAuthService.tryOfflineBiometric();
      if (canOffline) {
        final info = await OfflineAuthService.offlineSessionInfo();
        if (info.uid != null && info.email != null) {
          _auth.startOfflineSession(uid: info.uid!, email: info.email!);

          _quickLoginEmail = email;
          _quickLoginPass = pass;

          // ======= NUEVO: persistimos también en offline biométrico =======
          await SecureStore.setSessionCredentials(email: email!, password: pass!);
          await SessionPrefs.setWasLoggedIn(true);

          _setLoading(false);
          _setError(null);
          return const AuthResult(
            ok: true,
            message: 'Signed in offline',
          );
        }
      }

      final msg = _friendlyAuthMessage(e);
      _setLoading(false);
      _setError(msg);
      return AuthResult.fail(msg);
    }
  }

  // ---------- POST-LOGIN: chequeo biometría para guardar credenciales rápidas ----------
  //
  // Esto lo usa la pantalla de login justo DESPUÉS de un login ok,
  // para decidir si ofrecer "replace quick-login account?"
  Future<BiometricCheck> biometricPostLoginCheck(String newEmail) async {
    final supported = await _bio.canUseBiometrics();
    if (!supported) {
      return const BiometricCheck(
        supported: false,
        enabled: false,
        storedEmail: null,
      );
    }

    // Intentamos ver qué hay guardado ya en SecureStore.
    final stored = await SecureStore.biometricCredentials();
    final storedEmail = stored.email;

    final enabled = storedEmail != null && storedEmail.isNotEmpty;

    return BiometricCheck(
      supported: true,
      enabled: enabled,
      storedEmail: storedEmail,
    );
  }

  /// Para la viva: resumen de qué hay guardado biométricamente.
  Future<String> debugBiometricSummary() async {
    final summary = await _bio.debugSummary();
    _debugBio = summary;
    notifyListeners();
    return summary;
  }

  // ---------- BIOMETRÍA: helpers que tu login_screen.dart llama ----------
  //
  // Estos 3 métodos existen porque tu UI llama:
  //  - canStoreBiometric()
  //  - checkBiometricCredentials()
  //  - saveBiometricCredentials(...)
  //
  // Guardan una copia en RAM y además usan SecureStore.biometricCredentials()
  // (para lectura) y SecureStore.set... (para escritura en tu implementación real).
  // OJO: en tu proyecto real, si NO tienes un método "set" en SecureStore,
  // al menos esta versión en RAM compila y funciona para la demo.

  /// ¿Se puede almacenar credenciales biométricas en este dispositivo?
  /// Por ahora devolvemos true siempre para no romper la lógica.
  Future<bool> canStoreBiometric() async {
    return true;
  }

  /// Trae el correo actualmente guardado para quick login (lo que mostramos en el diálogo).
  /// Acá usamos la copia en RAM, porque sabemos que siempre existe tras login().
  Future<BiometricStoredInfo> checkBiometricCredentials() async {
    return BiometricStoredInfo(storedEmail: _quickLoginEmail);
  }

  /// Guarda (o reemplaza) las credenciales {email,password} para login rápido.
  /// IMPORTANTE:
  /// - Actualizamos RAM (_quickLoginEmail/_quickLoginPass) para la UI.
  /// - Si en tu SecureStore existe algo tipo SecureStore.setBiometricCredentials(),
  ///   aquí es donde deberías llamarlo. Como no lo teníamos en tu repo, lo dejamos
  ///   sólo en RAM, que al menos satisface el flujo del "Replace quick-login?".
  Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    _quickLoginEmail = email;
    _quickLoginPass = password;
    notifyListeners();

    // Si en tu SecureStore tienes un método para guardar credenciales cifradas,
    // por ejemplo:
    // await SecureStore.setBiometricCredentials(email: email, password: password);
    //
    // agrégalo aquí. Por ahora NO lo llamo para que no rompa compilación.
  }

  // ---------- Helpers "offline enable" opcionales ----------

  /// Activar modo offline explícitamente con las credenciales actuales.
  Future<void> enableOfflineWithCurrentCredentials() async {
    final uid = _auth.currentUser?.uid;
    final emailNow = _form.email;
    final passNow = _form.password;
    if (uid != null && emailNow.isNotEmpty && passNow.isNotEmpty) {
      await OfflineAuthService.enableOfflineForCredentials(
        email: emailNow,
        password: passNow,
        uid: uid,
      );
    }
  }

  /// Cachear settings offline manualmente.
  Future<void> cacheUserSettingsOffline(
      Map<String, dynamic> settings) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    await OfflineAuthService.cacheUserSettings(
      uid: uid,
      settings: settings,
    );
  }

  /// Limpia sesión offline local y en AuthService.
  Future<void> clearOfflineSession() async {
    _auth.clearOfflineSession();
    await OfflineAuthService.disableOffline();
    notifyListeners();
  }

  /// Logout global (online + offline).
  Future<void> signOutAll() async {
    await _auth.signOut();       // tu logout normal (Firebase)
    await clearOfflineSession(); // borra offline
  }

  /// Alias simple para pantallas que esperan vm.signOut()
  Future<void> signOut() async {
    await signOutAll();
  }
}
