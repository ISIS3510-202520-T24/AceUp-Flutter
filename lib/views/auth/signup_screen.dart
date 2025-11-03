// lib/views/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../themes/app_typography.dart';
import '../../viewmodels/auth/signup_viewmodel.dart';

/// Pantalla de registro con Terms of Service accesibles
/// y estilos alineados al login_screen.
/// Usa Provider<SignUpViewModel> (inyectado desde main.dart)
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignUpViewModel>();
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surfaceDim,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isLight
                  ? 'assets/logos/t_blue.svg'
                  : 'assets/logos/t_white.svg',
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text('AceUp'),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Header(isLight: isLight),
            const SizedBox(height: 24),

            _NicknameField(vm: vm),
            const SizedBox(height: 16),

            _EmailField(vm: vm),
            const SizedBox(height: 16),

            _PasswordField(vm: vm),
            const SizedBox(height: 16),

            _ConfirmField(vm: vm),
            const SizedBox(height: 16),

            _TermsAndConditions(vm: vm),

            const SizedBox(height: 24),

            _SubmitButton(vm: vm),

            const SizedBox(height: 24),

            // error global
            if (vm.errorGlobal != null && vm.errorGlobal!.isNotEmpty)
              Text(
                vm.errorGlobal!,
                style: AppTypography.bodyS.copyWith(
                  color: cs.error,
                ),
              ),

            // info message
            if (vm.infoMessage != null && vm.infoMessage!.isNotEmpty)
              Text(
                vm.infoMessage!,
                style: AppTypography.bodyS.copyWith(
                  color: cs.secondary,
                ),
              ),

            const SizedBox(height: 32),

            // back to login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: AppTypography.bodyS.copyWith(
                    color: cs.secondary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text('Log in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// Encabezado (branding + texto)
// ===============================
class _Header extends StatelessWidget {
  final bool isLight;
  const _Header({required this.isLight});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          isLight ? 'assets/logos/t_blue.svg' : 'assets/logos/t_white.svg',
          height: 60,
        ),
        const SizedBox(height: 8),
        Text(
          'Create your account',
          style: AppTypography.h4.copyWith(
            color: cs.onPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sync classes, assignments, and holidays across devices.',
          style: AppTypography.bodyM.copyWith(
            color: cs.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ===============================
// Nickname
// ===============================
class _NicknameField extends StatelessWidget {
  final SignUpViewModel vm;
  const _NicknameField({required this.vm});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: vm.setNickname,
      decoration: InputDecoration(
        labelText: 'Nickname',
        errorText: vm.errorNickname,
      ),
    );
  }
}

// ===============================
// Email
// ===============================
class _EmailField extends StatelessWidget {
  final SignUpViewModel vm;
  const _EmailField({required this.vm});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      onChanged: vm.setEmail,
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: vm.errorEmail,
      ),
    );
  }
}

// ===============================
// Password
// ===============================
class _PasswordField extends StatefulWidget {
  final SignUpViewModel vm;
  const _PasswordField({required this.vm});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return TextField(
      obscureText: _obscure,
      onChanged: vm.setPassword,
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: vm.errorPassword,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
          icon: Icon(
            _obscure ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
    );
  }
}

// ===============================
// Confirm password
// ===============================
class _ConfirmField extends StatefulWidget {
  final SignUpViewModel vm;
  const _ConfirmField({required this.vm});

  @override
  State<_ConfirmField> createState() => _ConfirmFieldState();
}

class _ConfirmFieldState extends State<_ConfirmField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return TextField(
      obscureText: _obscure,
      onChanged: vm.setPasswordConfirm,
      decoration: InputDecoration(
        labelText: 'Confirm password',
        errorText: vm.errorConfirm,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
          icon: Icon(
            _obscure ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
    );
  }
}

// ===============================
// Términos y Condiciones
// ===============================
class _TermsAndConditions extends StatelessWidget {
  final SignUpViewModel vm;
  const _TermsAndConditions({required this.vm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: vm.form.acceptTerms,
              onChanged: (v) {
                vm.setAcceptTerms(v ?? false);
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _openTermsSheet(context);
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'I agree to the ',
                        style: AppTypography.bodyS.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        style: AppTypography.bodyS.copyWith(
                          color: cs.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: ' and the ',
                        style: AppTypography.bodyS.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTypography.bodyS.copyWith(
                          color: cs.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text:
                            '. I understand that my schedule, assignments, and holidays may sync using cloud backup.',
                        style: AppTypography.bodyS.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // error visual si no aceptó términos
        if (vm.errorGlobal == 'TERMS')
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'You must accept terms.',
              style: AppTypography.bodyS.copyWith(
                color: cs.error,
              ),
            ),
          ),
      ],
    );
  }
}

/// BottomSheet con Términos y Privacidad
void _openTermsSheet(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terms & Privacy',
                      style: AppTypography.h4.copyWith(
                        color: cs.onPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  'AceUp Terms of Service',
                  style: AppTypography.h4.copyWith(
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By creating an account you agree that this app will store and sync certain academic data '
                  'such as assignments, deadlines, classes, and holidays. We use this data ONLY to help you plan.',
                  style: AppTypography.bodyS.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Privacy Policy',
                  style: AppTypography.h4.copyWith(
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We respect your privacy. Your schedule and course data belongs to you. '
                  'We may back it up in the cloud so you can access it from multiple devices, '
                  'and to enable optional features like biometric quick login.',
                  style: AppTypography.bodyS.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Data Retention',
                  style: AppTypography.h4.copyWith(
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'If you delete your account, we will remove any stored personal data from our cloud. '
                  'Some anonymized usage statistics may be kept to help us improve.',
                  style: AppTypography.bodyS.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// ===============================
// Botón principal "Create account"
// ===============================
class _SubmitButton extends StatelessWidget {
  final SignUpViewModel vm;
  const _SubmitButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FilledButton(
      onPressed: vm.loading
          ? null
          : () async {
              // ejecuta el flujo de registro
              final res = await vm.signup();
              if (!context.mounted) return;

              if (res.ok) {
                // registro OK -> saltar a /today
                Navigator.pushReplacementNamed(context, '/today');
              } else {
                // algo falló -> mostrar SnackBar
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
                        res.message ?? 'Sign up failed.',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  );
              }
            },
      child: vm.loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Create account'),
    );
  }
}
