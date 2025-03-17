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
      
      return RepositoryResponse.success(resultados, message: 'Productos enviados correctamente');
    } catch (e) {
      throw Exception('Error al enviar productos: ${e.toString()}');
    }
  }

  Future<RepositoryResponse> trasladarProducto(int productoId, int newHospitalId) async {
    try {
      final getAllResponse = await apiClient.getAll(ApiConfig.productosEndpoint, {});
      
      if (getAllResponse != null && getAllResponse is List) {
        dynamic producto;
        try {
          producto = getAllResponse.firstWhere(
            (p) => p['numproducto'] == productoId,
          );
        } catch (e) {
          return RepositoryResponse.error('No se encontró el producto con numproducto: $productoId');
        }
        
        if (producto != null) {
          if (producto['codigoalmacen'] == newHospitalId) {
            return RepositoryResponse.success(
              producto, 
              message: 'El producto ya se encuentra en el almacén especificado'
            );
          }
          
          final response = await apiClient.patch(
            '${ApiConfig.productosEndpoint}/${producto['id']}',
            {'codigoalmacen': newHospitalId, 'stock': producto['stock']},
          );
          
          return RepositoryResponse.success(response, message: 'Producto trasladado correctamente');
        } else {
          return RepositoryResponse.error('No se encontró el producto con numproducto: $productoId');
        }
      } else {
        return RepositoryResponse.error('Error al obtener la lista de productos');
      }
    } catch (e) {
      return RepositoryResponse.error('Error al trasladar producto: ${e.toString()}');
    }
  }

  Future<RepositoryResponse> getProductoByNumeroAndAlmacen(int numproducto, int almacenId) async {
    try {
      final getAllResponse = await apiClient.getAll(ApiConfig.productosEndpoint, {});
      
      if (getAllResponse != null && getAllResponse is List) {
        dynamic producto;
        try {
          producto = getAllResponse.firstWhere(
            (p) => p['numproducto'] == numproducto,
          );
        } catch (e) {
          return RepositoryResponse.error('No se encontró el producto con numproducto: $numproducto');
        }
        
        if (producto != null) {
          if (producto['codigoalmacen'] == almacenId) {
            return RepositoryResponse.success(
              producto, 
              message: 'Producto encontrado en el almacén especificado'
            );
          } else {
            return RepositoryResponse.error(
              'El producto existe pero está asignado al almacén ${producto['codigoalmacen']}',
              data: producto
            );
          }
        } else {
          return RepositoryResponse.error('No se encontró el producto con numproducto: $numproducto');
        }
      } else {
        return RepositoryResponse.error('Error al obtener la lista de productos');
      }
    } catch (e) {
      return RepositoryResponse.error('Error al obtener el producto: ${e.toString()}');
    }
  }
  
  Future<RepositoryResponse> getProductoBySerieAndAlmacen(String serie, int almacenId) async {
    try {
      final getAllResponse = await apiClient.getAll(ApiConfig.productosEndpoint, {});
      
      if (getAllResponse != null && getAllResponse is List) {
        dynamic producto;
        try {
          producto = getAllResponse.firstWhere(
            (p) => p['serie'] == serie,
          );
        } catch (e) {
          return RepositoryResponse.error('No se encontró el producto con serie: $serie');
        }
        
        if (producto != null) {
          if (producto['codigoalmacen'] == almacenId) {
            return RepositoryResponse.success(
              producto, 
              message: 'Producto encontrado en el almacén especificado'
            );
          } else {
            return RepositoryResponse.error(
              'El producto existe pero está asignado al almacén ${producto['codigoalmacen']}',
              data: producto
            );
          }
        } else {
          return RepositoryResponse.error('No se encontró el producto con serie: $serie');
        }
      } else {
        return RepositoryResponse.error('Error al obtener la lista de productos');
      }
    } catch (e) {
      return RepositoryResponse.error('Error al obtener el producto: ${e.toString()}');
    }
  }
}
