import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/repository_response.dart';
import 'package:quilmedic/domain/transfer_request.dart';

/// Repositorio que gestiona las operaciones relacionadas con el traslado de productos.
/// Proporciona métodos para enviar solicitudes de traslado de productos entre hospitales.
class TransferRepository {
  /// Cliente de API utilizado para realizar las peticiones al servidor
  final ApiClient apiClient;

  /// Constructor que recibe una instancia de ApiClient
  /// @param apiClient Cliente de API para realizar las peticiones
  TransferRepository({required this.apiClient});

  /// Envía una solicitud de traslado de productos entre hospitales
  /// @param request Objeto que contiene los datos de la solicitud de traslado
  /// @return RepositoryResponse con el resultado de la operación
  Future<RepositoryResponse> transferProducts(TransferRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConfig.transferEndpoint,
        request.toJson(),
      );

      return RepositoryResponse.success(
        response,
        message: 'Solicitud de traslado enviada correctamente',
      );
    } catch (e) {
      return RepositoryResponse.error('Error al enviar solicitud de traslado: ${e.toString()}');
    }
  }
}
