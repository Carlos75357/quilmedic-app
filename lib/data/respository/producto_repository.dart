import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/data/respository/repository_response.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';

class ProductoRepository {
  final ApiClient apiClient;

  ProductoRepository({required this.apiClient});

  Future<RepositoryResponse> enviarProductosEscaneados(
    String hospitalId,
    List<ProductoEscaneado> productos,
  ) async {
    final List<dynamic> resultados = [];

    try {
      for (var producto in productos) {
        final response = await apiClient.getAll(
          '${ApiConfig.productosEndpoint}?serie=${producto.serie}',
          null,
        );

        if (response is List) {
          for (var item in response) {
            if (item is Map<String, dynamic> &&
                item['serie'] != null &&
                item['serie'] == producto.serie) {
              resultados.add(item);
            }
          }
        }
      }

      return RepositoryResponse.success(
        resultados,
        message: 'Productos enviados correctamente',
      );
    } catch (e) {
      throw Exception('Error al enviar productos: ${e.toString()}');
    }
  }

  Future<RepositoryResponse> trasladarProducto(
    String productoId,
    String newHospitalId,
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
            (p) => p['numproducto'] == productoId,
          );
        } catch (e) {
          return RepositoryResponse.error(
            'No se encontró el producto con numproducto: $productoId',
          );
        }

        if (producto != null) {
          final currentAlmacen = producto['codigoalmacen'];
          int currentAlmacenId;

          if (currentAlmacen is String) {
            try {
              currentAlmacenId = int.parse(currentAlmacen);
            } catch (e) {
              return RepositoryResponse.error(
                'Error en formato de codigoalmacen actual: $currentAlmacen',
              );
            }
          } else {
            currentAlmacenId = currentAlmacen;
          }

          if (currentAlmacenId == newHospitalId) {
            return RepositoryResponse.success(
              producto,
              message: 'El producto ya se encuentra en el almacén especificado',
            );
          }

          final String productoDbId = producto['id'];

          final Map<String, dynamic> updateData = {
            'codigoalmacen': newHospitalId,
          };

          if (producto['stock'] != null) {
            updateData['stock'] = producto['stock'];
          }

          final response = await apiClient.patch(
            '${ApiConfig.productosEndpoint}/$productoDbId',
            updateData,
          );

          await _actualizarProductoEnCache(productoId, newHospitalId);

          try {
            final verificacionResponse = await apiClient.getAll(
              '${ApiConfig.productosEndpoint}/$productoDbId',
              {},
            );

            if (verificacionResponse != null &&
                verificacionResponse['codigoalmacen'] != null) {
              int almacenActualizado;
              if (verificacionResponse['codigoalmacen'] is String) {
                almacenActualizado = int.parse(
                  verificacionResponse['codigoalmacen'],
                );
              } else {
                almacenActualizado = verificacionResponse['codigoalmacen'];
              }

              if (almacenActualizado != newHospitalId) {
                print(
                  'Advertencia: El almacén no se actualizó correctamente en el servidor. ' +
                      'Se usará la información local para mostrar el producto en el almacén correcto.',
                );
              }
            }
          } catch (e) {
            print(
              'Error al verificar la actualización del producto: ${e.toString()}',
            );
          }

          return RepositoryResponse.success(
            response,
            message: 'Producto trasladado correctamente',
          );
        } else {
          return RepositoryResponse.error(
            'No se encontró el producto con numproducto: $productoId',
          );
        }
      } else {
        return RepositoryResponse.error(
          'Error al obtener la lista de productos',
        );
      }
    } catch (e) {
      return RepositoryResponse.error(
        'Error al trasladar producto: ${e.toString()}',
      );
    }
  }

  Future<void> _actualizarProductoEnCache(
    String numproducto,
    String nuevoHospitalId,
  ) async {
    try {
      await ProductoLocalStorage.guardarInfoTraslado(
        numproducto,
        nuevoHospitalId,
      );
    } catch (e) {
      print('Error al actualizar producto en caché: ${e.toString()}');
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
          final currentAlmacen = producto['codigoalmacen'];
          int currentAlmacenId;

          if (currentAlmacen is String) {
            try {
              currentAlmacenId = int.parse(currentAlmacen);
            } catch (e) {
              return RepositoryResponse.error(
                'Error en formato de codigoalmacen: $currentAlmacen',
              );
            }
          } else {
            currentAlmacenId = currentAlmacen;
          }

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
