// lib/services/profile/profile_cache_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // ignore: uri_does_not_exist

import '../../models/user_profile.dart';
import 'image_compressor.dart';

// ignore_for_file: undefined_method

class ProfileCacheService {
  ProfileCacheService._();
  static final ProfileCacheService _instance = ProfileCacheService._();
  factory ProfileCacheService() => _instance;

  // cache en RAM por email
  final Map<String, UserProfile> _memoryCache = {};
    // toggle: activar o desactivar optimización de caché de compresión
  bool enableAvatarCompressionCache = false;

  // cache en RAM: originalPath -> avatar comprimido en disco
  final Map<String, String> _avatarCacheByOriginalPath = {};

  Future<Directory> _profilesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/profiles');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _safeEmail(String email) {
    // limpia caracteres raros del correo para usarlo en nombre de archivo
    return email.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
  }

  Future<File> _profileFile(String email) async {
    final dir = await _profilesDir();
    return File('${dir.path}/${_safeEmail(email)}.json');
  }

  Future<void> saveProfile(UserProfile profile) async {
    _memoryCache[profile.email] = profile;
    final f = await _profileFile(profile.email);
    await f.writeAsString(profile.toJsonString(), flush: true);
  }

  Future<UserProfile?> loadProfile(String email) async {
    if (email.isEmpty) return null;

    if (_memoryCache.containsKey(email)) {
      return _memoryCache[email];
    }

    final f = await _profileFile(email);
    if (await f.exists()) {
      final raw = await f.readAsString();
      final prof = UserProfile.fromJsonString(raw);
      if (prof != null) {
        _memoryCache[email] = prof;
      }
      return prof;
    }

    return null;
  }

  /// Comprime y guarda avatar local estable para ESTE email.
  /// Devuelve la ruta guardada en disco lista para poner en `avatarLocalPath`.
    Future<String?> saveCompressedAvatarForEmail({
    required String email,
    required String originalPath,
  }) async {
    if (email.isEmpty) return null;

    // === MÉTRICA: tiempo de compresión de avatar ===
    final sw = Stopwatch()..start();
    print(
      '[METRIC][AVATAR] start email=$email original=$originalPath cacheEnabled=$enableAvatarCompressionCache',
    );

    String? resultPath;

    // 1) Si la optimización está activada, intentamos leer de caché
    if (enableAvatarCompressionCache) {
      final cached = _avatarCacheByOriginalPath[originalPath];
      if (cached != null && File(cached).existsSync()) {
        sw.stop();
        print(
          '[METRIC][AVATAR] cache_hit email=$email ms=${sw.elapsedMilliseconds} cached=$cached',
        );
        return cached;
      }
    }

    // 2) Compresión "real"
    final dir = await _profilesDir();
    final outPath = '${dir.path}/${_safeEmail(email)}_avatar.jpg';

    resultPath = await ImageCompressor.compressAndSave(
      inputPath: originalPath,
      outputPath: outPath,
    );

    sw.stop();
    print(
      '[METRIC][AVATAR] done email=$email ms=${sw.elapsedMilliseconds} result=$resultPath',
    );

    if (resultPath == null || resultPath.isEmpty) {
      return null;
    }

    // 3) Si la optimización está activada, guardamos en caché
    if (enableAvatarCompressionCache) {
      _avatarCacheByOriginalPath[originalPath] = resultPath;
    }

    return resultPath;
  }

}
