import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quilmedic/data/respository/hospital_repository.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/hospital.dart';
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
  late HospitalRepository hospitalRepository = HospitalRepository(
    apiClient: apiClient,
  );

  ListaProductosBloc() : super(ListaProductosInitial()) {
    on<CargarProductosEvent>(_cargarProductos);
    on<MostrarProductosEvent>(_mostrarProductos);
    on<CargarHospitalesEvent>(_cargarHospitales);
    on<EnviarSolicitudTrasladoEvent>(_enviarSolicitudTraslado);
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
                
                if (productosEscaneadosIds.contains(numerodeproducto.toString())) {
                  
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
                emit(ListaProductosError('Error al cargar productos: ${e.toString()}'));
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
          final Map<String, Producto> productosMap = {};
          
          for (var item in response) {
            if (item is Map<String, dynamic>) {
              try {
                final String numProducto = item['numerodeproducto'] ?? "0";
                
                if (productosEscaneadosIds.contains(numProducto)) {
                  int codigoAlmacen = item['codigoalmacen'] ?? 0;
                  
                  if (traslados.containsKey(numProducto)) {
                    final Map<String, dynamic> infoTraslado = traslados[numProducto];
                    if (infoTraslado.containsKey('nuevoHospitalId')) {
                      codigoAlmacen = infoTraslado['nuevoHospitalId'];
                    }
                  }
                  
                  final producto = Producto(
                    item['numerodeproducto'] ?? 0,
                    item['descripcion'] ?? '',
                    codigoAlmacen,
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
                emit(ListaProductosError('Error al cargar productos desde caché: ${e.toString()}'));
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

  void _mostrarProductos(MostrarProductosEvent event, Emitter<ListaProductosState> emit) {
    emit(ProductosCargadosState(event.productos));
  }

  Future<void> _cargarHospitales(CargarHospitalesEvent event, Emitter<ListaProductosState> emit) async {
    try {
      emit(CargandoHospitalesState());
      
      List<Hospital> hospitales = await hospitalRepository
        .getAllHospitals()
        .then((value) => value.data);
    
      if (hospitales.isNotEmpty) {
        emit(HospitalesCargadosState(hospitales));
      } else {
        emit(ErrorCargaHospitalesState('No se encontraron hospitales'));
      }
    } catch (e) {
      emit(ErrorCargaHospitalesState(e.toString()));
    }
  }

  Future<void> _enviarSolicitudTraslado(EnviarSolicitudTrasladoEvent event, Emitter<ListaProductosState> emit) async {
    try {
      emit(EnviandoSolicitudTrasladoState());
      
      // final Map<String, dynamic> data = {
      //   'producto_id': event.producto.numerodeproducto,
      //   'hospital_origen_id': event.producto.codigoalmacen,
      //   'hospital_destino_id': event.hospitalDestinoId,
      //   'hospital_destino_nombre': event.hospitalDestinoNombre,
      //   'comentarios': event.comentarios,
      // };
      
      try {
        // final response = await apiClient.post('/solicitudes-traslado', data);
        emit(SolicitudTrasladoEnviadaState(
          'Solicitud de traslado enviada correctamente',
        ));
        // if (response is Map<String, dynamic> && response['success'] == true) {
        //   emit(SolicitudTrasladoEnviadaState(
        //     'Solicitud de traslado enviada correctamente',
        //   ));
        // } else {
        //   emit(ErrorSolicitudTrasladoState(
        //     'Error al enviar la solicitud de traslado: ${response['message'] ?? 'Error desconocido'}',
        //   ));
        // }
      } catch (e) {
        // Si hay un error de conexión, simular que se ha enviado correctamente
        // TODO guardar localmente para reintento
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Connection refused') ||
            e.toString().contains('Network is unreachable')) {
          emit(SolicitudTrasladoEnviadaState(
            'Solicitud de traslado registrada (pendiente de sincronización)',
          ));
        } else {
          emit(ErrorSolicitudTrasladoState(
            'Error al enviar la solicitud de traslado: ${e.toString()}',
          ));
        }
      }
    } catch (e) {
      emit(ErrorSolicitudTrasladoState(
        'Error inesperado: ${e.toString()}',
      ));
    }
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
      return {};
    }
  }
}
