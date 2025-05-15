import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/domain/user.dart';
import 'package:quilmedic/exceptions/authentication_exceptions.dart';
import 'package:quilmedic/services/navigation_service.dart';
import 'package:quilmedic/services/device_id_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceIdService _deviceIdService = DeviceIdService();
  final ApiClient _apiClient = ApiClient();
  
  final StreamController<bool> _authExpirationController = StreamController<bool>.broadcast();
  Stream<bool> get onAuthExpired => _authExpirationController.stream;

  Future<String> getDeviceId() async {
    try {
      return await _deviceIdService.getUniqueDeviceId();
    } catch (e) {
      return 'unknown_device';
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      final deviceId = await getDeviceId();
      
      try {
        final response = await _apiClient.post('/login', {
          'username': username,
          'password': password,
          'device_id': deviceId,
        });
        if (response != null) {
          final Map<String, dynamic> userResponse = response['user'];
          final String tokenResponse = response['token'];
          
          final user = User(
            id: userResponse['id'],
            username: username,
            token: tokenResponse,
            androidId: deviceId,
          );

          await _secureStorage.write(key: _tokenKey, value: user.token);
          await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
          
          return user;
        } else {
          throw Exception(response['message'] ?? 'Error al iniciar sesión');
        }
      } catch (e) {
        if (e is TimeoutException) {
          throw Exception('Tiempo de espera agotado. Compruebe su conexión a Internet.');
        } else {
          throw Exception('Error de conexión: ${e.toString()}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }
    
  Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      
      if (token == null) {
        return false;
      }
      
      try {
        await _apiClient.getAll('/validate-token', {});
        return true;
      } catch (e) {
        if (e is TokenExpiredException || e is AuthenticationException || 
            e.toString().contains('401') || 
            e.toString().contains('unauthorized') || 
            e.toString().contains('Unauthorized')) {
          
          await logout();
          
          NavigationService.navigateToLogin();
          
          _authExpirationController.add(true);
          return false;
        }
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final userData = await _secureStorage.read(key: _userKey);
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userKey);
      
      await ApiConfig.clearToken();
    } catch (e) {
      //
    }
  }
  
  Future<bool> isTokenValid() async {
    try {
      await _apiClient.getAll('/validate-token', {});
      return true;
    } catch (e) {
      if (e is TokenExpiredException || e is AuthenticationException || 
          e.toString().contains('401') || 
          e.toString().contains('unauthorized') || 
          e.toString().contains('Unauthorized')) {
        _authExpirationController.add(true);
        return false;
      }
      return await isAuthenticated();
    }
  }
  
  void dispose() {
    _authExpirationController.close();
  }
}
