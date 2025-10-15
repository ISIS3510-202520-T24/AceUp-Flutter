import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ignore: uri_does_not_exist
import 'package:provider/provider.dart';

import '../../themes/app_icons.dart';
import '../../themes/app_typography.dart';
import '../../viewmodels/auth/signup_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _nick = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  bool _agree = false;
  bool _ob1 = true, _ob2 = true;
  bool _loading = false;

  // Mostrar errores solo tras 1er intento
  bool _showErrors = false;

  @override
  void dispose() {
    _nick.dispose(); _email.dispose(); _pass.dispose(); _pass2.dispose();
    super.dispose();
  }

  // ---------------- Validators ----------------
  String? _vNick(String? v) {
    final x = (v ?? '').trim();
    if (x.isEmpty) return 'Choose a nickname';
    if (x.length > 40) return 'Max 40 characters';
    return null;
  }

  final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  String? _vEmail(String? v) {
    final x = (v ?? '').trim();
    if (x.isEmpty) return 'Enter your email';
    if (!_emailRegex.hasMatch(x)) return 'Enter a valid email';
    if (x.length > 40) return 'Max 40 characters';
    return null;
  }

  // At least 8 chars, one uppercase letter and one number
  final _pwdRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
  String? _vPass(String? v) {
    final x = (v ?? '').trim();
    if (x.isEmpty) return 'Enter your password';
    if (x.length > 40) return 'Max 40 characters';
    if (!_pwdRegex.hasMatch(x)) {
      return 'Password must be 8+ chars, 1 uppercase, 1 number';
    }
    return null;
  }

  // Confirm password: solo que coincida
  String? _vConfirm(String? v) {
    final x = (v ?? '').trim();
    if (x.isEmpty) return 'Confirm your password';
    if (x != _pass.text.trim()) return 'Passwords do not match';
    return null;
  }

  // --------------- Estilo uniforme ---------------
  InputDecoration _decorStandard(BuildContext ctx,
      {String? label, String? hint, Widget? suffix}) {
    final colors = Theme.of(ctx).colorScheme;
    return InputDecoration(
      labelText: label,
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

  // ---------------- Terms modal (English) ----------------
  void _openTerms() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      constraints: const BoxConstraints(maxHeight: 600),
      builder: (_) {
        final textStyle = Theme.of(context).textTheme.bodyMedium;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: ListView(
            children: [
              Text('Terms & Conditions',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('1. Acceptance of Service',
                  style: textStyle?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text(
                  'By creating an account on AceUp you agree to follow our usage rules, privacy policy, and community guidelines.'),
              const SizedBox(height: 12),
              Text('2. Acceptable Use',
                  style: textStyle?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text(
                  'You may not use the service for unlawful activities, spam, or attempts to compromise system security.'),
              const SizedBox(height: 12),
              Text('3. Data & Privacy',
                  style: textStyle?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text(
                  'We process your data according to the Privacy Policy. You can request deletion of your account at any time.'),
              const SizedBox(height: 12),
              Text('4. Intellectual Property',
                  style: textStyle?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text(
                  'AceUp trademarks and content belong to their respective owners. Do not use them without permission.'),
              const SizedBox(height: 12),
              Text('5. Changes',
                  style: textStyle?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text(
                  'We may update these terms. We will notify you of material changes.'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _snack(String msg) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.error,
          content: Text(msg, style: TextStyle(color: colors.onError)),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  Future<void> _showVerificationDialog() async {
    await showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('We sent you an email ✉️'),
        content: Text(
            'Please verify your address (check inbox and spam). You can sign in once your email is verified.'),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _showErrors = true); // desde aquí ya valida visualmente
    if (!_form.currentState!.validate()) return;

    if (!_agree) {
      _snack('Please accept the Terms & Privacy');
      return;
    }

    setState(() => _loading = true);
    final (ok, err) = await context.read<SignUpViewModel>().signUpWithEmailPassword(
          nickname: _nick.text.trim(),
          email: _email.text.trim(),
          password: _pass.text.trim(),
        );
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      await _showVerificationDialog();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
    } else {
      _snack(err ?? 'Could not register');
    }
  }

  Widget _termsSection(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    final linkStyle = textStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? false)),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            text: TextSpan(style: textStyle, children: [
              const TextSpan(text: 'I have read and accept the '),
              TextSpan(
                  text: 'Terms & Conditions',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()..onTap = _openTerms),
              const TextSpan(text: ' and the '),
              TextSpan(
                  text: 'Privacy Policy',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()..onTap = _openTerms),
              const TextSpan(text: '.'),
            ]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final autoMode = _showErrors
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent, backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _form,
              autovalidateMode: autoMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        SvgPicture.asset('assets/logos/t_blue.svg', height: 120), // ignore: undefined_identifier
                        const SizedBox(height: 2),
                        Text('AceUp',
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.onPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Sign up',
                      style: AppTypography.h3.copyWith(color: colors.onPrimary)),
                  const SizedBox(height: 6),
                  Text('Create an account to access your new student lifestyle!',
                      style: AppTypography.bodyS.copyWith(color: colors.onPrimary)),
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _nick,
                    maxLength: 40,
                    validator: _vNick,
                    decoration: _decorStandard(context,
                        label: 'Choose Your Nick', hint: 'e.g., Luc'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _email,
                    maxLength: 40,
                    validator: _vEmail,
                    decoration: _decorStandard(context,
                        label: 'Email Address', hint: 'name@email.com'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _pass,
                    maxLength: 40,
                    validator: _vPass,
                    obscureText: _ob1,
                    decoration: _decorStandard(
                      context,
                      label: 'Password',
                      hint: '8+ chars, 1 uppercase, 1 number',
                      suffix: IconButton(
                        onPressed: () => setState(() => _ob1 = !_ob1),
                        icon: Icon(_ob1 ? AppIcons.visibilityOff : AppIcons.visibilityOn),
                        color: colors.outline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _pass2,
                    maxLength: 40,
                    validator: _vConfirm,
                    obscureText: _ob2,
                    decoration: _decorStandard(
                      context,
                      label: 'Confirm password',
                      suffix: IconButton(
                          onPressed: () => setState(() => _ob2 = !_ob2),
                          icon: Icon(_ob2 ? AppIcons.visibilityOff : AppIcons.visibilityOn),
                          color: colors.outline,
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
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Create account'),
                    ),
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
