import 'dart:convert';
import 'package:http/http.dart' as http; // ignore: uri_does_not_exist

class AuthBridgeService {
  // Cambia por tu endpoint (Cloud Run/Functions/tu servidor)
  static const String base = 'https://TU-BACKEND/bridge';

  Future<String> signUpAndGetCustomToken({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final r = await http.post(Uri.parse('$base/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'nickname': nickname}));
    if (r.statusCode != 200) {
      throw Exception('SignUp failed: ${r.body}');
    }
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return data['firebaseCustomToken'] as String;
  }

  Future<String> loginAndGetCustomToken({
    required String email,
    required String password,
  }) async {
    final r = await http.post(Uri.parse('$base/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}));
    if (r.statusCode != 200) {
      throw Exception('Login failed: ${r.body}');
    }
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return data['firebaseCustomToken'] as String;
  }
}
