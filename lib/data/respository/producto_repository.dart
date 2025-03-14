import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/json/json_rpc.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

class ProductoRepository {
  final ApiClient apiClient;

  ProductoRepository({required this.apiClient});

  /// Envía los productos escaneados al servidor
  /// 
  /// [hospitalId] es el ID del hospital seleccionado
  /// [productos] es la lista de productos escaneados
  Future<dynamic> enviarProductosEscaneados(int hospitalId, List<ProductoEscaneado> productos) async {
    try {
      // Extraer solo los números de serie de los productos
      final List<int> seriesProductos = productos.map((p) => p.serie).toList();
      
      // Crear el objeto de parámetros para la solicitud
      final Map<String, dynamic> params = {
        'hospitalId': hospitalId,
        'series': seriesProductos,
      };
      
      // Crear la solicitud JSON-RPC
      var jsonRequest = JsonRequest({
        'jsonrpc': '2.0',
        'method': 'enviarProductos',
        'params': params,
      });
      
      // Enviar la solicitud al servidor
      final response = await apiClient.call(
        ApiConfig.productosEndpoint,
        jsonRequest,
      );
      
      return response;
    } catch (e) {
      throw Exception('Error al enviar productos: ${e.toString()}');
    }
  }

  /// Verifica si un producto existe en la base de datos
  Future<bool> verificarProductoExistente(int serie) async {
    try {
      // Crear la solicitud JSON-RPC
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