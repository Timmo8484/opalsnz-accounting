import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

// Handles login + token storage. Kept separate from ApiClient to avoid a circular
// dependency (ApiClient needs the stored token; login itself is unauthenticated).
class AuthService {
  AuthService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _tokenKey = 'auth_token';

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      return false;
    }

    final token = jsonDecode(response.body)['token'] as String;
    await _storage.write(key: _tokenKey, value: token);
    return true;
  }

  Future<void> logout() => _storage.delete(key: _tokenKey);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<bool> isLoggedIn() async => await getToken() != null;
}
