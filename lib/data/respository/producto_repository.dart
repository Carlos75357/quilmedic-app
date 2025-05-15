import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/data/respository/repository_response.dart';

/// Repositorio que gestiona las operaciones relacionadas con los productos.
/// Proporciona métodos para enviar productos escaneados al servidor.
class ProductoRepository {
  /// Cliente de API utilizado para realizar las peticiones al servidor
  final ApiClient apiClient;

  /// Constructor que recibe una instancia de ApiClient
  /// @param apiClient Cliente de API para realizar las peticiones
  ProductoRepository({required this.apiClient});

  /// Envía una lista de productos escaneados al servidor para su procesamiento
  /// Identifica qué productos fueron encontrados en la base de datos y cuáles no
  /// @param hospitalId ID del hospital donde se escanearon los productos
  /// @param locationId ID de la ubicación dentro del hospital
  /// @param productos Lista de productos escaneados a enviar
  /// @return RepositoryResponse con los resultados de la operación, incluyendo productos encontrados y no encontrados
  Future<RepositoryResponse> enviarProductosEscaneados(int hospitalId, int locationId, List<ProductoEscaneado> productos) async {
    final List<dynamic> resultados = [];
    final List<String> noEncontrados = [];

    try {
      List<String> serialNumbers =
          productos.map((producto) => producto.serialnumber).toList();
      final response = await apiClient
          .post('${ApiConfig.productosEndpoint}/bySerialNumbers', {
            'serial_numbers': serialNumbers,
            'store_id': hospitalId,
            'location_id': locationId,
          });

      if (response is Map &&
          response.containsKey('found') &&
          response.containsKey('missing')) {
        resultados.addAll(response['found']);
        noEncontrados.addAll(
          (response['missing'] as List).map((item) => item.toString()),
        );
      }

      String message = 'Productos enviados correctamente';
      if (noEncontrados.isNotEmpty) {
        message =
            'ATENCIÓN: Se encontraron ${resultados.length} productos. No se encontraron ${noEncontrados.length} productos con serialnumbers: ${noEncontrados.join(", ")}';
      }

      return RepositoryResponse.success({
        'found': resultados,
        'missing': noEncontrados,
      }, message: message);
    } catch (e) {
      return RepositoryResponse.error(
        'Error al enviar productos: ${e.toString()}',
      );
    }
  }
}
