// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Provider
import 'package:provider/provider.dart';

// Servicios
import 'services/notif/notification_service.dart';
import 'services/startup_ttfp.dart';
import 'services/auth/auth_service.dart';
import 'services/auth/biometric_service.dart';
import 'services/profile/profile_notifier.dart';
import 'services/shared/sync_service.dart';

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

// Core
import 'core/observer/vm_scope.dart';
import 'core/connectivity/connectivity_manager.dart';

// Data
import 'data/local/database/app_database.dart';
import 'data/repositories/shared_repository.dart';

// Tema
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Marcador de tiempo de arranque (para métricas de TTFP en consola)
  StartupTTFP.start();

  // 2) Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3) Initialize local database
  final database = AppDatabase();
  
  // 4) Initialize connectivity manager
  final connectivity = ConnectivityManager();
  await connectivity.initialize();
  
  // 5) Initialize SharedRepository
  final sharedRepository = SharedRepository(
    database: database,
    firestore: FirebaseFirestore.instance,
    connectivity: connectivity,
  );
  
  // 6) Start background sync service
  final syncService = SyncService(
    database: database,
    firestore: FirebaseFirestore.instance,
    connectivity: connectivity,
  );
  syncService.startPeriodicSync();
  
  print('✅ Eventual connectivity initialized');

  // 7) Notificaciones
  await NotificationService().initNotifications();

  // 8) Servicios y VMs (para nuestro Observer)
  final authService = AuthService();
  final bioService = BiometricService();

  // 9) Instanciar VMs que viven "global"
  final loginVM = LoginViewModel(authService, bioService);
  // SignUpViewModel se crea en la ruta, no lo registramos globalmente

  // 10) Registrar en VmRegistry (nuestro contenedor simple)
  final registry = VmRegistry()
    ..put<AuthService>(authService)
    ..put<BiometricService>(bioService)
    ..put<SharedRepository>(sharedRepository)
    ..put<ConnectivityManager>(connectivity)
    ..put<SyncService>(syncService)
    ..put<LoginViewModel>(loginVM);

  // (debug opcional)
  registry.debugPrintKeys();

  // 11) runApp con VmScope y luego MultiProvider
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
          Provider<SharedRepository>.value(value: sharedRepository),
          Provider<ConnectivityManager>.value(value: connectivity),
          
          // SyncService es ChangeNotifier, debe usar ChangeNotifierProvider
          ChangeNotifierProvider<SyncService>.value(value: syncService),

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
        // Creamos un SignUpViewModel NUEVO cada vez que navegamos a /signup,
        // para que el formulario empiece limpio.
        '/signup': (context) {
          return ChangeNotifierProvider(
            create: (_) => SignUpViewModel(),
            child: const SignUpScreen(),
          );
        },
      },
    );
  }
}
