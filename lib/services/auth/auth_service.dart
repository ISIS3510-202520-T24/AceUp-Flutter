// lib/services/auth/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart'; // ignore: uri_does_not_exist
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // ignore: uri_does_not_exist

// ignore_for_file: undefined_class, undefined_identifier, non_type_as_type_argument, non_type_in_catch_clause

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // ---- Accesores / estado ----
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // ---------- SIGN UP (email/clave) ----------
  Future<UserCredential> signUpEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Opcional: mostrar nick en Firebase Auth
      if ((displayName ?? '').trim().isNotEmpty) {
        await cred.user?.updateDisplayName(displayName!.trim());
      }

      // Asegura perfil en Firestore
      await _ensureUserDoc(cred.user!, nickname: displayName);

      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendly(e));
    } catch (_) {
      throw Exception('Could not create the account. Please try again.');
    }
  }

  // ---------- SIGN IN (email/clave) ----------
  Future<UserCredential> signInEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Si no hay doc (usuarios antiguos), créalo/actualízalo
      await _ensureUserDoc(cred.user!);

      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendly(e));
    } catch (_) {
      throw Exception('Could not sign in. Please try again.');
    }
  }

  // ---------- PERFIL EN FIRESTORE ----------
  Future<void> _ensureUserDoc(
    User user, {
    String? nickname,
  }) async {
    final uid = user.uid;
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();

    // Intenta obtener FCM token (si falla, no rompe el flujo)
    String? fcmToken;
    try {
      fcmToken = await _fcm.getToken();
      // ignore: avoid_print
      print('📱 AuthService got FCM Token: $fcmToken');
    } catch (e) {
      // ignore: avoid_print
      print('Could not get FCM token: $e');
    }

    if (!snap.exists) {
      await ref.set({
        'uid': uid,
        'email': user.email,
        'nick': nickname ?? user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'fcmTokens': fcmToken != null ? [fcmToken] : [],
      });
    } else {
      await ref.set({
        'email': user.email,
        if ((nickname ?? '').trim().isNotEmpty) 'nick': nickname!.trim(),
        if (fcmToken != null) 'fcmTokens': FieldValue.arrayUnion([fcmToken]),
      }, SetOptions(merge: true));
    }
  }

  // (Opcional) actualizar el nick más tarde
  Future<void> updateNickname(String newNick) async {
    final u = _auth.currentUser;
    if (u == null) return;
    await _db.collection('users').doc(u.uid).set(
      {'nick': newNick.trim()},
      SetOptions(merge: true),
    );
    await u.updateDisplayName(newNick.trim());
  }

  // ---------- UTILIDADES ----------
  Future<void> sendEmailVerification() async {
    final u = _auth.currentUser;
    if (u != null && !u.emailVerified) {
      await u.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async => _auth.currentUser?.reload();

  Future<void> requestPasswordReset(String email) async {
    try {
      await _auth.setLanguageCode('en'); // o 'es'
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendly(e));
    } catch (_) {
      throw Exception('Could not send the reset email. Please try again.');
    }
  }

  Future<void> signOut() => _auth.signOut();

  // ---------- Mapeo de errores a mensajes amigables ----------
  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'invalid-credential':          // Web / SDKs recientes
      case 'invalid-login-credentials':   // variante en algunos SDKs
        return 'Incorrect email or password.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'expired-action-code':
        return 'The link has expired. Request a new one.';
      case 'invalid-action-code':
        return 'The link is invalid or has already been used.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
