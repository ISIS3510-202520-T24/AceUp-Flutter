import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../main.dart'; // for AppTheme

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agree = false;

  Widget _termsSection(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    final linkStyle = textStyle?.copyWith(
      color: AppTheme.mint,
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agree,
          onChanged: (v) => setState(() => _agree = v ?? false),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: textStyle,
              children: [
                const TextSpan(text: "I've read and agree with the "),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: ' and the '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: 120),
                      const SizedBox(height: 8),
                      const Text(
                        'AceUp',
                        style: TextStyle(
                          color: Color(0xFF0F2C4C),
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          letterSpacing: .2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign up',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create an account to access your new student lifestyle!',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 18),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Choose Your Nick',
                    hintText: 'e.g., Luc',
                  ),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'name@email.com',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: null,
                      icon: const Icon(Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    suffixIcon: IconButton(
                      onPressed: null,
                      icon: const Icon(Icons.visibility_off),
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
                    onPressed: () => Navigator.pushReplacementNamed(context, '/today'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.mint,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Create account'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

