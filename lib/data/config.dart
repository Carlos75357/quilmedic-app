import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  // URL base de la API
  // static const String baseUrl = 'https://api.quilmedic.com';
  // static const String baseUrl = 'http://localhost:3000';
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const String masterToken = String.fromEnvironment('MASTER_TOKEN');
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<String?> getToken() async {
    final savedToken = await _storage.read(key: _tokenKey);

    if (savedToken != null) return savedToken;

    final newToken = await _fetchInitialToken();
    if (newToken != null) {
      await _storage.write(key: _tokenKey, value: newToken);
    }

    return newToken;
  }

  static Future<String?> _fetchInitialToken() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-token'),
        headers: {'Authorization': 'Bearer $masterToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Endpoints
  static const String hospitalesEndpoint = '/stores';
  static const String productosEndpoint = '/products';
  static const String alarmasEndpoint = '/alarms';
  static const String locationEndpoint = '/locations';

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $masterToken',
  };
}
