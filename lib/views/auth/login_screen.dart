import 'package:flutter/material.dart';
import '../../main.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ignore: uri_does_not_exist
import '../../themes/app_icons.dart';
import '../../themes/app_theme.dart';
import '../../widgets/buttons.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceDim,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 40),
                SvgPicture.asset('assets/logos/t_blue.svg', height: 250), // ignore: undefined_identifier
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: colors.onPrimary,
                      letterSpacing: 0.5,
                      height: 1.1,
                    ),
                    children: const [
                      TextSpan(
                        text: 'AceUp',
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
                        ?.copyWith(fontWeight: FontWeight.w700, color: colors.onPrimary),
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
                      icon: Icon(AppIcons.visibilityOff),
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
                      TextButton.icon(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(context, '/biometric');
                          if (result == true) {
                            Navigator.pushReplacementNamed(context, '/today');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Biometric authentication OK')),
                            );
                          }
                        },
                        icon: Icon(AppIcons.fingerprint),
                        label: const Text('Login with Biometrics'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Button(
                    type: ButtonType.primary,
                    text: 'Login',
                    onPressed: () => Navigator.pushReplacementNamed(context, '/today'),
                  )
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
