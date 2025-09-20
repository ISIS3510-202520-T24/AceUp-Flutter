import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'biometric_screen.dart';
import 'shared_screen.dart';

void main() {
  runApp(const MyApp());
}

class AppTheme {
  static const Color mint = Color(0xFF2ED5AE);   // color del botón
  static const Color pastelBg = Color(0xFFF5F3ED); // fondo pastel clarito

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: mint,
      primary: mint,
    ),
    scaffoldBackgroundColor: Color(0xFFF8F6F0),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth UI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routes: {
        '/': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/biometric': (_) => const BiometricScreen(),
        '/shared': (_) => const SharedScreen(),
      },
    );
  }
}

/// ---------------- LOGIN ----------------
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/logo.png', height: 120),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0E2A47), // azul del mock
                      letterSpacing: 0.5,
                      height: 1.1, // compacta líneas
                    ),
                    children: [
                      TextSpan(text: 'Ace'),
                      TextSpan(
                        text: 'Up',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome Back!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(hintText: 'Email Address'),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: null,
                      icon: const Icon(Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?'),
                      ),
                      // debajo del TextButton "Forgot password?"
                      TextButton.icon(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(context, '/biometric');
                          if (result == true) {
                            // Autenticado: aquí navegas a tu Home real
                            Navigator.pushReplacementNamed(context, '/shared');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Autenticación biométrica OK')),
                            );
                          }
                        },
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Login with Biometrics'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/shared'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.mint,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member? '),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text('Register now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- SIGN UP ----------------
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agree = false;

  Widget _termsSection(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    final linkStyle = textStyle?.copyWith(
      color: AppTheme.mint,
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agree,
          onChanged: (v) => setState(() => _agree = v ?? false),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: textStyle,
              children: [
                const TextSpan(text: "I've read and agree with the "),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: ' and the '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: 120),
                      const SizedBox(height: 8),
                      const Text(
                        'AceUp',
                        style: TextStyle(
                          color: Color(0xFF0F2C4C),
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          letterSpacing: .2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign up',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create an account to access your new student lifestyle!',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 18),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Choose Your Nick',
                    hintText: 'e.g., Luc',
                  ),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'name@email.com',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: null,
                      icon: const Icon(Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    suffixIcon: IconButton(
                      onPressed: null,
                      icon: const Icon(Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _termsSection(context),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/shared'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.mint,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Create account'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
