import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final Stopwatch _sw = Stopwatch()..start();

class StartupMetrics {
  static Future<void> markFrameLoaded() async {
    try {
      _sw.stop();
      final rawUs = _sw.elapsedMicroseconds;
      final rawMs = (rawUs / 1000).round();
      final clampedMs = rawMs <= 0 ? 1 : rawMs;

      // 🔹 Ambos logs para asegurar visibilidad en cualquier build:
      debugPrint('[startup_events_v2] native rawMs=$clampedMs');
      // ignore: avoid_print
      print('[startup_events_v2] native rawMs=$clampedMs');

      final pkg = await PackageInfo.fromPlatform();
      final appVersion = pkg.version;
      final buildType = kReleaseMode ? 'release' : 'debug';
      final platform =
          Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');

      await Supabase.instance.client.from('startup_events').insert({
        'ts': DateTime.now().toUtc().toIso8601String(),
        'load_ms': clampedMs,
        'platform': platform,
        'app_version': appVersion,
        'build_type': buildType,
      });

      debugPrint('[startup_events] insert OK (ms=$clampedMs)');
      // ignore: avoid_print
      print('[startup_events] insert OK (ms=$clampedMs)');
    } catch (e) {
      debugPrint('[startup_events] insert FAIL: $e');
      // ignore: avoid_print
      print('[startup_events] insert FAIL: $e');
    }
  }
}
