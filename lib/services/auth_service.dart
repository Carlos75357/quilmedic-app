import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/domain/user.dart';
import 'package:quilmedic/exceptions/authentication_exceptions.dart';
import 'package:quilmedic/services/navigation_service.dart';
import 'package:quilmedic/services/device_id_service.dart';

/// Servicio que gestiona la autenticación de usuarios en la aplicación.
/// Proporciona métodos para iniciar sesión, cerrar sesión, validar tokens
/// y obtener información del usuario autenticado.
class AuthService {
  /// Clave para almacenar el token de autenticación en el almacenamiento seguro
  static const String _tokenKey = 'auth_token';
  /// Clave para almacenar los datos del usuario en el almacenamiento seguro
  static const String _userKey = 'user_data';
  
  /// Instancia de almacenamiento seguro para guardar datos sensibles
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  /// Servicio para obtener el ID único del dispositivo
  final DeviceIdService _deviceIdService = DeviceIdService();
  /// Cliente API para realizar peticiones al servidor
  final ApiClient _apiClient = ApiClient();
  
  /// Controlador de stream para notificar cuando la autenticación ha expirado
  final StreamController<bool> _authExpirationController = StreamController<bool>.broadcast();
  /// Stream que emite eventos cuando la autenticación expira
  Stream<bool> get onAuthExpired => _authExpirationController.stream;

  /// Obtiene el ID único del dispositivo
  /// @return ID del dispositivo o 'unknown_device' si ocurre un error
  Future<String> getDeviceId() async {
    try {
      return await _deviceIdService.getUniqueDeviceId();
    } catch (e) {
      return 'unknown_device';
    }
  }

  /// Inicia sesión con las credenciales proporcionadas
  /// @param username Nombre de usuario
  /// @param password Contraseña del usuario
  /// @return Usuario autenticado o null si falla la autenticación
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
    
  /// Verifica si el usuario está autenticado actualmente
  /// Valida el token almacenado contra el servidor
  /// @return true si el usuario está autenticado, false en caso contrario
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

  /// Obtiene los datos del usuario actualmente autenticado
  /// @return Usuario actual o null si no hay usuario autenticado
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

  /// Obtiene el token de autenticación almacenado
  /// @return Token de autenticación o null si no existe
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Cierra la sesión del usuario actual
  /// Elimina el token y los datos del usuario del almacenamiento seguro
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userKey);
      
      await ApiConfig.clearToken();
    } catch (e) {
      //
    }
  }
  
  /// Verifica si el token actual es válido
  /// Realiza una petición al servidor para validar el token
  /// @return true si el token es válido, false en caso contrario
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
  
  /// Libera los recursos utilizados por el servicio
  /// Cierra el stream controller para evitar fugas de memoria
  void dispose() {
    _authExpirationController.close();
  }
}
