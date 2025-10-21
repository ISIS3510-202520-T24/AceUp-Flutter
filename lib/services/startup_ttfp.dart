import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; //ignore: uri_does_not_exist

//ignore_for_file: undefined_identifier

/// Mide el tiempo desde main() hasta que el Login hace su primer frame.
class StartupTTFP {
  static final Stopwatch _sw = Stopwatch();
  static bool _sent = false;

  /// Llamar en main() ANTES de Firebase.initializeApp y runApp().
  static void start() {
    if (!_sw.isRunning && !_sent) {
      // por si quedó de una corrida previa
      _sw.reset();
      _sw.start();
      debugPrint('[startup_ttfp] stopwatch started');
    }
  }

  /// Llamar en LoginScreen.initState() dentro de un postFrameCallback.
  static Future<void> markLoginFirstFrame() async {
    if (_sent || !_sw.isRunning) return;
    try {
      _sw.stop();
      final ms = _sw.elapsedMilliseconds;
      final seconds = ms / 1000.0;
      debugPrint('[startup_ttfp] elapsed = ${ms}ms (${seconds}s)');

      // 🔴 clave: marcar como debug en web/entorno dev
      final params = <String, Object>{
        'tiempo_carga_ms': ms,      // INT
        'tiempo_carga_s': seconds,  // DOUBLE
        if (kIsWeb || kDebugMode) 'debug_mode': 1,
      };

      await FirebaseAnalytics.instance.logEvent(
        name: 'time_login_ttfp',
        parameters: params,
      );
      _sent = true;
      debugPrint('[startup_ttfp] event time_login_ttfp sent');
    } catch (e, st) {
      debugPrint('[startup_ttfp] send fail: $e\n$st');
    }
  }
}
