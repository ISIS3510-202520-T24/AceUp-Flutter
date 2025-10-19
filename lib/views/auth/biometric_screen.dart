import 'package:flutter/material.dart';
import 'package:aceup_clean/viewmodels/auth/login_viewmodel.dart';

class BiometricScreen extends StatefulWidget {
  final LoginViewModel vm;
  const BiometricScreen({super.key, required this.vm});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  bool _checking = false;
  String? _debugInfo;

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    widget.vm.removeListener(_onVmChanged);
    super.dispose();
  }

  Future<void> _tryAuth() async {
    if (_checking) return;
    setState(() => _checking = true);

    try {
      final info = await widget.vm.debugBiometricSummary();
      if (mounted) setState(() => _debugInfo = info);

      final res = await widget.vm.loginWithBiometrics();
      if (!mounted) return;

      if (res.ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome back!')));
        Navigator.pushReplacementNamed(context, '/today');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Biometric auth failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text('Use your fingerprint/face to continue.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _checking ? null : _tryAuth,
                icon: const Icon(Icons.fingerprint),
                label: _checking
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Sign in with biometrics'),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                await widget.vm.signOut();
                if (mounted) Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Use another account'),
            ),
            const Spacer(),
            if (_debugInfo != null)
              Text('Debug: $_debugInfo', style: TextStyle(color: colors.outline)),
          ],
        ),
      ),
    );
  }
}
