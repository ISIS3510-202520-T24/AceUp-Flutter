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

    final dir = await _profilesDir();
    final outPath = '${dir.path}/${_safeEmail(email)}_avatar.jpg';

    final resultPath = await ImageCompressor.compressAndSave(
      inputPath: originalPath,
      outputPath: outPath,
    );

    if (resultPath.isEmpty) return null;
    return resultPath;
  }
}
