/// Excepción que se lanza cuando un token de autenticación ha expirado.
/// Se utiliza para manejar el caso en que el servidor responde con un error 401
/// debido a que el token de autenticación ya no es válido.
class TokenExpiredException implements Exception {
  /// Mensaje descriptivo de la excepción
  final String message;
  
  /// Constructor de la excepción TokenExpiredException
  /// @param message Mensaje descriptivo del error
  TokenExpiredException(this.message);
  @override
  /// Retorna el mensaje descriptivo de la excepción como cadena de texto
  String toString() => message;
}

/// Excepción que se lanza cuando ocurre un error de autenticación.
/// Se utiliza para manejar errores generales relacionados con la autenticación
/// como credenciales inválidas o problemas de acceso.
class AuthenticationException implements Exception {
  /// Mensaje descriptivo de la excepción
  final String message;
  
  /// Constructor de la excepción AuthenticationException
  /// @param message Mensaje descriptivo del error
  AuthenticationException(this.message);
  @override
  /// Retorna el mensaje descriptivo de la excepción como cadena de texto
  String toString() => message;
}