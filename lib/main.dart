import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'firebase_options.dart';

// Vistas
import 'views/assignments/assignments_screen.dart';
import 'views/auth/logout_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/auth/biometric_screen.dart';
import 'views/holidays/holidays_screen.dart';
import 'views/today/today_screen.dart';
import 'views/shared/shared_screen.dart';

// Tema
import 'themes/app_theme.dart';

// Servicios y VMs (rutas nuevas)
import 'package:aceup_clean/services/notif/notification_service.dart';
import 'package:aceup_clean/services/auth/auth_service.dart';
import 'package:aceup_clean/services/auth/biometric_service.dart';

import 'package:aceup_clean/viewmodels/holidays/holidays_viewmodel.dart';
import 'package:aceup_clean/viewmodels/auth/login_viewmodel.dart';
import 'package:aceup_clean/viewmodels/auth/signup_viewmodel.dart';

// Nuestro observer
import 'package:aceup_clean/core/observer/vm_scope.dart';

// TTFP (está en lib/)
import 'package:aceup_clean/services/startup_ttfp.dart';

// Provider
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Arranca TTFP lo antes posible
  StartupTTFP.start();

  // 2) Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3) Notificaciones
  await NotificationService().initNotifications();

  // 4) Servicios y VMs (para nuestro Observer)
  final authService = AuthService();
  final bioService = BiometricService();

  final loginVM = LoginViewModel(authService, bioService);
  final signUpVM = SignUpViewModel(authService);

  // 5) Registrar en VmRegistry (nuestro contenedor simple)
  final registry = VmRegistry()
    ..put<AuthService>(authService)
    ..put<BiometricService>(bioService)
    ..put<LoginViewModel>(loginVM)
    ..put<SignUpViewModel>(signUpVM);

  // Opcional: ver claves registradas en consola
  registry.debugPrintKeys();

  runApp(
    // Importante: VmScope por ENCIMA de MaterialApp
    VmScope(
      registry: registry,
      // Debajo usamos Provider para Holidays y el stream de Auth
      child: MultiProvider(
        providers: [
          // Holidays usa ChangeNotifier
          ChangeNotifierProvider(create: (_) => HolidaysViewModel()),

          // Exponer servicios si en alguna vista lees context.read<AuthService>()
          Provider<AuthService>.value(value: authService),
          Provider<BiometricService>.value(value: bioService),

          // Stream del estado de autenticación (si lo usas en otras pantallas)
          StreamProvider<User?>(
            create: (_) => authService.authStateChanges,
            initialData: null,
          ),
        ],
        child: const AceUpApp(),
      ),
    ),
  );
}

class AceUpApp extends StatelessWidget {
  const AceUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AceUp',
      debugShowCheckedModeBanner: false,

      // Tus temas como estaban
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Ajustes de status/nav bar según brillo actual del tema
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                brightness == Brightness.dark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness:
                brightness == Brightness.dark ? Brightness.light : Brightness.dark,
            systemNavigationBarContrastEnforced: false,
          ),
        );
        return child!;
      },

      // Rutas — inyectamos los VM desde VmScope SOLO donde se necesitan
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(
              vm: VmScope.of(context).get<LoginViewModel>(),
            ),
        '/signup': (context) => SignUpScreen(
              vm: VmScope.of(context).get<SignUpViewModel>(),
            ),
        '/biometric': (context) => BiometricScreen(
              vm: VmScope.of(context).get<LoginViewModel>(),
            ),
        '/today': (context) => const TodayScreen(),
        '/holidays': (context) => const HolidaysScreen(),
        '/account': (context) => LogoutScreen(
              vm: VmScope.of(context).get<LoginViewModel>(),
            ),
        '/shared': (context) => const SharedScreenWrapper(),
        '/assignments': (context) => const AssignmentsScreen(),
      },
    );
  }
}
