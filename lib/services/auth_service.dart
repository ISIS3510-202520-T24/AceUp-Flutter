import 'package:firebase_auth/firebase_auth.dart'; // ignore: uri_does_not_exist
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore_for_file: undefined_class, undefined_identifier, non_type_as_type_argument

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // ---------- SIGN UP (email/clave) ----------
  Future<UserCredential> signUpEmailPassword({
    required String email,
    required String password,
    String? displayName, // nuestro "nick"
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Opcional: guardar nick como displayName en Auth
    if (displayName != null && displayName.trim().isNotEmpty) {
      await cred.user?.updateDisplayName(displayName.trim());
    }

    // 🔹 Asegura perfil en Firestore
    await _ensureUserDoc(
      cred.user!,
      nickname: displayName,
    );

    // Puedes enviar verificación si quieres
    // await sendEmailVerification();

    return cred;
  }

  // ---------- SIGN IN (email/clave) ----------
  Future<UserCredential> signInEmailPassword({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // 🔹 Si el doc de perfil no existe (usuarios antiguos), lo creamos
    await _ensureUserDoc(cred.user!);

    return cred;
  }

  // ---------- PERFIL EN FIRESTORE ----------
  Future<void> _ensureUserDoc(
    User user, {
    String? nickname,
  }) async {
    final uid = user.uid;
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();

    if (!snap.exists) {
      // Crear documento inicial
      await ref.set({
        'uid': uid,
        'email': user.email,
        'nick': nickname ?? user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Actualizar campos importantes sin pisar lo demás
      await ref.set({
        'email': user.email,
        if (nickname != null && nickname.isNotEmpty) 'nick': nickname,
      }, SetOptions(merge: true));
    }
  }

  // (Opcional) actualizar el nick más tarde
  Future<void> updateNickname(String newNick) async {
    final u = _auth.currentUser;
    if (u == null) return;
    await _db.collection('users').doc(u.uid).set({
      'nick': newNick.trim(),
    }, SetOptions(merge: true));
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
    await _auth.setLanguageCode('en'); // o 'es'
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();
}
