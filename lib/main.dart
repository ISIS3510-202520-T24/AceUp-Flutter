// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'firebase_options.dart';

// Provider
import 'package:provider/provider.dart';

// Notificaciones / startup timing
import 'services/notif/notification_service.dart';
import 'services/startup_ttfp.dart';

// Servicios
import 'services/auth/auth_service.dart';
import 'services/auth/biometric_service.dart';
import 'services/profile/profile_notifier.dart';

// ViewModels
import 'viewmodels/auth/login_viewmodel.dart';
import 'viewmodels/auth/signup_viewmodel.dart';
import 'viewmodels/holidays/holidays_viewmodel.dart';

// Vistas
import 'views/auth/login_screen.dart';
import 'views/auth/biometric_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/auth/logout_screen.dart';
import 'views/today/today_screen.dart';
import 'views/holidays/holidays_screen.dart';
import 'views/assignments/assignments_screen.dart';
import 'views/shared/shared_screen.dart';
import 'views/settings/settings_screen.dart';

// Tema
import 'themes/app_theme.dart';

// Nuestro contenedor tipo locator
import 'core/observer/vm_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Marcador de tiempo de arranque (para métricas de TTFP en consola)
  StartupTTFP.start();

  // 2) Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3) Inicializar notificaciones locales
  await NotificationService().initNotifications();

  // 4) Instanciar servicios singleton-ish
  final authService = AuthService();
  final bioService = BiometricService();

  // 5) Instanciar VMs que viven "global" (login puede vivir global;
  //    signup lo vamos a recrear en la ruta para no mezclar estado viejo del form,
  //    pero igual podemos tener uno base en el registry si quieres).
  final loginVM = LoginViewModel(authService, bioService);
  final signUpVM = SignUpViewModel(); // <- sin argumentos

  // 6) Registrar todo en VmRegistry para que podamos pedirlos con VmScope.of(context)
  final registry = VmRegistry()
    ..put<AuthService>(authService)
    ..put<BiometricService>(bioService)
    ..put<LoginViewModel>(loginVM)
    ..put<SignUpViewModel>(signUpVM);

  // (debug opcional)
  registry.debugPrintKeys();

  // 7) runApp con VmScope y luego MultiProvider
  runApp(
    VmScope(
      registry: registry,
      child: MultiProvider(
        providers: [
          // Estado global del perfil (nickname/avatar) usado por Settings y BurgerMenu
          ChangeNotifierProvider<ProfileNotifier>(
            create: (_) => ProfileNotifier(),
          ),

          // HolidaysViewModel (ChangeNotifier con lógica de festivos)
          ChangeNotifierProvider<HolidaysViewModel>(
            create: (_) => HolidaysViewModel(),
          ),

          // Exponer servicios para pantallas que hacen context.read<AuthService>()
          Provider<AuthService>.value(value: authService),
          Provider<BiometricService>.value(value: bioService),

          // Stream de auth (FirebaseAuth) para saber si hay usuario logeado
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

      // Tema claro/oscuro actual
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Ajuste de System UI overlays segun brillo actual
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

      initialRoute: '/',

      routes: {
        // LOGIN: usa el LoginViewModel que ya está registrado en VmScope
        '/': (context) => LoginScreen(
              vm: VmScope.of(context).get<LoginViewModel>(),
            ),

        // BIOMETRIC QUICK LOGIN: también usa el mismo LoginViewModel global
        '/biometric': (context) => BiometricScreen(
              vm: VmScope.of(context).get<LoginViewModel>(),
            ),

        // HOME (pantalla Today)
        '/today': (context) => const TodayScreen(),

        // FESTIVOS
        '/holidays': (context) => const HolidaysScreen(),

        // SHARED
        '/shared': (context) => const SharedScreenWrapper(),

        // ASSIGNMENTS
        '/assignments': (context) => const AssignmentsScreen(),

        // SETTINGS (perfil / seguridad / logout)
        '/settings': (context) => const SettingsScreen(),

        // ACCOUNT (pantalla de salir que ya tenías)
        '/account': (context) => LogoutScreen(
              vm: VmScope.of(context).get<LoginViewModel>(),
            ),

        // SIGNUP:
        // Aquí creamos un SignUpViewModel NUEVO cada vez que navegamos a /signup,
        // para que el formulario empiece limpio.
        '/signup': (context) {
          return ChangeNotifierProvider<SignUpViewModel>(
            create: (_) => SignUpViewModel(), // <- SIN argumentos
            child: const SignUpScreen(),
          );
        },
      },
    );
  }
}
