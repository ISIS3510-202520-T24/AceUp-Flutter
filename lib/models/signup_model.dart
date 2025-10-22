// lib/models/signup_model.dart
class SignUpForm {
  final String nickname;
  final String email;
  final String password;
  final String confirm;
  final bool acceptTerms;

  const SignUpForm({
    this.nickname = '',
    this.email = '',
    this.password = '',
    this.confirm = '',
    this.acceptTerms = false,
  });

  SignUpForm copyWith({
    String? nickname,
    String? email,
    String? password,
    String? confirm,
    bool? acceptTerms,
  }) =>
      SignUpForm(
        nickname: nickname ?? this.nickname,
        email: email ?? this.email,
        password: password ?? this.password,
        confirm: confirm ?? this.confirm,
        acceptTerms: acceptTerms ?? this.acceptTerms,
      );

  // Reglas
  static final _emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _pwdRx   = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
  static bool _hasSemicolon(String x) => x.contains(';');

  // Validadores
  static String? validateNick(String v) {
    final x = v.trim();
    if (x.isEmpty) return 'Choose a nickname';
    if (_hasSemicolon(x)) return "Semicolon ';' is not allowed";
    if (x.length > 40) return 'Max 40 characters';
    return null;
  }

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
    if (!_pwdRx.hasMatch(x)) return 'Password must be 8+ chars, 1 uppercase, 1 number';
    return null;
  }

  static String? validateConfirm(String pass, String confirm) {
    final x = confirm.trim();
    if (x.isEmpty) return 'Confirm your password';
    if (_hasSemicolon(x)) return "Semicolon ';' is not allowed";
    if (x != pass.trim()) return 'Passwords do not match';
    return null;
  }

  static String? validateTerms(bool accept) =>
      accept ? null : 'Accept the terms';

  bool get isValid =>
      validateNick(nickname) == null &&
      validateEmail(email) == null &&
      validatePassword(password) == null &&
      validateConfirm(password, confirm) == null &&
      validateTerms(acceptTerms) == null;
}
