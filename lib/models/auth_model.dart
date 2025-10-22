// lib/models/auth_model.dart

class AuthResult {
  final bool ok;
  final String? message;
  final bool needsEmailVerification;
  const AuthResult({
    required this.ok,
    this.message,
    this.needsEmailVerification = false,
  });

  static AuthResult success([String? msg]) =>
      AuthResult(ok: true, message: msg);

  static AuthResult fail(String msg, {bool needsVerification = false}) =>
      AuthResult(ok: false, message: msg, needsEmailVerification: needsVerification);
}

class LoginForm {
  final String email;
  final String password;
  const LoginForm({this.email = '', this.password = ''});

  LoginForm copyWith({String? email, String? password}) =>
      LoginForm(email: email ?? this.email, password: password ?? this.password);

  static final _emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static bool _hasSemicolon(String x) => x.contains(';');
  
  static String? validateEmail(String v) {
    final x = v.trim();
    if (x.isEmpty) return 'Enter your email';
    if (_hasSemicolon(x)) return "Semicolon ';' is not allowed";
    if (!_emailRx.hasMatch(x)) return 'Enter a valid email';
    if (x.length > 40) return 'Max 40 characters';
    return null;
  }

  static String? validatePassword(String v) {
    final x = v.trim();
    if (x.isEmpty) return 'Enter your password';
    if (_hasSemicolon(x)) return "Semicolon ';' is not allowed";
    if (x.length > 40) return 'Max 40 characters';
    return null;
  }

  bool get isValid =>
      validateEmail(email) == null && validatePassword(password) == null;
}

/// Estado para decidir acciones de biometría tras login exitoso
class BiometricCheck {
  final bool supported;
  final bool enabled;
  final String? storedEmail;
  BiometricCheck({
    required this.supported,
    required this.enabled,
    this.storedEmail,
  });
}
