import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _kBiometric = 'bio_enabled';
  static const _kLastEmail = 'last_email';
  static const _kCredEmail = 'cred_email';
  static const _kCredPass = 'cred_pass';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Flag biometría
  static Future<void> setBiometricEnabled(bool value) =>
      _storage.write(key: _kBiometric, value: value ? '1' : '0');

  static Future<bool> biometricEnabled() async =>
      (await _storage.read(key: _kBiometric)) == '1';

  // Email usado por última vez (por si necesitas prefills)
  static Future<void> setLastEmail(String email) =>
      _storage.write(key: _kLastEmail, value: email);

  static Future<String?> lastEmail() => _storage.read(key: _kLastEmail);

  // Credenciales para login con biometría
  static Future<void> setBiometricCredentials(String email, String password) async {
    await _storage.write(key: _kCredEmail, value: email);
    await _storage.write(key: _kCredPass, value: password);
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
}
