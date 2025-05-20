/// Clase genérica que encapsula la respuesta de los repositorios.
/// Proporciona una estructura estándar para manejar éxitos y errores
/// en las operaciones de los repositorios.
class RepositoryResponse<T> {
  /// Indica si la operación fue exitosa
  final bool success;
  /// Mensaje descriptivo sobre el resultado de la operación
  final String? message;
  /// Datos devueltos por la operación (solo si fue exitosa)
  final T? data;
  /// Excepción producida (solo si hubo error)
  final Exception? error;

  /// Constructor principal
  /// @param [success] Indica si la operación fue exitosa
  /// @param [message] Mensaje opcional descriptivo
  /// @param [data] Datos opcionales devueltos por la operación
  /// @param [error] Excepción opcional si hubo error
  RepositoryResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  /// Constructor factory para crear una respuesta exitosa
  /// @param [data] Datos devueltos por la operación
  /// @param [message] Mensaje opcional de éxito
  /// @return Nueva instancia de [RepositoryResponse] con success=true
  factory RepositoryResponse.success(T data, {String? message}) {
    return RepositoryResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  /// Constructor factory para crear una respuesta de error
  /// @param [message] Mensaje de error
  /// @param [error] Excepción opcional que causó el error
  /// @param [data] Datos opcionales que podrían haberse obtenido parcialmente
  /// @return Nueva instancia de [RepositoryResponse] con success=false
  factory RepositoryResponse.error(String message, {Exception? error, T? data}) {
    return RepositoryResponse(
      success: false,
      message: message,
      error: error,
      data: data,
    );
  }
}