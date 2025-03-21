import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/producto_repository.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

part 'lista_productos_event.dart';
part 'lista_productos_state.dart';

class ListaProductosBloc
    extends Bloc<ListaProductosEvent, ListaProductosState> {
  final ApiClient apiClient = ApiClient();
  late ProductoRepository productoRepository = ProductoRepository(
    apiClient: apiClient,
  );

  ListaProductosBloc() : super(ListaProductosInitial()) {
    on<CargarProductosEvent>(_cargarProductos);
    on<MostrarProductosEvent>(_mostrarProductos);
  }

  Future<void> _cargarProductos(CargarProductosEvent event, Emitter<ListaProductosState> emit) async {
    try {
      emit(ListaProductosLoading());
      
      final List<String> productosEscaneadosIds = 
          await ProductoLocalStorage.obtenerProductosEscaneados();
      
      if (productosEscaneadosIds.isEmpty) {
        emit(ListaProductosError('No hay productos escaneados'));
        return;
      }
      
      try {
        final response = await productoRepository.getProductosByCodigos(productosEscaneadosIds);
        
        if (response.success && response.data is List) {
          final Map<int, Producto> productosMap = {};
          
          for (var item in response.data) {
            if (item is Map<String, dynamic>) {
              try {
                final int numerodeproducto = item['numerodeproducto'] ?? 0;
                
                if (productosEscaneadosIds.contains(numerodeproducto)) {
                  
                  final producto = Producto(
                    item['numerodeproducto'] ?? 0,
                    item['descripcion'] ?? '',
                    item['codigoalmacen'] ?? 0, 
                    item['numerolote'] ?? 0,
                    item['serie'] ?? '',
                    item['fechacaducidad'] != null
                        ? DateTime.parse(item['fechacaducidad'])
                        : DateTime.now(),
                    item['cantidad'] ?? 0,
                  );
                  
                  productosMap[numerodeproducto] = producto;
                }
              } catch (e) {
                print('Error al cargar producto: ${e.toString()}');
              }
            }
          }
          
          final List<Producto> productos = productosMap.values.toList();
          
          if (productos.isEmpty) {
            emit(ListaProductosError('No se encontraron productos escaneados'));
          } else {
            emit(ProductosCargadosState(productos));
          }
        } else {
          emit(
            ListaProductosError(
              'Error al cargar productos: ${response.message}',
            ),
          );
        }
      } catch (e) {
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Connection refused') ||
            e.toString().contains('Network is unreachable')) {
          emit(
            ListaProductosError(
              'No hay conexión a internet para cargar los productos. Usando datos locales.',
            ),
          );
        } else {
          emit(
            ListaProductosError('Error al cargar productos: ${e.toString()}. Usando datos locales.'),
          );
        }
        
        await _cargarProductosDesdeCache(emit);
      }
    } catch (e) {
      emit(ListaProductosError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _cargarProductosDesdeCache(Emitter<ListaProductosState> emit) async {
    try {
      final List<String> productosEscaneadosIds = 
          await ProductoLocalStorage.obtenerProductosEscaneados();
      
      if (productosEscaneadosIds.isEmpty) {
        emit(ListaProductosError('No hay productos escaneados en la caché local'));
        return;
      }
      
      final Map<String, dynamic> traslados = await _obtenerTodosLosTraslados();
      
      try {
        final response = await apiClient.getAll('/productos', null);
        
        if (response is List) {
          final Map<int, Producto> productosMap = {};
          
          for (var item in response) {
            if (item is Map<String, dynamic>) {
              try {
                final int numProducto = item['numproducto'] ?? 0;
                
                if (productosEscaneadosIds.contains(numProducto)) {
                  int codigoAlmacen = item['codigoalmacen'] ?? 0;
                  
                  final String numProductoStr = numProducto.toString();
                  if (traslados.containsKey(numProductoStr)) {
                    final Map<String, dynamic> infoTraslado = traslados[numProductoStr];
                    if (infoTraslado.containsKey('nuevoHospitalId')) {
                      codigoAlmacen = infoTraslado['nuevoHospitalId'];
                    }
                  }
                  
                  final producto = Producto(
                    item['numerodeproducto'] ?? 0,
                    item['descripcion'] ?? '',
                    item['codigoalmacen'] ?? 0, 
                    item['numerolote'] ?? 0,
                    item['serie'] ?? '',
                    item['fechacaducidad'] != null
                        ? DateTime.parse(item['fechacaducidad'])
                        : DateTime.now(),
                    item['cantidad'] ?? 0,
                  );
                  
                  productosMap[numProducto] = producto;
                }
              } catch (e) {
                print('Error al procesar producto desde caché: ${e.toString()}');
              }
            }
          }
          
          final List<Producto> productos = productosMap.values.toList();
          
          if (productos.isNotEmpty) {
            emit(ProductosCargadosState(productos));
          } else {
            emit(ListaProductosError('No se encontraron productos en la caché local'));
          }
        } else {
          emit(ListaProductosError('Formato de respuesta inválido en la caché local'));
        }
      } catch (e) {
        emit(ListaProductosError('Error al cargar productos desde caché: ${e.toString()}'));
      }
    } catch (e) {
      emit(ListaProductosError('Error al acceder a la caché local: ${e.toString()}'));
    }
  }

  void _mostrarProductos(
    MostrarProductosEvent event,
    Emitter<ListaProductosState> emit,
  ) {
    emit(ProductosCargadosState(event.productos));
  }

  // Método auxiliar para obtener todos los traslados
  Future<Map<String, dynamic>> _obtenerTodosLosTraslados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString('productos_trasladados');
      
      if (jsonString == null || jsonString.isEmpty) {
        return {};
      }
      
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error al obtener traslados: ${e.toString()}');
      return {};
    }
  }
}
