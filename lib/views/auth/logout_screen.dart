import 'package:flutter/material.dart';
import '../../viewmodels/auth/login_viewmodel.dart';
import '../../services/auth/offline_auth_service.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/login_viewmodel.dart';

class LogoutScreen extends StatelessWidget {
  final LoginViewModel vm;
  const LogoutScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.tonal(
              onPressed: () async {
                final vm = context.read<LoginViewModel>();     // obtenemos el VM
                await vm.signOutAll();                         // MVVM: logout total
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
              ,
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
