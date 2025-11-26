// lib/views/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ignore: uri_does_not_exist

import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/auth/login_viewmodel.dart';

// ignore_for_file: undefined_identifier

/// Pantalla de Login
/// Requiere que le inyectes un LoginViewModel (por Provider, VmScope, etc.)
class LoginScreen extends StatefulWidget {
  final LoginViewModel vm;
  const LoginScreen({
    super.key,
    required this.vm,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _showErrors = false;
  bool _obscure = true;
  bool _checkingBio = false;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios del VM para redibujar
    widget.vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    widget.vm.removeListener(_onVmChanged);
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  // === InputDecoration consistente con tu estilo ===
  InputDecoration _decorStandard(
    BuildContext ctx, {
    String? hint,
    Widget? suffix,
  }) {
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
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            msg,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
  }

  /// Diálogo para preguntar si reemplazar credenciales biométricas guardadas.
  Future<bool> _askReplaceDialog({
    required String title,
    required String message,
    String positive = 'Replace',
    String negative = 'Keep current',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(negative),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(positive),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Diálogo cuando el usuario todavía no verificó el correo
  Future<void> _showVerifyDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Email not verified'),
          content: const Text(
            'Your email is not verified yet. Would you like us to resend a verification email?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await widget.vm.resendVerificationEmail();
                if (!mounted) return;
                _showSnack('Verification email sent.');
              },
              child: const Text('Resend'),
            ),
          ],
        );
      },
    );
  }

  /// Acción principal de Login (botón "Login").
  ///
  /// Flujo:
  /// - valida form
  /// - vm.login()
  /// - si necesita verificación, mostramos diálogo
  /// - si OK, preguntamos por biometría / guardamos credenciales
  /// - navegamos a /today
  Future<void> _submit() async {
    setState(() {
      _showErrors = true;
    });

    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    // pasar credenciales al VM
    widget.vm.setEmail(email);
    widget.vm.setPassword(password);

    final res = await widget.vm.login();
    if (!mounted) return;

    if (!res.ok) {
      // login falló
      if (res.needsEmailVerification) {
        // correo sin verificar -> pop up para reenviar
        await _showVerifyDialog();
      }
      _showSnack(res.message ?? 'Login failed');
      return;
    }

    // Login OK (online o offline). Ahora biometría como UX opcional:
    final canStore = await widget.vm.canStoreBiometric();
    if (canStore) {
      final check = await widget.vm.checkBiometricCredentials();
      final storedEmail = (check.storedEmail ?? '');

      if (storedEmail.isEmpty ||
          storedEmail.toLowerCase() == email.toLowerCase()) {
        // o no había nada, o ya coincide este usuario
        await widget.vm.saveBiometricCredentials(
          email: email,
          password: password,
        );
      } else {
        // había otra cuenta guardada → preguntar si reemplazar
        final replace = await _askReplaceDialog(
          title: 'Replace quick-login account?',
          message:
              'Biometrics is set for $storedEmail. Replace with $email?',
          positive: 'Replace',
          negative: 'Keep current',
        );
        if (replace) {
          await widget.vm.saveBiometricCredentials(
            email: email,
            password: password,
          );
        }
      }
    }

    _showSnack('Welcome back, ${widget.vm.displayNameOrEmail} 🔥');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/today');
  }

  /// "Forgot password?" link
  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Enter your email first.');
      return;
    }

    final res = await widget.vm.forgotPassword(email);
    if (res.ok) {
      _showSnack('Reset link sent to $email');
    } else {
      _showSnack(res.message ?? 'Could not send reset link');
    }
  }

  /// Botón "Sign in with biometrics"
  Future<void> _loginWithBiometric() async {
    if (_checkingBio) return;
    setState(() {
      _checkingBio = true;
    });

    try {
      final res = await widget.vm.loginWithBiometrics();
      if (!res.ok) {
        if (res.needsEmailVerification) {
          await _showVerifyDialog();
        }
        _showSnack(res.message ?? 'Biometric login failed.');
        return;
      }

      _showSnack('Welcome back, ${widget.vm.displayNameOrEmail} 🔥');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/today');
    } finally {
      if (mounted) {
        setState(() {
          _checkingBio = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final vm = widget.vm;

    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: colors.surfaceDim,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- TOP: Logo AceUp grande ----------
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: SvgPicture.asset(
                      isLight
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

            // ---------- BOTTOM: Formulario ----------
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _showErrors
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'Welcome Back!',
                        style: AppTypography.h1.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // EMAIL
                      TextFormField(
                        controller: _emailCtrl,
                        maxLength: 40,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'[;]')),
                        ],
                        validator: (_) {
                          final v = _emailCtrl.text.trim();
                          if (v.isEmpty) return 'Email required';
                          if (!v.contains('@')) return 'Invalid email';
                          return null;
                        },
                        decoration: _decorStandard(
                          context,
                          hint: 'Email Address',
                        ),
                      ),

                      const SizedBox(height: 12),

                      // PASSWORD
                      TextFormField(
                        controller: _passCtrl,
                        maxLength: 40,
                        obscureText: _obscure,
                        validator: (_) {
                          final v = _passCtrl.text;
                          if (v.isEmpty) return 'Password required';
                          if (v.length < 6) return 'Min 6 chars';
                          return null;
                        },
                        decoration: _decorStandard(
                          context,
                          hint: 'Password',
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? AppIcons.visibilityOff
                                  : AppIcons.visibilityOn,
                              size: 18,
                            ),
                            color: colors.outline,
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: vm.loading ? null : _forgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // LOGIN button
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: vm.loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: vm.loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: AppTypography.actionM,
                                ),
                        ),
                      ),

                      // biometría
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: (vm.loading || _checkingBio)
                              ? null
                              : _loginWithBiometric,
                          icon: const Icon(Icons.fingerprint),
                          label: _checkingBio
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign in with biometrics',
                                  style: AppTypography.actionM,
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // link a signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New to AceUp? ',
                            style: AppTypography.bodyS.copyWith(
                              color: colors.onPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: vm.loading
                                ? null
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      '/signup',
                                    );
                                  },
                            child: const Text('Register now'),
                          ),
                        ],
                      ),

                      // Mostrar error global del VM si existe
                      if (vm.error != null && vm.error!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          vm.error!,
                          style: AppTypography.bodyS.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ],
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
