import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Clase de configuración para la API de la aplicación.
/// Contiene constantes y métodos relacionados con la configuración
/// de la API, como URL base, endpoints, tokens de autenticación y timeouts.
class ApiConfig {
  /// Instancia de almacenamiento seguro para guardar el token de autenticación
  static const _storage = FlutterSecureStorage();
  /// Clave utilizada para almacenar el token de autenticación
  static const _tokenKey = 'auth_token';
  /// Token maestro utilizado como respaldo cuando no hay token guardado
  static const String masterToken = String.fromEnvironment('MASTER_TOKEN');
  /// URL base de la API de producción
  static const String baseUrl = 'https://controlalmacen.quilmedic.com/api';
  /// URL base de la API para desarrollo local (comentada)
  // static const String baseUrl = 'http://localhost:8000/api';

  /// Obtiene el token de autenticación almacenado o el token maestro si no hay ninguno guardado
  /// @return [String] Token de autenticación o null si no existe
  static Future<String?> getToken() async {
    final savedToken = await _storage.read(key: _tokenKey);

    if (savedToken != null) return savedToken;

    return masterToken;
  }

  /// Elimina el token de autenticación almacenado
  /// Utilizado generalmente para cerrar sesión
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Endpoints de la API
  /// Endpoint para obtener y gestionar hospitales
  static const String hospitalesEndpoint = '/stores';
  /// Endpoint para obtener y gestionar productos
  static const String productosEndpoint = '/products';
  /// Endpoint para obtener y gestionar alarmas
  static const String alarmasEndpoint = '/alarms';
  /// Endpoint para obtener y gestionar ubicaciones
  static const String locationEndpoint = '/locations';
  /// Endpoint para gestionar traslados de productos
  static const String transferEndpoint = '/notifications/transfer';

  /// Configuración de timeouts para las peticiones HTTP
  /// Tiempo máximo de espera para establecer conexión (en milisegundos)
  static const int connectionTimeout = 30000;
  /// Tiempo máximo de espera para recibir respuesta (en milisegundos)
  static const int receiveTimeout = 30000;

  /// Encabezados HTTP estándar para las peticiones a la API
  /// @return [Map] Mapa con los encabezados HTTP incluyendo el token maestro
  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $masterToken',
    };
  }
}
