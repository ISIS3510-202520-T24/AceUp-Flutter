import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/biometric_service.dart';
import '../../services/auth_service.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authNow());
  }

  Future<void> _authNow() async {
    final bio = BiometricService();
    final ok = await bio.authenticate(reason: 'Use biometrics to continue');

    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/today');
    } else {
      // opcional: cerrar sesión si quieres “cerrar” la app al fallar
      await context.read<AuthService>().signOut();
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fingerprint, size: 96, color: cs.primary),
            const SizedBox(height: 12),
            const Text('Waiting for biometric…'),
          ],
        ),
      ),
    );
  }
}
