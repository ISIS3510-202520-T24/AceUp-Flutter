import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

import 'views/assignments/assignments_screen.dart';
import 'views/auth/logout_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/auth/biometric_screen.dart';
import 'views/holidays/holidays_screen.dart';
import 'views/today/today_screen.dart';
import 'views/shared/shared_screen.dart';

import 'themes/app_theme.dart';

import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/signup_viewmodel.dart';
import 'viewmodels/holidays_viewmodel.dart';

import 'package:firebase_auth/firebase_auth.dart'; //ignore: uri_does_not_exist
import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart' hide User; // ignore: uri_does_not_exist
import 'services/startup_ttfp.dart';

//ignore_for_file: undefined_identifier, non_type_as_type_argument

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⬇⬇⬇ Arranca el cronómetro ANTES de cualquier await/inicialización pesada
  StartupTTFP.start();

  // Inicializa Supabase para que StartupTTFP pueda insertar métricas
  await Supabase.initialize(
    url: 'https://qaotvqrayazjhkykevbo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFhb3R2cXJheWF6amhreWtldmJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1OTYwNTcsImV4cCI6MjA3NTE3MjA1N30.R9i8RqEUFMzx6Uh0q2vHZ7H8gDVYzb1A0CbhiE030kc',
  );

  // Firebase (si ya lo tenías)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Notificaciones (si ya lo tenías)
  await NotificationService().initNotifications();

  runApp(
    MultiProvider(
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
  );
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

      builder: (context, child) {
        final brightness = Theme.of(context).brightness;

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ));
        return child!;
      },

      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/biometric': (context) => const BiometricScreen(),
        '/today': (context) => const TodayScreen(),
        '/holidays': (context) => const HolidaysScreen(),
        '/account': (context) => const LogoutScreen(),
        '/shared': (context) => const SharedScreenWrapper(),
        '/assignments': (context) => const AssignmentsScreen(),
      },
    );
  }
}
