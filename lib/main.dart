import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'firebase_options.dart';
import 'views/auth/logout_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/auth/biometric_screen.dart';
import 'views/holidays/holidays_screen.dart';
import 'views/today/today_screen.dart';
import 'views/shared/shared_screen.dart';
import 'themes/app_theme.dart';

import 'services/auth_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/signup_viewmodel.dart';
import 'viewmodels/holidays_viewmodel.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Marca el instante en que el proceso arrancó (antes de runApp).
final DateTime _appStart = DateTime.now();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    StartupTimer(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HolidaysViewModel()),
          Provider<AuthService>(create: (_) => AuthService()),
          ChangeNotifierProvider<LoginViewModel>(
            create: (ctx) => LoginViewModel(ctx.read<AuthService>()),
          ),
          Provider<SignUpViewModel>(
            create: (ctx) => SignUpViewModel(ctx.read<AuthService>()),
          ),
          StreamProvider<User?>(
            create: (ctx) => ctx.read<AuthService>().authStateChanges,
            initialData: null,
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

/// Envía a Firebase Analytics un evento `app_load_time` con `load_ms`
/// cuando se renderiza el primer frame (cold start).
class StartupTimer extends StatefulWidget {
  final Widget child;
  const StartupTimer({super.key, required this.child});

  @override
  State<StartupTimer> createState() => _StartupTimerState();
}

class _StartupTimerState extends State<StartupTimer> {
  static bool _sent = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (_sent) return;
      _sent = true;

      try {
        final loadMs = DateTime.now().difference(_appStart).inMilliseconds;
        final platform =
            Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');

        await FirebaseAnalytics.instance.logEvent(
          name: 'app_load_time',
          // 👇 clave: tipar el mapa como <String, Object>{...}
          parameters: <String, Object>{
            'load_ms': loadMs,
            'platform': platform,
          },
        );
      } catch (_) {
        // Evitar que un fallo de analytics rompa el arranque
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AceUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/biometric': (context) => const BiometricScreen(),
        '/today': (context) => const TodayScreen(),
        '/holidays': (context) => const HolidaysScreen(),
        '/account': (_) => const LogoutScreen(),
        '/shared': (_) => const SharedScreenWrapper(),
      },
    );
  }
}
