import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/data/respository/repository_response.dart';

class ProductoRepository {
  final ApiClient apiClient;

  ProductoRepository({required this.apiClient});

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
