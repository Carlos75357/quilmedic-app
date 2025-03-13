import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/respository/data_source.dart';
import 'package:quilmedic/data/respository/repository_response.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

class ProductoRepository {
  final DataSource _dataSource;

  ProductoRepository({DataSource? dataSource})
      : _dataSource = dataSource ?? DataSource();

  Future<RepositoryResponse<List<Producto>>> obtenerInformacionProductos(
      List<ProductoEscaneado> productosEscaneados, Hospital hospital) async {
    try {
      final Map<String, dynamic> requestData = {
        'hospital_id': hospital.codigo,
        'productos': productosEscaneados.map((p) => {
              'id': p.id,
              'serie': p.serie,
            }).toList(),
      };

      final Map<String, dynamic> response = await _dataSource.post(
        ApiConfig.productosEndpoint,
        requestData,
      );

      if (response.containsKey('productos') && response['productos'] is List) {
        final List<dynamic> productosData = response['productos'];
        
        final productos = productosData.map<Producto>((productoData) {
          return Producto(
            productoData['numproducto'] ?? 0,
            productoData['descripcion'],
            productoData['codigoalmacen'] ?? 0,
            productoData['ubicacion'],
            productoData['numerolote'] ?? 0,
            productoData['descripcionlote'],
            productoData['numerodeproducto'] ?? 0,
            productoData['descripcion1'] ?? 'Sin descripción',
            productoData['codigoalmacen1'] ?? 0,
            productoData['serie'] ?? 0,
            productoData['fechacaducidad'] != null 
                ? DateTime.parse(productoData['fechacaducidad']) 
                : DateTime.now().add(const Duration(days: 365)),
          );
        }).toList();
        
        return RepositoryResponse.success(
          productos,
          message: 'Se obtuvieron ${productos.length} productos correctamente',
        );
      }
      
      return RepositoryResponse.error('Formato de respuesta inválido');
    } catch (e) {
      return RepositoryResponse.error(
        'Error al obtener información de productos: $e',
        error: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  Future<RepositoryResponse<bool>> guardarProductos(List<Producto> productos, Hospital hospital) async {
    try {
      final Map<String, dynamic> requestData = {
        'hospital_id': hospital.codigo,
        'productos': productos.map((p) => {
              'numproducto': p.numproducto,
              'descripcion': p.descripcion,
              'codigoalmacen': p.codigoalmacen,
              'ubicacion': p.ubicacion,
              'numerolote': p.numerolote,
              'descripcionlote': p.descripcionlote,
              'numerodeproducto': p.numerodeproducto,
              'descripcion1': p.descripcion1,
              'codigoalmacen1': p.codigoalmacen1,
              'serie': p.serie,
              'fechacaducidad': p.fechacaducidad.toIso8601String(),
            }).toList(),
      };

      final Map<String, dynamic> response = await _dataSource.post(
        ApiConfig.guardarProductosEndpoint,
        requestData,
      );

      if (response.containsKey('success') && response['success'] == true) {
        return RepositoryResponse.success(
          true,
          message: response['message'] ?? 'Productos guardados correctamente',
        );
      }
      
      return RepositoryResponse.error(
        response['message'] ?? 'Error al guardar productos',
      );
    } catch (e) {
      return RepositoryResponse.error(
        'Error al guardar productos: $e',
        error: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  Future<RepositoryResponse<List<Producto>>> obtenerProductosPorHospital(Hospital hospital) async {
    try {
      final Map<String, dynamic> response = await _dataSource.get(
        '${ApiConfig.productosEndpoint}?hospital_id=${hospital.codigo}',
      );

      if (response.containsKey('productos') && response['productos'] is List) {
        final List<dynamic> productosData = response['productos'];
        
        final productos = productosData.map<Producto>((productoData) {
          return Producto(
            productoData['numproducto'] ?? 0,
            productoData['descripcion'],
            productoData['codigoalmacen'] ?? 0,
            productoData['ubicacion'],
            productoData['numerolote'] ?? 0,
            productoData['descripcionlote'],
            productoData['numerodeproducto'] ?? 0,
            productoData['descripcion1'] ?? 'Sin descripción',
            productoData['codigoalmacen1'] ?? 0,
            productoData['serie'] ?? 0,
            productoData['fechacaducidad'] != null 
                ? DateTime.parse(productoData['fechacaducidad']) 
                : DateTime.now().add(const Duration(days: 365)),
          );
        }).toList();
        
        return RepositoryResponse.success(
          productos,
          message: 'Se obtuvieron ${productos.length} productos del hospital ${hospital.nombre}',
        );
      }
      
      return RepositoryResponse.error('Formato de respuesta inválido');
    } catch (e) {
      return RepositoryResponse.error(
        'Error al obtener productos por hospital: $e',
        error: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  Future<RepositoryResponse<List<Producto>>> obtenerInformacionProductosSimulado(
      List<ProductoEscaneado> productosEscaneados, Hospital hospital) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final productos = productosEscaneados.map((producto) {
        return Producto(
          producto.id,
          'Descripción del producto ${producto.serie}',
          hospital.codigo,
          'Ubicación A-${producto.serie % 10}',
          100 + producto.serie % 1000,
          'Lote ${producto.serie % 100}',
          producto.serie,
          'Producto ${producto.serie} - ${hospital.nombre}',
          hospital.codigo,
          producto.serie,
          DateTime.now().add(Duration(days: 30 + (producto.serie % 365))),
        );
      }).toList();
      
      return RepositoryResponse.success(
        productos,
        message: 'Se obtuvieron ${productos.length} productos simulados',
      );
    } catch (e) {
      return RepositoryResponse.error(
        'Error al obtener información simulada de productos: $e',
        error: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  void dispose() {
    _dataSource.dispose();
  }
}