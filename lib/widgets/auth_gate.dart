import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../services/auth/secure_store.dart';
import '../services/auth/session_prefs.dart';
import '../services/auth/auth_service.dart';

class AuthGate extends StatefulWidget {
  final Widget home;   // TodayScreen
  final Widget login;  // LoginScreen
  const AuthGate({super.key, required this.home, required this.login});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> _boot;

  Future<bool> _decide() async {
    // pequeño respiro para restauración interna de Firebase
    await Future.delayed(const Duration(milliseconds: 40));

    // 1) si ya hay usuario -> a Home
    if (FirebaseAuth.instance.currentUser != null) return true;

    // 2) Sign-in silencioso con credenciales guardadas (si hay red)
    final sess = await SecureStore.sessionCredentials();
    if (sess.email != null && sess.password != null) {
      try {
        // usa tu AuthService para mantener la misma ruta de código
        final auth = context.read<AuthService>();
        await auth.signInEmailPassword(
          email: sess.email!.trim(),
          password: sess.password!,
        );
        return true; // ok → Home
      } catch (_) {
        // si falla, seguimos con fallback offline
      }
    }

    // 3) Fallback offline: si sabemos que ya hubo login, deja entrar a Home
    final wasLogged = await SessionPrefs.getWasLoggedIn();
    if (wasLogged) return true;

    // 4) Caso base: mostrar Login
    return false;
  }

  @override
  void initState() {
    super.initState();
    _boot = _decide();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _boot,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final goHome = snap.data == true;

        // si entramos a Home, igual escuchamos authState por si se hace logout
        if (goHome) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (_, s) {
              if (s.connectionState == ConnectionState.active && s.data == null) {
                return widget.login;
              }
              return widget.home;
            },
          );
        }

        return widget.login;
      },
    );
  }
}
