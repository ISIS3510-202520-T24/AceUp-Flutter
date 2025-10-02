import 'package:firebase_auth/firebase_auth.dart'; // ignore: uri_does_not_exist

// ignore_for_file: undefined_identifier, non_type_as_type_argument, undefined_class, non_type_in_catch_clause

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---- Estado actual / stream ----
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
  bool get isEmailVerified => _auth.currentUser?.emailVerified == true;

  // ---- Sign up / Sign in ----
  Future<UserCredential> signUpEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && displayName.trim().isNotEmpty) {
        await cred.user?.updateDisplayName(displayName.trim());
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  Future<UserCredential> signInEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  // ---- Verificación de correo ----
  Future<void> sendEmailVerification() async {
    final u = _auth.currentUser;
    if (u != null && !u.emailVerified) {
      await u.sendEmailVerification();
    }
  }

  // ---- Utilidades de sesión ----
  Future<void> reloadUser() async => _auth.currentUser?.reload();

  Future<void> signOut() => _auth.signOut();

  // ---- Forgot password ----
  Future<void> requestPasswordReset(String email) async {
    try {
      await _auth.setLanguageCode('en'); // Cambia a 'es' si prefieres
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _map(e);
    }
  }

  // ---- Mapeo de errores a mensajes amigables ----
  Exception _map(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('Enter a valid email.');
      case 'user-not-found':
        return Exception('No account found with that email.');
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Wrong email or password.');
      case 'email-already-in-use':
        return Exception('That email is already registered.');
      case 'weak-password':
        return Exception('Password is too weak.');
      case 'too-many-requests':
        return Exception('Too many attempts. Try again in a few minutes.');
      default:
        return Exception('Unexpected error. Please try again.');
    }
  }
}
