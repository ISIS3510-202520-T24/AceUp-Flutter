import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show User; // ignore: uri_does_not_exist
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Provider
import 'package:provider/provider.dart';

// Servicios
import 'services/grades/gpa_calculation_service.dart';
import 'services/notif/notification_service.dart';
import 'services/startup_ttfp.dart';
import 'services/auth/auth_service.dart';
import 'services/auth/biometric_service.dart';
import 'services/profile/profile_notifier.dart';
import 'services/shared/sync_service.dart';
import 'services/storage/hive_service.dart';
import 'services/storage/app_preferences.dart';

// ViewModels
import 'viewmodels/auth/login_viewmodel.dart';
import 'viewmodels/auth/signup_viewmodel.dart';
import 'viewmodels/holidays/holidays_viewmodel.dart';

// Vistas
import 'views/auth/login_screen.dart';
import 'views/auth/biometric_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/settings/account_screen.dart';
import 'views/planner/planner_screen.dart';
import 'views/today/today_screen.dart';
import 'views/holidays/holidays_screen.dart';
import 'views/assignments/assignments_screen.dart';
import 'views/shared/shared_screen.dart';
import 'views/shared/group_stats_screen.dart';
import 'views/settings/settings_screen.dart';

// Core
import 'core/observer/vm_scope.dart';
import 'core/connectivity/connectivity_manager.dart';

// Data
import 'data/local/database/app_database.dart';

// Tema
import 'themes/app_theme.dart';

// 🔹 NUEVO: AuthGate para sesión persistente
import 'widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Marcador de tiempo de arranque (para métricas de TTFP en consola)
  StartupTTFP.start();

  // 2) Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2.5) Inicializar Hive (BD Llave/Valor)
  await HiveService.instance.initialize();
  print('Hive initialized');

  // 2.6) Inicializar SharedPreferences
  await AppPreferences.instance.initialize();
  print('SharedPreferences initialized');

  // 3) Initialize local database
  final database = AppDatabase();
  
  // 4) Initialize connectivity manager
  final connectivity = ConnectivityManager();
  await connectivity.initialize();
  
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

          ProxyProvider<AppDatabase, GpaCalculationService>(
            update: (_, db, __) => GpaCalculationService(database: db), 
          ),

          // Exponer servicios para pantallas que hacen context.read<AuthService>()
          Provider<AuthService>.value(value: authService),
          Provider<BiometricService>.value(value: bioService),
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
    '/': (context) => AuthGate(
          home: const TodayScreen(),
          login: LoginScreen(
            vm: VmScope.of(context).get<LoginViewModel>(),
          ),
        ),

    '/biometric': (context) => BiometricScreen(
          vm: VmScope.of(context).get<LoginViewModel>(),
        ),
    '/today': (context) => const TodayScreen(),
    '/holidays': (context) => const HolidaysScreen(),
    '/shared': (context) => const SharedScreenWrapper(),
    '/planner' : (context) => const PlannerScreen(),
    '/assignments': (context) => const AssignmentsScreen(),
    '/settings': (context) => const SettingsScreen(),
    '/group-stats': (context) => const GroupStatsScreen(),
    '/account': (context) => AccountScreen(),
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