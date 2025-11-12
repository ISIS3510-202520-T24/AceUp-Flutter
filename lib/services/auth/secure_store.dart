import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ignore: uri_does_not_exist 

// ignore_for_file: undefined_method, const_initialized_with_non_constant_value, undefined_identifier

class SecureStore {
  // ================== EXISTENTE ==================
  static const _kBiometric = 'bio_enabled';
  static const _kLastEmail = 'last_email';
  static const _kCredEmail = 'cred_email';
  static const _kCredPass = 'cred_pass';

  // ================== NUEVO: credenciales de sesión persistente ==================
  static const _kSessEmail = 'session_email';
  static const _kSessPass  = 'session_pass';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ---------- Flag biometría ----------
  static Future<void> setBiometricEnabled(bool value) =>
      _storage.write(key: _kBiometric, value: value ? '1' : '0');

  static Future<bool> biometricEnabled() async =>
      (await _storage.read(key: _kBiometric)) == '1';

  // ---------- Email usado por última vez ----------
  static Future<void> setLastEmail(String email) =>
      _storage.write(key: _kLastEmail, value: email);

  static Future<String?> lastEmail() => _storage.read(key: _kLastEmail);

  // ---------- Credenciales para login con biometría ----------
  static Future<void> setBiometricCredentials(String email, String password) async {
    await _storage.write(key: _kCredEmail, value: email);
    await _storage.write(key: _kCredPass,  value: password);
  }

  static Future<({String? email, String? password})> biometricCredentials() async {
    final e = await _storage.read(key: _kCredEmail);
    final p = await _storage.read(key: _kCredPass);
    return (email: e, password: p);
  }

  static Future<void> clearBiometricCredentials() async {
    await _storage.delete(key: _kCredEmail);
    await _storage.delete(key: _kCredPass);
  }

  // ================== NUEVO: Sesión persistente (auto-login silencioso) ==================
  /// Guarda credenciales para intentar sign-in silencioso al arrancar.
  static Future<void> setSessionCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _kSessEmail, value: email);
    await _storage.write(key: _kSessPass,  value: password);
  }

  /// Lee las credenciales guardadas para sesión persistente.
  static Future<({String? email, String? password})> sessionCredentials() async {
    final e = await _storage.read(key: _kSessEmail);
    final p = await _storage.read(key: _kSessPass);
    return (email: e, password: p);
  }

  /// Borra las credenciales de sesión persistente (úsalo en logout).
  static Future<void> clearSessionCredentials() async {
    await _storage.delete(key: _kSessEmail);
    await _storage.delete(key: _kSessPass);
  }
}
