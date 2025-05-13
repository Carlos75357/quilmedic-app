import 'dart:convert';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/json_client.dart';
import 'package:quilmedic/domain/user.dart';
import 'package:quilmedic/services/navigation_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final ApiClient _apiClient = ApiClient();
  
  // Stream para notificar cuando un token ha expirado
  final StreamController<bool> _authExpirationController = StreamController<bool>.broadcast();
  Stream<bool> get onAuthExpired => _authExpirationController.stream;

  Future<String> getAndroidId() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.id;
    } catch (e) {
      return 'unknown_device';
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      final androidId = await getAndroidId();
      
      try {
        final response = await _apiClient.post('/login', {
          'username': username,
          'password': password,
          'device_id': androidId,
        });
        if (response != null) {
          final Map<String, dynamic> userResponse = response['user'];
          final String tokenResponse = response['token'];
          
          final user = User(
            id: userResponse['id'],
            username: username,
            token: tokenResponse,
            androidId: androidId,
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
      debugPrint('Error en login: $e');
      rethrow;
    }
  }
    
  Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      
      // Si no hay token, no está autenticado
      if (token == null) {
        return false;
      }
      
      // Verificar si el token está expirado intentando hacer una petición simple
      try {
        // Intentamos una petición básica para validar el token
        await _apiClient.getAll('/validate-token', {});
        return true;
      } catch (e) {
        // Si hay un error de autenticación, el token no es válido
        if (e is TokenExpiredException || e is AuthenticationException || 
            e.toString().contains('401') || 
            e.toString().contains('unauthorized') || 
            e.toString().contains('Unauthorized')) {
          debugPrint('Token expirado o inválido en isAuthenticated: $e');
          
          // Eliminar todos los datos del almacenamiento seguro
          await logout();
          
          // Navegar directamente al login
          NavigationService.navigateToLogin();
          
          // Notificar que la autenticación ha expirado
          _authExpirationController.add(true);
          return false;
        }
        // Si es otro tipo de error (como de red), asumimos que el token es válido
        // ya que no podemos verificarlo en este momento
        return true;
      }
    } catch (e) {
      debugPrint('Error al verificar autenticación: $e');
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
      debugPrint('Error al obtener usuario actual: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('Error al obtener token: $e');
      return null;
    }
  }

  /// Cierra la sesión del usuario eliminando todos los datos de autenticación
  /// del almacenamiento seguro
  Future<void> logout() async {
    try {
      // Eliminar token y datos del usuario
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userKey);
      
      // Eliminar cualquier otro dato relacionado con la sesión
      // También limpiar el token en ApiConfig
      await ApiConfig.clearToken();
      
      debugPrint('Sesión cerrada correctamente. Todos los datos eliminados.');
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
    }
  }
  
  /// Verifica si el token actual es válido haciendo una petición de prueba
  /// Retorna true si el token es válido, false en caso contrario
  Future<bool> isTokenValid() async {
    try {
      // Intentar hacer una petición simple para verificar el token
      await _apiClient.getAll('/validate-token', {});
      return true;
    } catch (e) {
      if (e is TokenExpiredException || e is AuthenticationException || 
          e.toString().contains('401') || 
          e.toString().contains('unauthorized') || 
          e.toString().contains('Unauthorized')) {
        debugPrint('Token inválido o expirado: $e');
        // Notificar que la autenticación ha expirado
        _authExpirationController.add(true);
        return false;
      }
      // Otros errores pueden ser de red, no necesariamente de token inválido
      return await isAuthenticated();
    }
  }
  
  /// Maneja un error de autenticación, intentando renovar el token o redirigiendo al login
  /// Retorna true si se pudo manejar el error, false en caso contrario
  Future<bool> handleAuthError() async {
    try {
      // Intentar renovar el token usando el token maestro
      final tokenRenewed = await ApiConfig.renewToken();
      
      if (tokenRenewed) {
        // Si se renovó el token, actualizar el usuario actual
        final token = await ApiConfig.getToken();
        final currentUser = await getCurrentUser();
        
        if (currentUser != null && token != null) {
          // Actualizar el token del usuario
          final updatedUser = User(
            id: currentUser.id,
            username: currentUser.username,
            token: token,
            androidId: currentUser.androidId,
          );
          
          // Guardar el usuario actualizado
          await _secureStorage.write(key: _userKey, value: jsonEncode(updatedUser.toJson()));
          return true;
        }
      }
      
      // Si no se pudo renovar el token o no hay usuario actual, notificar expiración
      _authExpirationController.add(true);
      return false;
    } catch (e) {
      debugPrint('Error al manejar error de autenticación: $e');
      _authExpirationController.add(true);
      return false;
    }
  }
  
  /// Cierra el stream controller cuando el servicio ya no se necesita
  void dispose() {
    _authExpirationController.close();
  }
}
