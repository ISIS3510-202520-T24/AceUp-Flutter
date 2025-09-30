import 'package:flutter/material.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/auth/biometric_screen.dart';
import 'views/holidays/holidays_screen.dart';
import 'views/today/today_screen.dart';

class AppTheme {
  static const Color mint = Color(0xFF2ED5AE);
  static const Color pastelBg = Color(0xFFF5F3ED);

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: mint,
      primary: mint,
    ),
    scaffoldBackgroundColor: Color(0xFFF8F6F0),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AceUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/biometric': (context) => const BiometricScreen(),
        '/today': (context) => const TodayScreen(),
        '/holidays': (context) => const HolidaysScreen(),
      },
    );
  }
}



