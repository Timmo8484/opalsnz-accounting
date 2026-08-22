import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// Thin HTTP wrapper: attaches the bearer token, serializes/deserializes JSON, and
// surfaces non-2xx responses as ApiException so BLoCs can turn them into error states.
class ApiClient {
  ApiClient(this._authService);

  final AuthService _authService;
  final Uri _baseUri = Uri.parse(AppConfig.apiBaseUrl);

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, String>? query]) =>
      _baseUri.replace(path: path, queryParameters: query);

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final response = await http.get(_uri(path, query), headers: await _headers());
    return _handle(response);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final response = await http.post(_uri(path), headers: await _headers(), body: jsonEncode(body));
    return _handle(response);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final response = await http.put(_uri(path), headers: await _headers(), body: jsonEncode(body));
    return _handle(response);
  }

  Future<void> delete(String path) async {
    final response = await http.delete(_uri(path), headers: await _headers());
    _handle(response);
  }

  dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    }
    throw ApiException(response.statusCode, response.body.isEmpty ? response.reasonPhrase ?? 'Request failed' : response.body);
  }
}
