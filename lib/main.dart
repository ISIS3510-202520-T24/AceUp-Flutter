import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/signup_viewmodel.dart';
import 'viewmodels/holidays_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart'; //ignore: uri_does_not_exist
import 'package:provider/provider.dart';
import 'services/notification_service.dart';

//ignore_for_file: non_type_as_type_argument

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/biometric': (context) => const BiometricScreen(),
        '/today': (context) => const TodayScreen(),
        '/holidays': (context) => const HolidaysScreen(),
        '/account': (context) => const LogoutScreen(),
        '/shared': (context) => const SharedScreenWrapper(),
        '/assignments' : (context) => const AssignmentsScreen(),
      },
    );
  }
}