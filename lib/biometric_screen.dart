import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final _auth = LocalAuthentication();

  static const Color _bg   = Color(0xFFF6F3EA); // crema fondo logo
  static const Color _mint = Color(0xFF2AD9B1); // menta
  static const Color _navy = Color(0xFF0F2C4C); // azul

  bool _canCheck = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final can = await _auth.canCheckBiometrics;
      if (!mounted) return;
      setState(() => _canCheck = can);
    } catch (_) {}
  }

  Future<void> _authenticate() async {
    setState(() => _busy = true);
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: false,    // permite PIN/pattern si no hay huella
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (!mounted) return;
      if (ok) {
        // navega al Home o vuelve a Login
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication cancelled')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canTap = _canCheck && !_busy;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _navy,
        title: const Text('Biometric login',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              // Brand
              Column(
                children: [
                  Image.asset('assets/logo.png', width: 72, height: 72),
                  const SizedBox(height: 8),
                  const Text(
                    'AceUp',
                    style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: .2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Title + subtitle
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Protect your account',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enable fingerprint or face recognition to sign in faster.',
                  style: TextStyle(
                    color: Colors.black.withOpacity(.55),
                    height: 1.35,
                  ),
                ),
              ),
              const Spacer(),

              // Primary action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canTap ? _authenticate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mint,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Use biometrics',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 14),

              // Secondary action
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Use email/password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
