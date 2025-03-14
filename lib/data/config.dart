class ApiConfig {
  // URL base de la API
  // static const String baseUrl = 'https://api.quilmedic.com';
  static const String baseUrl = 'http://localhost:3000';
  
  // Endpoints
  static const String hospitalesEndpoint = '/almacenes';
  static const String productosEndpoint = '/productos';
  
  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}