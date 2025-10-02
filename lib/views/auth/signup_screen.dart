import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/signup_viewmodel.dart';

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
    final cs = Theme.of(ctx).colorScheme;
    return InputDecoration(
      labelText: label,
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
        borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF9A9A), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFD32F2F)),
      suffixIcon: suffix,
    );
  }

  // ---------------- Terms modal (English) ----------------
  void _openTerms() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.errorContainer,
          content: Text(msg, style: TextStyle(color: cs.onErrorContainer)),
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
                        SvgPicture.asset('assets/logos/t_blue.svg', height: 120),
                        const SizedBox(height: 8),
                        Text('AceUp',
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F2C4C))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Sign up',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Create an account to access your new student lifestyle!',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
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
                        icon: Icon(_ob1 ? Icons.visibility_off : Icons.visibility),
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
                        icon: Icon(_ob2 ? Icons.visibility_off : Icons.visibility),
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
