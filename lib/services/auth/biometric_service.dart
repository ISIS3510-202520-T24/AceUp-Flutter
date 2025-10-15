import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService _i = BiometricService._();
  factory BiometricService() => _i;

  final LocalAuthentication _auth = LocalAuthentication();

  /// Retorna true solo si el dispositivo soporta biometría *y* hay al menos
  /// una biometría enrolada (huella/face) disponible para autenticarse.
  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final types = await _auth.getAvailableBiometrics();
      // Útil para logs durante diagnóstico
      // ignore: avoid_print
      print('[bio] supported=$supported canCheck=$canCheck types=$types');
      // Algunos devices reportan supported=true pero lista vacía, preferimos exigir lista no vacía:
      return (supported || canCheck) && types.isNotEmpty;
    } catch (e) {
      // ignore: avoid_print
      print('[bio] canUseBiometrics error: $e');
      return false;
    }
  }

  /// Muestra el prompt nativo de biometría (solo biométrico).
  Future<bool> authenticate() async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock with biometrics',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );
      // ignore: avoid_print
      print('[bio] authenticate -> $ok');
      return ok;
    } catch (e) {
      // ignore: avoid_print
      print('[bio] authenticate error: $e');
      return false;
    }
  }

  /// Texto de estado útil para mostrar en SnackBar o logs.
  Future<String> debugSummary() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final types = await _auth.getAvailableBiometrics();
      return 'supported=$supported | canCheck=$canCheck | types=$types';
    } catch (e) {
      return 'error: $e';
    }
  }
}
