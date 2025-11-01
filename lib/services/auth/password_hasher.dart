// lib/services/auth/password_hasher.dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static const int _saltLen = 16;
  static const int _iterations = 100000;

  static String genSalt() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(_saltLen, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// PBKDF2-HMAC-SHA256 (1 bloque, dkLen<=32) con _iterations (100k).
  static String pbkdf2(String password, String saltBase64,
      {int iterations = _iterations, int dkLen = 32}) {
    final salt = base64Url.decode(saltBase64);

    List<int> _prf(List<int> key, List<int> data) {
      final hmacSha256 = Hmac(sha256, key);
      return hmacSha256.convert(data).bytes;
    }

    List<int> xorBytes(List<int> a, List<int> b) {
      final out = List<int>.from(a);
      for (var i = 0; i < out.length; i++) {
        out[i] ^= b[i];
      }
      return out;
    }

    final blockIndex = [0, 0, 0, 1]; // INT(1) big-endian
    final dk = List<int>.filled(dkLen, 0);

    final key = utf8.encode(password);
    final u1 = _prf(key, [...salt, ...blockIndex]);
    var t = List<int>.from(u1);
    var uPrev = u1;
    for (var c = 2; c <= iterations; c++) {
      uPrev = _prf(key, uPrev);
      t = xorBytes(t, uPrev);
    }
    for (var i = 0; i < dkLen; i++) {
      dk[i] = t[i];
    }
    return base64Url.encode(dk);
  }

  static ({String salt, String hash}) createVerifier(String password) {
    final salt = genSalt();
    final hash = pbkdf2(password, salt);
    return (salt: salt, hash: hash);
  }

  static bool verify(String password, String salt, String expectedHash) {
    final h = pbkdf2(password, salt);
    return constantTimeEquals(expectedHash, h);
  }

  static bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var res = 0;
    for (var i = 0; i < a.length; i++) {
      res |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return res == 0;
  }
}
