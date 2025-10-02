import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class BurgerMenu extends StatelessWidget {
  const BurgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header (como lo tengas, o simple)
            ListTile(
              title: Text('Menu', style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(height: 1),

            // Navegación principal
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Today'),
                    onTap: () => Navigator.pushReplacementNamed(context, '/today'),
                  ),
                  ListTile(
                    title: const Text('Shared'),
                    onTap: () => Navigator.pushReplacementNamed(context, '/shared'),
                  ),
                  ListTile(
                    title: const Text('Holidays'),
                    onTap: () => Navigator.pushReplacementNamed(context, '/holidays'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Logout pegado abajo
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await context.read<AuthService>().signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
