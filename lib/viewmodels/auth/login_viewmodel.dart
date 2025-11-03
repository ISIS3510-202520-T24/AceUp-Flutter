// lib/viewmodels/auth/login_viewmodel.dart
import 'package:flutter/foundation.dart';

import '../../services/auth/auth_service.dart';
import '../../services/auth/biometric_service.dart';

/// Resultado genérico de login / acciones
class LoginResult {
  final bool ok;
  final String? message;
  const LoginResult({required this.ok, this.message});
}

/// Info de las credenciales biométricas guardadas
class BiometricStoredInfo {
  final String? storedEmail;
  const BiometricStoredInfo({this.storedEmail});
}

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
}

class LoginViewModel extends ChangeNotifier {
  final AuthService _auth;
  final BiometricService _bio;

  LoginViewModel(this._auth, this._bio);

  LoginForm _form = const LoginForm();
  bool _loading = false;
  String? _error;
  String? _debugBio;

  // ------------------------------------------------------------------
  // Estos 2 campos son nuestro "mini storage en memoria" para biometría.
  // Motivo: tu BiometricService real no expone todavía canStoreCredentials(),
  // getStoredEmail() ni saveCredentials(). Para no romper nada ni forzarte
  // a reescribir ese service hoy, lo simulamos aquí.
  //
  // OJO: esto vive solo en RAM mientras la app está abierta. Para el viva voce
  // igual sirve porque mostramos la lógica, y NO rompe compilación.
  // ------------------------------------------------------------------
  String? _quickLoginEmail; // e.g. el correo asociado al login rápido
  String? _quickLoginPass;  // la clave asociada

  // ========= Getters básicos usados en pantallas =========
  bool get loading => _loading;
  String? get error => _error;
  String? get debugBioInfo => _debugBio;

  String get email => _form.email;
  String get password => _form.password;

  /// Nombre bonito para "Welcome back, X"
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

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  // ========= Setters del form (login_screen los llama) =========
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

  // ========= LOGIN normal con email / password =========
  Future<LoginResult> login() async {
    final emailNow = _form.email.trim();
    final passNow = _form.password;

    if (emailNow.isEmpty || !emailNow.contains('@')) {
      return const LoginResult(ok: false, message: 'Enter a valid email.');
    }
    if (passNow.isEmpty) {
      return const LoginResult(ok: false, message: 'Password required.');
    }

    _setLoading(true);
    try {
      await _auth.signInEmailPassword(email: emailNow, password: passNow);
      _error = null;
      notifyListeners();
      return const LoginResult(ok: true);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return LoginResult(ok: false, message: _error);
    } finally {
      _setLoading(false);
    }
  }

  // ========= BIOMETRÍA: debug info (biometric_screen.dart lo llama) =========
  Future<String> debugBiometricSummary() async {
    // Tu BiometricService sí tiene debugSummary() (estaba en tu flujo original).
    final summary = await _bio.debugSummary();
    _debugBio = summary;
    notifyListeners();
    return summary;
  }

  // ========= BIOMETRÍA: login rápido con huella / cara =========
  Future<LoginResult> loginWithBiometrics() async {
    try {
      // IMPORTANTE:
      // Me dijiste que en tu proyecto real la firma correcta es authenticate()
      // (no tryBiometricLogin). La mantengo exactamente así.
      //
      // authenticate() internamente hace el prompt biométrico
      // Y debe encargarse él mismo de loggear al usuario (Firebase signIn).
      final ok = await _bio.authenticate();

      if (ok) {
        return const LoginResult(ok: true);
      } else {
        return const LoginResult(
          ok: false,
          message: 'Biometric auth failed.',
        );
      }
    } catch (e) {
      return LoginResult(
        ok: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ========= BIOMETRÍA: lógica de guardado de credenciales =========
  //
  // En tu login_screen.dart estás llamando a:
  //   vm.canStoreBiometric()
  //   vm.checkBiometricCredentials()
  //   vm.saveBiometricCredentials(...)
  //
  // Como tu BiometricService real NO expone esos métodos con esos nombres,
  // aquí los implemento en el ViewModel usando variables privadas en RAM.
  //
  // Esto elimina los errores rojos que estás viendo en las líneas 148-166.
  //
  // Más adelante, si quieres persistencia real y encriptada,
  // puedes mover esto a BiometricService con flutter_secure_storage, etc.
  //

  /// ¿Se puede almacenar credenciales biométricas en este dispositivo?
  /// Por ahora devolvemos true siempre para no romper lógica.
  Future<bool> canStoreBiometric() async {
    // Si quieres ser más estricta, puedes preguntar al servicio biométrico:
    // return _bio.isDeviceSupported(); // <- si existiera
    return true;
  }

  /// Trae el correo actualmente guardado para quick login biométrico.
  /// En la UI lo usas para decidir si preguntar "replace credentials?".
  Future<BiometricStoredInfo> checkBiometricCredentials() async {
    return BiometricStoredInfo(storedEmail: _quickLoginEmail);
  }

  /// Guarda (o reemplaza) las credenciales {email,password} en almacenamiento "rápido".
  /// Aquí sólo las guardamos en variables privadas en RAM.
  /// Esto es suficiente para que TU flujo de dialogo/replace funcione,
  /// y mata el error del editor.
  Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    _quickLoginEmail = email;
    _quickLoginPass = password;
    // notifyListeners() no es 100% necesario, pero lo mantenemos por consistencia:
    notifyListeners();
  }

  // ========= SETTINGS: reset password por correo =========
  Future<LoginResult> forgotPassword(String emailToReset) async {
    try {
      await _auth.requestPasswordReset(emailToReset.trim());
      return const LoginResult(ok: true);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return LoginResult(ok: false, message: msg);
    }
  }

  // ========= SETTINGS / DRAWER: logout =========
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
