// lib/viewmodels/auth/signup_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ignore: uri_does_not_exist

// ignore_for_file: undefined_identifier, undefined_class, non_type_in_catch_clause

/// Resultado de intentar registrarse.
/// ok = true  -> éxito
/// ok = false -> fallo, mira message
class SignupResult {
  final bool ok;
  final String? message;
  const SignupResult({required this.ok, this.message});
}

/// Estructura interna del form.
/// La UI también necesita leer acceptTerms.
class SignUpForm {
  String nickname;
  String email;
  String password;
  String confirm;
  bool acceptTerms;

  SignUpForm({
    this.nickname = '',
    this.email = '',
    this.password = '',
    this.confirm = '',
    this.acceptTerms = false,
  });
}

/// ViewModel que maneja el flujo de registro.
/// Esta clase está hecha para que compile con signup_screen.dart
/// tal como lo dejamos.
class SignUpViewModel extends ChangeNotifier {
  // --------- STATE PRINCIPAL ---------
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // formulario editable
  final SignUpForm form = SignUpForm();

  // errores por campo
  String? _errorNickname;
  String? _errorEmail;
  String? _errorPassword;
  String? _errorConfirm;

  // error global tipo "TERMS", etc.
  String? _errorGlobal;

  // mensaje informativo (ej. "Check your inbox")
  String? _infoMessage;

  // flag de carga del botón
  bool _loading = false;

  // ===== getters expuestos a la UI =====

  bool get loading => _loading;

  String? get errorNickname => _errorNickname;
  String? get errorEmail => _errorEmail;
  String? get errorPassword => _errorPassword;
  String? get errorConfirm => _errorConfirm;
  String? get errorGlobal => _errorGlobal;

  String? get infoMessage => _infoMessage;

  // ===== setters llamados por los TextFields =====

  void setNickname(String v) {
    form.nickname = v.trim();
    _validateNickname();
    notifyListeners();
  }

  void setEmail(String v) {
    form.email = v.trim();
    _validateEmail();
    notifyListeners();
  }

  void setPassword(String v) {
    form.password = v;
    _validatePassword();
    _validateConfirm(); // por si ya había confirm
    notifyListeners();
  }

  void setPasswordConfirm(String v) {
    form.confirm = v;
    _validateConfirm();
    notifyListeners();
  }

  void setAcceptTerms(bool v) {
    form.acceptTerms = v;
    // limpiar error global si lo único que fallaba era TERMS
    if (_errorGlobal == 'TERMS' && v == true) {
      _errorGlobal = null;
    }
    notifyListeners();
  }

  // ===== validaciones individuales =====

  void _validateNickname() {
    if (form.nickname.isEmpty) {
      _errorNickname = 'Please enter a nickname.';
    } else if (form.nickname.length < 2) {
      _errorNickname = 'Nickname is too short.';
    } else {
      _errorNickname = null;
    }
  }

  void _validateEmail() {
    if (form.email.isEmpty) {
      _errorEmail = 'Email required.';
    } else if (!form.email.contains('@')) {
      _errorEmail = 'Invalid email.';
    } else {
      _errorEmail = null;
    }
  }

  void _validatePassword() {
    if (form.password.isEmpty) {
      _errorPassword = 'Password required.';
    } else if (form.password.length < 6) {
      _errorPassword = 'Use at least 6 characters.';
    } else {
      _errorPassword = null;
    }
  }

  void _validateConfirm() {
    if (form.confirm.isEmpty) {
      _errorConfirm = 'Please confirm password.';
    } else if (form.confirm != form.password) {
      _errorConfirm = 'Passwords do not match.';
    } else {
      _errorConfirm = null;
    }
  }

  // ===== validación global previa al signup =====
  bool _isFormValidBeforeSignup() {
    _validateNickname();
    _validateEmail();
    _validatePassword();
    _validateConfirm();

    if (!form.acceptTerms) {
      _errorGlobal = 'TERMS';
    } else {
      if (_errorGlobal == 'TERMS') {
        _errorGlobal = null;
      }
    }

    // si hay cualquier error, no es válido
    if (_errorNickname != null ||
        _errorEmail != null ||
        _errorPassword != null ||
        _errorConfirm != null ||
        _errorGlobal != null) {
      return false;
    }
    return true;
  }

  // ===== flujo de registro =====
  //
  // Aquí hacemos el createUserWithEmailAndPassword en Firebase.
  // Si tú quieres además guardar hash offline en SQLite para login offline,
  // ese paso iría aquí también.
  //
    Future<SignupResult> signup() async {
    // === MÉTRICA: tiempo total de registro ===
    final sw = Stopwatch()..start();
    print('[METRIC][SIGNUP] start email=${form.email}');

    // refrescamos validaciones
    final valid = _isFormValidBeforeSignup();
    notifyListeners();

    if (!valid) {
      sw.stop();
      print(
        '[METRIC][SIGNUP] invalid_form total_ms=${sw.elapsedMilliseconds}',
      );
      return SignupResult(
        ok: false,
        message: 'Please fix the highlighted fields.',
      );
    }

    _loading = true;
    _errorGlobal = null;
    _infoMessage = null;
    notifyListeners();

    try {
      // 1. crear cuenta en Firebase
      final cred = await _auth.createUserWithEmailAndPassword(
        email: form.email,
        password: form.password,
      );

      // 2. actualizar displayName en Firebase user
      if (cred.user != null && form.nickname.isNotEmpty) {
        await cred.user!.updateDisplayName(form.nickname);
      }

      // 3. (Opcional) mandar verificación de email
      await cred.user?.sendEmailVerification();

      // 4. Mensaje informativo UI
      _infoMessage = 'Account created. Welcome ${form.nickname}!';

      _loading = false;
      notifyListeners();

      sw.stop();
      print(
        '[METRIC][SIGNUP] success total_ms=${sw.elapsedMilliseconds}',
      );

      return const SignupResult(
        ok: true,
        message: 'Account created.',
      );
    } on FirebaseAuthException catch (e) {
      // errores típicos: email en uso, formato inválido en backend, etc.
      _loading = false;

      // mapeo rápido:
      String msg;
      if (e.code == 'email-already-in-use') {
        msg = 'Email already in use.';
        _errorEmail = msg;
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email.';
        _errorEmail = msg;
      } else if (e.code == 'weak-password') {
        msg = 'Weak password.';
        _errorPassword = msg;
      } else {
        msg = e.message ?? 'Could not create account.';
        _errorGlobal = msg;
      }

      notifyListeners();

      sw.stop();
      print(
        '[METRIC][SIGNUP] firebase_error total_ms=${sw.elapsedMilliseconds} code=${e.code}',
      );

      return SignupResult(ok: false, message: msg);
    } catch (e) {
      // error inesperado (sin internet, etc.)
      _loading = false;
      _errorGlobal = 'Unexpected error. Please try again.';
      notifyListeners();

      sw.stop();
      print(
        '[METRIC][SIGNUP] unexpected_error total_ms=${sw.elapsedMilliseconds}',
      );

      return const SignupResult(
        ok: false,
        message: 'Unexpected error. Please try again.',
      );
    }
  }
}
