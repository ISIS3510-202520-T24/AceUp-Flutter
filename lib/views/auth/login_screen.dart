import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aceup_clean/themes/app_icons.dart';
import 'package:aceup_clean/themes/app_typography.dart';
import 'package:aceup_clean/viewmodels/auth/login_viewmodel.dart';

// Solo si este screen usa estos helpers directamente:
import 'package:aceup_clean/services/auth/secure_store.dart';

import 'package:aceup_clean/services/startup_ttfp.dart'; // tu archivo está en lib/startup_ttfp.dart
// import 'package:aceup_clean/widgets/buttons.dart'; // déjalo solo si existe

import 'package:aceup_clean/models/auth_model.dart';

class LoginScreen extends StatefulWidget {
  final LoginViewModel vm;
  const LoginScreen({super.key, required this.vm});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool _obscure = true;
  bool _showErrors = false;
  bool _checkingBio = false;

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Marca el primer frame del Login para el TTFP (no await)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StartupTTFP.markLoginFirstFrame();
    });
    widget.vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    widget.vm.removeListener(_onVmChanged);
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  InputDecoration _decorStandard(BuildContext ctx, {String? hint, Widget? suffix}) {
    final colors = Theme.of(ctx).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.secondary),
      counterText: '',
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.onError, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.onError, width: 1.5),
      ),
      errorStyle: TextStyle(color: colors.onError),
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
          backgroundColor: cs.surfaceDim,
          content: Text(msg, style: TextStyle(color: cs.onSurfaceVariant)),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  Future<void> _openForgotPassword() async {
    final form = GlobalKey<FormState>();
    final ctrl = TextEditingController(text: _email.text.trim());
    bool showErrors = false;

    await showDialog(
      context: context,
      builder: (ctx) {
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

        return StatefulBuilder(
          builder: (ctx, setDialog) => AlertDialog(
            title: const Text('Reset password'),
            content: Form(
              key: form,
              autovalidateMode:
                  showErrors ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
              child: TextFormField(
                controller: ctrl,
                keyboardType: TextInputType.emailAddress,
                maxLength: 40,
                inputFormatters: [
                  // Bloquea el carácter ';' al escribir
                  FilteringTextInputFormatter.deny(RegExp(r'[;]')),
                ],
                decoration: _decor().copyWith(
                  counterText: '', // oculta el contador si no lo quieres ver
                ),
                validator: (v) => LoginForm.validateEmail(v ?? ''),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  setDialog(() => showErrors = true);
                  if (!form.currentState!.validate()) return;
                  final res = await widget.vm.forgotPassword(ctrl.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    _showSnack(res.message ?? (res.ok ? 'Email sent' : 'Could not send reset email'));
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showVerifyDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Verify your email'),
        content: const Text('We sent a verification email. Please verify your address before continuing.'),
        actions: [
          TextButton(
            onPressed: () async {
              await widget.vm.resendVerificationEmail();
              if (mounted) _showSnack('Verification email re-sent');
            },
            child: const Text('Resend'),
          ),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
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

  Future<void> _submit() async {
    setState(() => _showErrors = true);
    if (!_form.currentState!.validate()) return;

    final email = _email.text.trim();
    final password = _pass.text.trim();

    widget.vm
      ..setEmail(email)
      ..setPassword(password);

    final res = await widget.vm.login();
    if (!mounted) return;

    if (!res.ok) {
      if (res.needsEmailVerification) {
        await _showVerifyDialog();
      }
      _showSnack(res.message ?? 'Wrong email or password.');
      return;
    }

    // Post-login: biometría
    final check = await widget.vm.biometricPostLoginCheck(email);
    if (check.supported) {
      if (!check.enabled) {
        final ok = await _askReplaceDialog(
          title: 'Enable quick login?',
          message: 'Save $email for biometric login?',
          positive: 'Save',
          negative: 'Not now',
        );
        if (ok) {
          await widget.vm.saveBiometricCredentials(email: email, password: password);
        }
      } else {
        final stored = (check.storedEmail ?? '');
        if (stored.isEmpty || stored.toLowerCase() == email.toLowerCase()) {
          await widget.vm.saveBiometricCredentials(email: email, password: password);
        } else {
          final replace = await _askReplaceDialog(
            title: 'Replace quick-login account?',
            message: 'Biometrics is set for $stored. Replace with $email?',
            positive: 'Replace',
            negative: 'Keep current',
          );
          if (replace) {
            await widget.vm.saveBiometricCredentials(email: email, password: password);
          }
        }
      }
    }

    _showSnack('Welcome back, ${widget.vm.displayNameOrEmail} 👋');
    Navigator.pushReplacementNamed(context, '/today');
  }

  Future<void> _onBiometricPressed() async {
    if (_checkingBio) return;
    setState(() => _checkingBio = true);
    try {
      final res = await widget.vm.loginWithBiometrics();
      if (!mounted) return;
      if (res.ok) {
        _showSnack('Welcome back!');
        Navigator.pushReplacementNamed(context, '/today');
      } else {
        if (res.needsEmailVerification) {
          await _showVerifyDialog();
        }
        _showSnack(res.message ?? 'Could not sign in with biometrics.');
      }
    } finally {
      if (mounted) setState(() => _checkingBio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = widget.vm.loading;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final autoMode = _showErrors ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled;

    return Scaffold(
      backgroundColor: colors.surfaceDim,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- TOP ----------
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: SvgPicture.asset(
                      theme.brightness == Brightness.light
                          ? 'assets/logos/t_blue.svg'
                          : 'assets/logos/t_white.svg',
                      width: MediaQuery.of(context).size.width * 0.5,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'AceUp',
                        style: AppTypography.logo.copyWith(
                          color: colors.onPrimary,
                          fontSize: 54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------- BOTTOM ----------
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Form(
                  key: _form,
                  autovalidateMode: autoMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Text('Welcome Back!',
                          style: AppTypography.h1.copyWith(color: colors.onPrimary)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _email,
                        maxLength: 40,
                        keyboardType: TextInputType.emailAddress,
                        validator: (_) => LoginForm.validateEmail(_email.text),
                        decoration: _decorStandard(context, hint: 'Email Address'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pass,
                        maxLength: 40,
                        obscureText: _obscure,
                        validator: (_) => LoginForm.validatePassword(_pass.text),
                        decoration: _decorStandard(
                          context,
                          hint: 'Password',
                          suffix: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? AppIcons.visibilityOff : AppIcons.visibilityOn, size: 18),
                            color: colors.outline,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(onPressed: _openForgotPassword, child: const Text('Forgot password?')),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Login', style: AppTypography.actionM),
                        ),
                      ),

                      // Biometría (si hay soporte)
                      const SizedBox(height: 6),
                      FutureBuilder<bool>(
                        future: widget.vm.canUseBiometrics(),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) return const SizedBox.shrink();
                          final canBio = snap.data == true;
                          if (!canBio) return const SizedBox.shrink();

                          return SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _checkingBio ? null : _onBiometricPressed,
                              icon: Icon(AppIcons.fingerprint),
                              label: _checkingBio
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Sign in with biometrics', style: AppTypography.actionM),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('New to AceUp? ', style: AppTypography.bodyS.copyWith(color: colors.onPrimary)),
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
          ],
        ),
      ),
    );
  }
}
