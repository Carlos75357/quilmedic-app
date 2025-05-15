import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  // URL base de la API
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const String masterToken = String.fromEnvironment('MASTER_TOKEN');
  static const String baseUrl = 'https://controlalmacen.quilmedic.com/api';
  // static const String baseUrl = 'http://localhost:8000/api';

  static Future<String?> getToken() async {
    final savedToken = await _storage.read(key: _tokenKey);

    if (savedToken != null) return savedToken;

    return masterToken;
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Endpoints
  static const String hospitalesEndpoint = '/stores';
  static const String productosEndpoint = '/products';
  static const String alarmasEndpoint = '/alarms';
  static const String locationEndpoint = '/locations';
  static const String transferEndpoint = '/notifications/transfer';

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Headers
  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $masterToken',
    };
  }
}
