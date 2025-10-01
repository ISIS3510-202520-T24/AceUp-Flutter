import 'package:flutter/material.dart';

import '../../themes/app_icons.dart';

class BiometricScreen extends StatelessWidget {
  const BiometricScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biometric Login")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.fingerprint, size: 100, color: Colors.teal),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // pretend successful auth
              },
              child: const Text("Authenticate"),
            )
          ],
        ),
      ),
    );
  }
}

