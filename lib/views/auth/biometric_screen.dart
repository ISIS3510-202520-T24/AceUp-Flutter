import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth/biometric_service.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/secure_store.dart';
import '../../viewmodels/auth/login_viewmodel.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  bool _checking = false;
  String? _debugInfo; // opcional

  Future<void> _tryAuth() async {
    if (_checking) return;
    setState(() => _checking = true);

    try {
      // Diagnóstico opcional
      final info = await BiometricService().debugSummary();
      if (mounted) setState(() => _debugInfo = info);

      final ok = await BiometricService().authenticate();
      if (!mounted) return;

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric auth cancelled / failed')),
        );
        return;
      }

      // Si hay credenciales guardadas, intenta el login
      final stored = await SecureStore.biometricCredentials();
      final email = stored.email;
      final pass  = stored.password;

      if (email == null || pass == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No saved credentials. Sign in once with email & password.')),
        );
        return;
      }

      final vm = context.read<LoginViewModel>();
      final (success, err) = await vm.loginWithEmailPassword(email: email, password: pass);

      if (!mounted) return;

      if (success) {
        final auth = context.read<AuthService>();
        await auth.reloadUser();
        if (auth.isEmailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Welcome back!')),
          );
          Navigator.pushReplacementNamed(context, '/today');
        } else {
          await auth.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please verify your email to continue')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err ?? 'Could not sign in with biometrics.')),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              'Use your fingerprint/face to continue.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Botón principal (mismo estilo que el de Sign in normal)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _checking ? null : _tryAuth,
                icon: const Icon(Icons.fingerprint),
                label: _checking
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in with biometrics'),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () async {
                await auth.signOut();
                if (mounted) Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Use another account'),
            ),

            const Spacer(),

            if (_debugInfo != null)
              Text(
                'Debug: $_debugInfo',
                style: TextStyle(color: colors.outline),
              ),
          ],
        ),
      ),
    );
  }
}
