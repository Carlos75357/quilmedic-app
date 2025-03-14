import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/json/json_rpc.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

class ProductoRepository {
  final ApiClient apiClient;

  ProductoRepository({required this.apiClient});

  Future<List<dynamic>> enviarProductosEscaneados(
    int hospitalId,
    List<ProductoEscaneado> productos,
  ) async {
    final List<dynamic> resultados = [];

    try {
      // Obtener todas las series de productos para filtrar
      for (var producto in productos) {
        // Obtenemos todos los productos
        final response = await apiClient.getAll(
          '${ApiConfig.productosEndpoint}?codigoalmacen=$hospitalId&serie=${producto.serie}',
          null,
        );
        
        // Filtramos manualmente los productos que coinciden con nuestras series
        if (response is List) {
          for (var producto in response) {
            if (producto is Map<String, dynamic> && 
                producto['serie'] != null && 
                producto['serie'] == producto['serie']) {
              resultados.add(producto);
            }
          }
        }  
      }
      

      return resultados;
    } catch (e) {
      throw Exception('Error al enviar productos: ${e.toString()}');
    }
  }

  Future<bool> verificarProductoExistente(String serie) async {
    try {
      var jsonRequest = JsonRequest({
        'jsonrpc': '2.0',
        'method': 'verificarProducto',
        'params': {'serie': serie},
      });

      final response = await apiClient.call(
        ApiConfig.productosEndpoint,
        jsonRequest,
      );

      return response['existe'] ?? false;
    } catch (e) {
      throw Exception('Error al verificar producto: ${e.toString()}');
    }
  }
}
