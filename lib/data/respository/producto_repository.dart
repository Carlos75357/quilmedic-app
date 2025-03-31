import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/data/respository/repository_response.dart';

class ProductoRepository {
  final ApiClient apiClient;

  ProductoRepository({required this.apiClient});

  Future<RepositoryResponse> enviarProductosEscaneados(
    int hospitalId,
    List<ProductoEscaneado> productos,
  ) async {
    final List<dynamic> resultados = [];
    final List<String> noEncontrados = [];

    try {
      List<String> serialNumbers = productos.map((producto) => producto.serie).toList();
      final response = await apiClient.getAll(
        '${ApiConfig.productosEndpoint}/bySerialNumbers',
        {'serial_numbers': serialNumbers},
      );

      if (response is Map && response.containsKey('found') && response.containsKey('missing')) {
        resultados.addAll(response['found']);
        noEncontrados.addAll((response['missing'] as List).map((item) => item.toString()));
      }

      // for (var producto in productos) {
      //   try {
      //     final response = await apiClient.getAll(
      //       '${ApiConfig.productosEndpoint}/bySerialNumber/${producto.serie}',
      //       null,
      //     );

      //     if (response != null &&
      //         response['serial_number'] == producto.serie &&
      //         response['serial_number'] != null) {
      //       resultados.add(response);
      //     } else {
      //       noEncontrados.add(producto.serie);
      //     }
      //   } catch (e) {
      //     noEncontrados.add(producto.serie);
      //   }
      // }

      if (resultados.isEmpty) {
        return RepositoryResponse.error(
          'No se encontraron productos con las series escaneadas: ${noEncontrados.join(", ")}',
        );
      }

      String message = 'Productos enviados correctamente';
      if (noEncontrados.isNotEmpty) {
        message =
            'ATENCIÓN: Se encontraron ${resultados.length} productos. No se encontraron ${noEncontrados.length} productos con series: ${noEncontrados.join(", ")}';
      }

      return RepositoryResponse.success(resultados, message: message);
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
          final currentAlmacenId = producto['codigoalmacen'];

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

  Future<RepositoryResponse> getProductoBySerieAndAlmacen(
    String serie,
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
          producto = getAllResponse.firstWhere((p) => p['serie'] == serie);
        } catch (e) {
          return RepositoryResponse.error(
            'No se encontró el producto con serie: $serie',
          );
        }

        if (producto != null) {
          if (producto['codigoalmacen'] == almacenId) {
            return RepositoryResponse.success(
              producto,
              message: 'Producto encontrado en el almacén especificado',
            );
          } else {
            return RepositoryResponse.error(
              'El producto existe pero está asignado al almacén ${producto['codigoalmacen']}',
              data: producto,
            );
          }
        } else {
          return RepositoryResponse.error(
            'No se encontró el producto con serie: $serie',
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
