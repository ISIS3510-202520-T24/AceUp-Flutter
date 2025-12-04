// lib/services/auth/offline_auth_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ignore: uri_does_not_exist
import 'package:shared_preferences/shared_preferences.dart'; // ignore: uri_does_not_exist
import 'password_hasher.dart';

// ignore_for_file: undefined_identifier, undefined_method, const_initialized_with_non_constant_value

/// Administra el "desbloqueo offline" **solo** tras un primer login ONLINE exitoso.
/// - Guarda en SecureStorage: uid, email, salt+hash PBKDF2 de la clave, enabledAt.
/// - Permite desbloquear offline por biometría (si hay sesión habilitada) o por email+clave.
/// - Permite cachear "user settings" en SharedPreferences (JSON), como en storage_memory (clave->valor/JSON).
class OfflineAuthService {
  static const _kOfflineEnabled = 'offline_enabled';
  static const _kOfflineUID = 'offline_uid';
  static const _kOfflineEmail = 'offline_email';
  static const _kOfflineSalt = 'offline_salt';
  static const _kOfflineHash = 'offline_hash';
  static const _kOfflineEnabledAt = 'offline_enabled_at';
  static const _kOfflineTTLDays = 90; // TTL suave; ajustable

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Habilita el modo offline para {email, password} del usuario {uid}.
  static Future<void> enableOfflineForCredentials({
    required String email,
    required String password,
    required String uid,
  }) async {
    final verifier = PasswordHasher.createVerifier(password);
    await _secure.write(key: _kOfflineEnabled, value: '1');
    await _secure.write(key: _kOfflineUID, value: uid);
    await _secure.write(key: _kOfflineEmail, value: email);
    await _secure.write(key: _kOfflineSalt, value: verifier.salt);
    await _secure.write(key: _kOfflineHash, value: verifier.hash);
    await _secure.write(key: _kOfflineEnabledAt, value: DateTime.now().toIso8601String());
  }

  static Future<void> disableOffline() async {
    await _secure.delete(key: _kOfflineEnabled);
    await _secure.delete(key: _kOfflineUID);
    await _secure.delete(key: _kOfflineEmail);
    await _secure.delete(key: _kOfflineSalt);
    await _secure.delete(key: _kOfflineHash);
    await _secure.delete(key: _kOfflineEnabledAt);
  }

  static Future<bool> isOfflineEnabled() async =>
      (await _secure.read(key: _kOfflineEnabled)) == '1';

  static Future<String?> offlineUid() => _secure.read(key: _kOfflineUID);
  static Future<String?> offlineEmail() => _secure.read(key: _kOfflineEmail);

  /// Desbloqueo con email+clave cuando no hay red.
  static Future<bool> tryOfflinePassword({
    required String email,
    required String password,
  }) async {
    final enabled = await isOfflineEnabled();
    if (!enabled) return false;

    final savedEmail = await _secure.read(key: _kOfflineEmail);
    if (savedEmail == null || savedEmail.toLowerCase() != email.toLowerCase()) return false;

    final salt = await _secure.read(key: _kOfflineSalt);
    final hash = await _secure.read(key: _kOfflineHash);
    if (salt == null || hash == null) return false;

    final ok = PasswordHasher.verify(password, salt, hash);
    if (!ok) return false;

    final enabledAtStr = await _secure.read(key: _kOfflineEnabledAt);
    if (enabledAtStr != null) {
      try {
        final enabledAt = DateTime.parse(enabledAtStr);
        if (DateTime.now().difference(enabledAt).inDays > _kOfflineTTLDays) {
          return false;
        }
      } catch (_) {}
    }
    return true;
  }

  /// Desbloqueo por biometría: solo valida que el modo offline esté habilitado y haya uid/email.
  static Future<bool> tryOfflineBiometric() async {
    final enabled = await isOfflineEnabled();
    if (!enabled) return false;
    final uid = await _secure.read(key: _kOfflineUID);
    final email = await _secure.read(key: _kOfflineEmail);
    return uid != null && email != null;
  }

  /// Info mínima de sesión offline (para AuthService.startOfflineSession)
  static Future<({String? uid, String? email})> offlineSessionInfo() async {
    return (uid: await offlineUid(), email: await offlineEmail());
  }

  /// Guarda user settings (JSON) en SharedPreferences bajo `settings:<uid>`.
  static Future<void> cacheUserSettings({
    required String uid,
    required Map<String, dynamic> settings,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings:$uid', jsonEncode(settings));
  }

  static Future<Map<String, dynamic>?> readUserSettings(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('settings:$uid');
    if (str == null) return null;
    try { return jsonDecode(str) as Map<String, dynamic>; } catch (_) { return null; }
  }
}
