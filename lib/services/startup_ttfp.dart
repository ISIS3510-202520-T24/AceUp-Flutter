// lib/services/startup_ttfp.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartupTTFP {
  static final Stopwatch _sw = Stopwatch();
  static bool _started = false;
  static bool _sent = false;

  /// Llamar lo más arriba posible en `main()` ANTES de runApp().
  static void start() {
    if (_started) return;
    _started = true;
    _sw
      ..reset()
      ..start();
    debugPrint('[startup_ttfp] stopwatch started');
    // ignore: avoid_print
    print('[startup_ttfp] stopwatch started');
  }

  /// Llamar cuando el primer frame del Login ya se haya RASTERIZADO.
  /// Este método espera a `endOfFrame` para capturar realmente el tiempo visual.
  static Future<void> markLoginFirstFrame() async {
    if (!_started || _sent) return;

    // Espera a que termine el frame actual (asegura que el frame se dibujó)
    await SchedulerBinding.instance.endOfFrame;

    _sw.stop();
    final rawUs = _sw.elapsedMicroseconds;
    final rawMs = (rawUs / 1000).round();
    final ms = rawMs <= 0 ? 1 : rawMs;

    // LOG fuerte para tu script (print y debugPrint)
    debugPrint('[startup_events_v2] native rawMs=$ms');
    // ignore: avoid_print
    print('[startup_events_v2] native rawMs=$ms');

    try {
      final info = await PackageInfo.fromPlatform();
      final platform =
          Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');
      final buildType = kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug');

      await Supabase.instance.client.from('startup_events').insert({
        'ts': DateTime.now().toUtc().toIso8601String(),
        'load_ms': ms,
        'platform': platform,
        'app_version': info.version,
        'build_type': buildType,
      });

      debugPrint('[startup_events] insert OK (ms=$ms)');
      // ignore: avoid_print
      print('[startup_events] insert OK (ms=$ms)');
    } catch (e) {
      debugPrint('[startup_events] insert FAIL: $e');
      // ignore: avoid_print
      print('[startup_events] insert FAIL: $e');
    }

    _sent = true;
  }
}
