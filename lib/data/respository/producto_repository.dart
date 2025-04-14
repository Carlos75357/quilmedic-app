import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/data/respository/repository_response.dart';

class ProductoRepository {
  final ApiClient apiClient;

  ProductoRepository({required this.apiClient});

  Future<RepositoryResponse> enviarProductosEscaneados(
    int hospitalId,
    int locationId,
    List<ProductoEscaneado> productos,
  ) async {
    final List<dynamic> resultados = [];
    final List<String> noEncontrados = [];

    try {
      List<String> serialNumbers =
          productos.map((producto) => producto.serialnumber).toList();
      final response = await apiClient.post(
        '${ApiConfig.productosEndpoint}/bySerialNumbers',
        {
          'serial_numbers': serialNumbers,
          'store_id': hospitalId,
          'location_id': locationId,
        },
      );

      if (response is Map &&
          response.containsKey('found') &&
          response.containsKey('missing')) {
        resultados.addAll(response['found']);
        noEncontrados.addAll(
          (response['missing'] as List).map((item) => item.toString()),
        );
      }

      if (resultados.isEmpty) {
        return RepositoryResponse.error(
          'No se encontraron productos con las serialnumbers escaneadas: ${noEncontrados.join(", ")}',
        );
      }

      String message = 'Productos enviados correctamente';
      if (noEncontrados.isNotEmpty) {
        message =
            'ATENCIÓN: Se encontraron ${resultados.length} productos. No se encontraron ${noEncontrados.length} productos con serialnumbers: ${noEncontrados.join(", ")}';
      }

      return RepositoryResponse.success({
        'found': resultados,
        'missing': noEncontrados
      }, message: message);
    } catch (e) {
      return RepositoryResponse.error(
        'Error al enviar productos: ${e.toString()}',
      );
    }
  }

  Future<RepositoryResponse> getProductoByNumeroAndAlmacen(
    String numproducto,
    String almacenId,
  ) async {
    try {
      final getAllResponse = await apiClient.getAll(
        ApiConfig.productosEndpoint,
        {},
      );

      if (getAllResponse != null && getAllResponse is List) {
        dynamic producto;
        try {
          producto = getAllResponse.firstWhere(
            (p) => p['numproducto'] == numproducto,
          );
        } catch (e) {
          return RepositoryResponse.error(
            'No se encontró el producto con numproducto: $numproducto',
          );
        }

        if (producto != null) {
          final currentAlmacenId = producto['storeid'];

          if (currentAlmacenId == almacenId) {
            return RepositoryResponse.success(
              producto,
              message: 'Producto encontrado en el almacén especificado',
            );
          } else {
            return RepositoryResponse.error(
              'El producto existe pero está asignado al almacén $currentAlmacenId',
              data: producto,
            );
          }
        } else {
          return RepositoryResponse.error(
            'No se encontró el producto con numproducto: $numproducto',
          );
        }
      } else {
        return RepositoryResponse.error(
          'Error al obtener la lista de productos',
        );
      }
    } catch (e) {
      return RepositoryResponse.error(
        'Error al obtener el producto: ${e.toString()}',
      );
    }
  }

  Future<RepositoryResponse> getProductoByserialnumberAndAlmacen(
    String serialnumber,
    int almacenId,
  ) async {
    try {
      final getAllResponse = await apiClient.getAll(
        ApiConfig.productosEndpoint,
        {},
      );

      if (getAllResponse != null && getAllResponse is List) {
        dynamic producto;
        try {
          producto = getAllResponse.firstWhere(
            (p) => p['serialnumber'] == serialnumber,
          );
        } catch (e) {
          return RepositoryResponse.error(
            'No se encontró el producto con serialnumber: $serialnumber',
          );
        }

        if (producto != null) {
          if (producto['storeid'] == almacenId) {
            return RepositoryResponse.success(
              producto,
              message: 'Producto encontrado en el almacén especificado',
            );
          } else {
            return RepositoryResponse.error(
              'El producto existe pero está asignado al almacén ${producto['storeid']}',
              data: producto,
            );
          }
        } else {
          return RepositoryResponse.error(
            'No se encontró el producto con serialnumber: $serialnumber',
          );
        }
      } else {
        return RepositoryResponse.error(
          'Error al obtener la lista de productos',
        );
      }
    } catch (e) {
      return RepositoryResponse.error(
        'Error al obtener el producto: ${e.toString()}',
      );
    }
  }

  Future<RepositoryResponse> getProductByCodigo(int codigo) async {
    try {
      final response = await apiClient.getAll(
        '${ApiConfig.productosEndpoint}?numproducto=$codigo',
        null,
      );
      return RepositoryResponse.success(response);
    } catch (e) {
      return RepositoryResponse.error(e.toString());
    }
  }

  Future<RepositoryResponse> getProductosByCodigos(List<String> codigos) async {
    try {
      final response = await apiClient.getAll(
        '${ApiConfig.productosEndpoint}?numproducto=${codigos.join(',')}',
        null,
      );

      return RepositoryResponse.success(response);
    } catch (e) {
      return RepositoryResponse.error(e.toString());
    }
  }
}
