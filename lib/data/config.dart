class ApiConfig {
  // URL base de la API
  static const String baseUrl = 'https://api.quilmedic.com';
  
  // Endpoints
  static const String hospitalesEndpoint = '/hospitales';
  static const String productosEndpoint = '/productos';
  static const String guardarProductosEndpoint = '/guardar-productos';
  
  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Versión de la API
  static const String apiVersion = 'v1';
  
  // URL completa con versión
  static String get apiUrl => '$baseUrl/$apiVersion';
}