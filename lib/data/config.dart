class ApiConfig {
  // URL base de la API
  // static const String baseUrl = 'https://api.quilmedic.com';
  // static const String baseUrl = 'http://localhost:3000';
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Endpoints
  static const String hospitalesEndpoint = '/stores';
  static const String productosEndpoint = '/products';
  static const String alarmasEndpoint = '/alarms';
  
  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}