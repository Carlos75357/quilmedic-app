/// Clase que representa una solicitud de traslado de productos entre hospitales.
/// Contiene toda la información necesaria para procesar un traslado, incluyendo
/// el origen, destino, usuario solicitante y los productos a trasladar.
class TransferRequest {
  /// Correo electrónico del usuario que solicita el traslado
  final String email;
  /// ID del hospital de origen
  final int fromStoreId;
  /// ID del hospital de destino
  final int toStoreId;
  /// ID del usuario que realiza la solicitud
  final int userId;
  /// Lista de números de serie de los productos a trasladar
  final List<String> products;

  /// Constructor de la clase TransferRequest
  /// @param [email] Correo electrónico del solicitante
  /// @param [fromStoreId] ID del hospital de origen
  /// @param [toStoreId] ID del hospital de destino
  /// @param [userId] ID del usuario que realiza la solicitud
  /// @param [products] Lista de números de serie de los productos
  TransferRequest({
    required this.email,
    required this.fromStoreId,
    required this.toStoreId,
    required this.userId,
    required this.products,
  });

  /// Convierte la instancia actual a un mapa JSON para enviar a la API
  /// @return [Map] Mapa con los datos de la solicitud de traslado en formato JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'from_store_id': fromStoreId,
      'to_store_id': toStoreId,
      'user_id': userId,
      'products': products,
    };
  }
}
