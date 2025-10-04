import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/login_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../services/secure_store.dart';
import '../../services/biometric_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool _obscure = true;
  bool _showErrors = false;

  // Biometrics
  bool _bioReady = false;   // dispositivo soporta + el usuario la activó
  bool _checkingBio = true;

  @override
  void initState() {
    super.initState();
    // Solo calculamos si mostrar el botón (NO pedimos biometría automáticamente)
    WidgetsBinding.instance.addPostFrameCallback((_) => _computeBioReady());
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  // ---------------- Validadores ----------------
  final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  String? _valEmail(String? v) {
    final x = (v ?? '').trim();
    if (x.isEmpty) return 'Enter your email';
    if (!_emailRegex.hasMatch(x)) return 'Enter a valid email';
    if (x.length > 40) return 'Max 40 characters';
    return null;
  }

  String? _valPass(String? v) {
    final x = (v ?? '').trim();
    if (x.isEmpty) return 'Enter your password';
    if (x.length > 40) return 'Max 40 characters';
    return null;
  }

  // -------- Estilo unificado --------
  InputDecoration _decorStandard(BuildContext ctx, {String? hint, Widget? suffix}) {
    final cs = Theme.of(ctx).colorScheme;
    return InputDecoration(
      hintText: hint,
      counterText: '',
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 1.6),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 1.8),
      ),
      errorStyle: TextStyle(color: cs.error),
      suffixIcon: suffix,
    );
  }

  void _showSnack(String msg) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.surfaceVariant,
          content: Text(msg, style: TextStyle(color: cs.onSurfaceVariant)),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  String _displayName(AuthService auth) {
    final u = auth.currentUser;
    if (u == null) return '';
    final name = (u.displayName ?? '').trim();
    if (name.isNotEmpty) return name;
    final email = u.email ?? '';
    return email.contains('@') ? email.split('@').first : email;
  }

  Future<void> _openForgotPassword() async {
    final form = GlobalKey<FormState>();
    final ctrl = TextEditingController(text: _email.text.trim());
    bool showErrors = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          final cs = Theme.of(ctx).colorScheme;
          InputDecoration _decor() => InputDecoration(
                labelText: 'Email',
                hintText: 'name@email.com',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.error, width: 1.6),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.error, width: 1.8),
                ),
                errorStyle: TextStyle(color: cs.error),
              );

          return AlertDialog(
            title: const Text('Reset password'),
            content: Form(
              key: form,
              autovalidateMode:
                  showErrors ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
              child: TextFormField(
                controller: ctrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _decor(),
                validator: (v) {
                  final x = (v ?? '').trim();
                  if (x.isEmpty) return 'Enter your email';
                  if (!_emailRegex.hasMatch(x)) return 'Enter a valid email';
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  setDialog(() => showErrors = true);
                  if (!form.currentState!.validate()) return;
                  try {
                    await context.read<AuthService>().requestPasswordReset(ctrl.text.trim());
                    if (context.mounted) {
                      Navigator.pop(context);
                      _showSnack('If an account exists, we sent an email to reset your password.');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      _showSnack(e.toString().replaceFirst('Exception: ', ''));
                    }
                  }
                },
                child: const Text('Send'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showVerifyDialog(AuthService auth) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Verify your email'),
        content: const Text('We sent a verification email. Please verify your address before continuing.'),
        actions: [
          TextButton(
            onPressed: () async {
              await auth.sendEmailVerification();
              if (mounted) _showSnack('Verification email re-sent');
            },
            child: const Text('Resend'),
          ),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  // ------- Biometrics helpers -------
  Future<void> _computeBioReady() async {
    final enabled = await SecureStore.biometricEnabled();
    final canBio = await BiometricService().canUseBiometrics();
    if (!mounted) return;
    setState(() {
      _bioReady = enabled && canBio;
      _checkingBio = false;
    });
  }

  Future<bool> _askReplaceDialog({
    required String title,
    required String message,
    String positive = 'Replace',
    String negative = 'Not now',
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(negative)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(positive)),
        ],
      ),
    );
    return res == true;
  }

  Future<void> _handleBiometricAfterLogin({
    required String email,
    required String password,
  }) async {
    final enabled = await SecureStore.biometricEnabled();
    if (!enabled) {
      await _maybeOfferBiometric(email: email, password: password);
      return;
    }

    final stored = await SecureStore.biometricCredentials();
    final storedEmail = (stored.email ?? '');

    if (storedEmail.isEmpty) {
      final save = await _askReplaceDialog(
        title: 'Save for quick login?',
        message: 'Do you want to save this account for biometric login?',
        positive: 'Save',
      );
      if (save) {
        await SecureStore.setBiometricCredentials(email, password);
        await SecureStore.setLastEmail(email);
        await _computeBioReady();
      }
      return;
    }

    if (storedEmail.toLowerCase() == email.toLowerCase()) {
      await SecureStore.setBiometricCredentials(email, password);
      await SecureStore.setLastEmail(email);
      await _computeBioReady();
    } else {
      final replace = await _askReplaceDialog(
        title: 'Replace quick-login account?',
        message:
            'Biometric is already enabled for $storedEmail. Do you want to replace it with $email?',
      );
      if (replace) {
        await SecureStore.setBiometricCredentials(email, password);
        await SecureStore.setLastEmail(email);
        await _computeBioReady();
      }
    }
  }

  Future<void> _maybeOfferBiometric({
    required String email,
    required String password,
  }) async {
    final canBio = await BiometricService().canUseBiometrics();
    if (!canBio) return;

    final already = await SecureStore.biometricEnabled();
    if (already) return;

    final enable = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quick login'),
        content: const Text('Enable biometric unlock for next time?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enable')),
        ],
      ),
    );

    if (enable == true) {
      await SecureStore.setBiometricEnabled(true);
      await SecureStore.setLastEmail(email);
      await SecureStore.setBiometricCredentials(email, password);
      await _computeBioReady();
    }
  }

  Future<void> _tryBiometricLogin() async {
    if (_checkingBio) return;
    setState(() => _checkingBio = true);

    try {
      final ok = await BiometricService().authenticate();
      if (!mounted || !ok) return;

      final auth = context.read<AuthService>();
      await auth.reloadUser();

      if (auth.currentUser != null && auth.isEmailVerified) {
        final name = auth.currentUser?.displayName ?? 'there';
        _showSnack('Welcome back, $name!');
        Navigator.pushReplacementNamed(context, '/today');
        return;
      }

      final stored = await SecureStore.biometricCredentials();
      final email = stored.email;
      final pass  = stored.password;

      if (email == null || pass == null) {
        _showSnack('No saved credentials. Sign in once with email & password.');
        return;
      }

      final vm = context.read<LoginViewModel>();
      final (success, err) = await vm.loginWithEmailPassword(email: email, password: pass);

      if (!mounted) return;

      if (success) {
        final name = auth.currentUser?.displayName ?? 'there';
        _showSnack('Welcome back, $name!');
        Navigator.pushReplacementNamed(context, '/today');
      } else {
        _showSnack(err ?? 'Could not sign in with biometrics.');
      }
    } finally {
      if (mounted) setState(() => _checkingBio = false);
    }
  }

  // ---------------- Submit email/clave ----------------
  Future<void> _submit() async {
    setState(() => _showErrors = true);
    if (!_form.currentState!.validate()) return;

    final vm = context.read<LoginViewModel>();
    final auth = context.read<AuthService>();

    final email = _email.text.trim();
    final password = _pass.text.trim();

    final (ok, err) = await vm.loginWithEmailPassword(email: email, password: password);
    if (!mounted) return;

    if (!ok) {
      _showSnack(err ?? 'Wrong email or password.');
      return;
    }

    await auth.reloadUser();
    if (auth.isEmailVerified) {
      await _handleBiometricAfterLogin(email: email, password: password);
      _showSnack('Welcome back, ${_displayName(auth)} 👋');
      Navigator.pushReplacementNamed(context, '/today');
    } else {
      await _showVerifyDialog(auth);
      await auth.signOut();
      _showSnack('Please verify your email to continue');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<LoginViewModel>().loading;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final autoMode =
        _showErrors ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _form,
              autovalidateMode: autoMode,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  SvgPicture.asset('assets/logos/t_blue.svg', height: 180),
                  const SizedBox(height: 12),
                  Text('AceUp',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      )),
                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Welcome Back!',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _email,
                    maxLength: 40,
                    keyboardType: TextInputType.emailAddress,
                    validator: _valEmail,
                    decoration: _decorStandard(context, hint: 'Email Address'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _pass,
                    maxLength: 40,
                    obscureText: _obscure,
                    validator: _valPass,
                    decoration: _decorStandard(
                      context,
                      hint: 'Password',
                      suffix: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _openForgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in'),
                    ),
                  ),

                  // Botón secundario para biometría (solo si está listo)
                  if (_bioReady) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _checkingBio ? null : _tryBiometricLogin,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Sign in with biometrics'),
                      ),
                    ),
                  ],

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
      ),
    );
  }
}
