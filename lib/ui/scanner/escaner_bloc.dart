import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/hospital_repository.dart';
import 'package:quilmedic/data/respository/producto_repository.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/ui/list/lista_productos_page.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:quilmedic/utils/connectivity_service.dart';

part 'escaner_event.dart';
part 'escaner_state.dart';

class EscanerBloc extends Bloc<EscanerEvent, EscanerState> {
  List<ProductoEscaneado> productosEscaneados = [];
  Hospital? hospitalSeleccionado;

  final ApiClient apiClient = ApiClient();
  late HospitalRepository hospitalRepository = HospitalRepository(
    apiClient: apiClient,
  );
  late ProductoRepository productoRepository = ProductoRepository(
    apiClient: apiClient,
  );

  EscanerBloc() : super(EscanerInitial()) {
    on<LoadHospitales>(cargarHospitales);
    on<ElegirHospitalEvent>(elegirHospitales);
    on<SubmitCodeEvent>(_procesarCodigoDeBarras);
    on<GuardarProductosEvent>(guardarProductos);
    on<GuardarProductosForzadoEvent>(_guardarProductosForzado);
    on<EliminarProductoEvent>(_eliminarProducto);
    on<SincronizarProductosPendientesEvent>(_sincronizarProductosPendientes);
  }

  Future<void> cargarHospitales(LoadHospitales event, Emitter<EscanerState> emit) async {
    emit(EscanerLoading());

    try {
      List<Hospital> hospitales = await hospitalRepository
          .getAllHospitals()
          .then((value) => value.data);

      emit(HospitalesCargados(hospitales));
    } catch (e) {
      emit(EscanerError(e.toString()));
    }
  }

  Future<void> _procesarCodigoDeBarras(
    SubmitCodeEvent event,
    Emitter<EscanerState> emit,
  ) async {
    try {
      if (_validarHospitalSeleccionado(emit) == false) return;

      final String code = event.code;

      if (code.isEmpty) {
        emit(EscanerError("Código inválido: No puede estar vacío"));
        return;
      }

      final ProductoEscaneado nuevoProducto = ProductoEscaneado(code);

      if (productosEscaneados.any((p) => p.serie == nuevoProducto.serie)) {
        emit(ProductoEscaneadoExistenteState(nuevoProducto));
        return;
      }

      final productosPendientes = await ProductoLocalStorage.obtenerProductosPendientes();
      if (productosPendientes.any((p) => p.serie == nuevoProducto.serie)) {
        emit(ProductoEscaneadoExistenteState(nuevoProducto));
        return;
      }

      productosEscaneados.add(nuevoProducto);
      emit(ProductoEscaneadoGuardadoState(nuevoProducto));
      emit(ProductosListadosState(productosEscaneados));
    } catch (e) {
      emit(EscanerError("Error al procesar el código de barras: ${e.toString()}"));
    }
  }

  void elegirHospitales(ElegirHospitalEvent event, Emitter<EscanerState> emit) {
    hospitalSeleccionado = event.hospital;
    emit(EscanerSuccess());
    emit(ProductosListadosState(productosEscaneados));
  }

  Future<void> guardarProductos(
    GuardarProductosEvent event,
    Emitter<EscanerState> emit,
  ) async {
    try {
      if (_validarHospitalSeleccionado(emit) == false) return;
      
      emit(EscanerLoading());
      
      await _comprobarProductosPendientes(emit);
      
      if (_validarProductosEscaneados(emit) == false) return;

      bool hayConexion = await _verificarConexion();
      
      if (!hayConexion) {
        await _guardarProductosLocal(emit);
        return;
      }
      
      await _guardarProductosEnServidor(emit);
    } catch (e) {
      emit(EscanerError("Error general al guardar productos: ${e.toString()}"));
    }
  }

  Future<void> _guardarProductosForzado(
    GuardarProductosForzadoEvent event,
    Emitter<EscanerState> emit,
  ) async {
    try {
      if (_validarHospitalSeleccionado(emit) == false) return;
      if (_validarProductosEscaneados(emit) == false) return;

      emit(EscanerLoading());

      await _enviarProductosAlServidor(emit);
    } catch (e) {
      emit(EscanerError("Error al guardar productos: ${e.toString()}"));
    }
  }

  void _eliminarProducto(
    EliminarProductoEvent event,
    Emitter<EscanerState> emit,
  ) {
    productosEscaneados.removeWhere((p) => p.serie == event.producto.serie);
    _eliminarProductoPorSerie(event.producto.serie);
    emit(ProductosListadosState(productosEscaneados));
  }

  Future<void> _sincronizarProductosPendientes(
    SincronizarProductosPendientesEvent event,
    Emitter<EscanerState> emit,
  ) async {
    try {
      bool hayPendientes = await ProductoLocalStorage.hayProductosPendientes();
      if (!hayPendientes) {
        emit(SinProductosPendientesState());
        return;
      }

      bool hayConexion = await _verificarConexion();
      if (!hayConexion) {
        emit(EscanerError("No hay conexión a internet para sincronizar"));
        return;
      }

      emit(EscanerLoading());

      final productosPendientes = await _obtenerProductosPendientes(emit);
      if (productosPendientes == null) return;
      
      final hospitalId = await ProductoLocalStorage.obtenerHospitalPendiente();
      if (hospitalId == null || productosPendientes.isEmpty) {
        await ProductoLocalStorage.limpiarProductosPendientes();
        emit(SinProductosPendientesState());
        return;
      }

      await _sincronizarConServidor(emit, hospitalId, productosPendientes);
    } catch (e) {
      emit(EscanerError("Error general durante la sincronización: ${e.toString()}"));
    }
  }

  bool _validarHospitalSeleccionado(Emitter<EscanerState> emit) {
    if (hospitalSeleccionado == null) {
      emit(EscanerError("Debe seleccionar un hospital primero"));
      return false;
    }
    return true;
  }
  
  bool _validarProductosEscaneados(Emitter<EscanerState> emit) {
    if (productosEscaneados.isEmpty) {
      emit(EscanerError("No hay productos escaneados para guardar"));
      return false;
    }
    return true;
  }
  
  Future<bool> _verificarConexion() async {
    try {
      return await ConnectivityService.hayConexionInternet();
    } catch (e) {
      return false;
    }
  }
  
  Future<void> _guardarProductosLocal(Emitter<EscanerState> emit) async {
    try {
      await ProductoLocalStorage.guardarProductosPendientes(
        productosEscaneados,
        hospitalSeleccionado!.id,
      );
      productosEscaneados.clear();
      emit(GuardarOfflineSuccess());
    } catch (storageError) {
      emit(EscanerError("Error al guardar productos localmente: ${storageError.toString()}"));
    }
  }
  
  Future<void> _comprobarProductosPendientes(Emitter<EscanerState> emit) async {
    try {
      final productosPendientes = await ProductoLocalStorage.obtenerProductosPendientes();
      final hospitalIdPendiente = await ProductoLocalStorage.obtenerHospitalPendiente();
      
      if (productosPendientes.isNotEmpty && hospitalIdPendiente == hospitalSeleccionado!.id) {
        for (var productoPendiente in productosPendientes) {
          if (!productosEscaneados.any((p) => p.serie == productoPendiente.serie)) {
            productosEscaneados.add(productoPendiente);
          }
        }
        
        await ProductoLocalStorage.limpiarProductosPendientes();
        emit(ProductosListadosState(productosEscaneados));
      }
    } catch (e) {
      emit(EscanerError("Error al comprobar productos pendientes: ${e.toString()}"));
    }
  }
  
  Future<void> _guardarProductosEnServidor(Emitter<EscanerState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      var response = await productoRepository.enviarProductosEscaneados(
        hospitalSeleccionado!.id,
        productosEscaneados,
      );
      
      List<ProductoEscaneado> productosCopia = List.from(productosEscaneados);
      productosEscaneados.clear();
      
      if (response.success) {
        List<Producto> productos = List<Producto>.from(
          response.data.map((item) => Producto.fromApiMap(item)),
        );
        
        await _guardarProductosEscaneadosLocalmente(productos);
        emit(GuardarSuccess(productos: productos));
        emit(ProductosRecibidosState(productos));
      } else {
        await ProductoLocalStorage.guardarProductosPendientes(
          productosCopia,
          hospitalSeleccionado!.id,
        );
        
        emit(EscanerError(
          "Error al guardar productos en el servidor. Se han guardado localmente: ${response.message}",
        ));
      }
    } catch (e) {
      await _guardarProductosLocal(emit);
    }
  }
  
  Future<void> _enviarProductosAlServidor(Emitter<EscanerState> emit) async {
    var response = await productoRepository.enviarProductosEscaneados(
      hospitalSeleccionado!.id,
      productosEscaneados,
    );
    
    productosEscaneados.clear();
    
    if (response.success) {
      List<Producto> productos = List<Producto>.from(
        response.data.map((item) => Producto.fromApiMap(item)),
      );
      
      await _guardarProductosEscaneadosLocalmente(productos);
      emit(GuardarSuccess(productos: productos));
      emit(ProductosRecibidosState(productos));
    } else {
      emit(EscanerError("No se encontraron productos con las series escaneadas"));
    }
  }
  
  Future<void> _eliminarProductoPorSerie(String serie) async {
    try {
      final response = await apiClient.getAll('/productos', null);
      
      if (response is List) {
        for (var item in response) {
          if (item is Map<String, dynamic> &&
              item['serie'] != null &&
              item['serie'] == serie &&
              item['numproducto'] != null) {
            final String numProducto = item['numproducto'];
            await ProductoLocalStorage.eliminarProductoEscaneado(numProducto);
            break;
          }
        }
      }
    } catch (e) {
      throw Exception('Error al eliminar producto por serie: ${e.toString()}');
    }
  }
  
  Future<List<ProductoEscaneado>?> _obtenerProductosPendientes(Emitter<EscanerState> emit) async {
    try {
      return await ProductoLocalStorage.obtenerProductosPendientes();
    } catch (e) {
      emit(EscanerError("Error al obtener productos pendientes: ${e.toString()}"));
      return null;
    }
  }
  
  Future<void> _sincronizarConServidor(
    Emitter<EscanerState> emit,
    int hospitalId,
    List<ProductoEscaneado> productosPendientes
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      var response = await productoRepository.enviarProductosEscaneados(
        hospitalId,
        productosPendientes,
      );
      
      if (response.success) {
        await ProductoLocalStorage.limpiarProductosPendientes();
        
        List<Producto> productos = List<Producto>.from(
          response.data.map((item) => Producto.fromApiMap(item)),
        );
        
        await _guardarProductosEscaneadosLocalmente(productos);
        
        await _actualizarHospitalSeleccionado(emit, hospitalId);
        
        productosEscaneados.clear();
        
        emit(SincronizacionCompletaState(productos));
        emit(GuardarSuccess(productos: productos));
        emit(ProductosRecibidosState(productos));
      } else {
        emit(EscanerError("Error al sincronizar productos pendientes: ${response.message}"));
      }
    } catch (e) {
      emit(EscanerError("Error durante la sincronización: ${e.toString()}"));
    }
  }
  
  Future<void> _actualizarHospitalSeleccionado(Emitter<EscanerState> emit, int hospitalId) async {
    if (hospitalSeleccionado == null || hospitalSeleccionado!.id != hospitalId) {
      try {
        List<Hospital> hospitales = await hospitalRepository
            .getAllHospitals()
            .then((value) => value.data);
            
        for (var hospital in hospitales) {
          if (hospital.id == hospitalId) {
            hospitalSeleccionado = hospital;
            break;
          }
        }
      } catch (e) {
        emit(EscanerError("Error al obtener hospitales: ${e.toString()}"));
      }
    }
  }
  
  Future<void> _guardarProductosEscaneadosLocalmente(List<Producto> productos) async {
    try {
      final List<String> productosIds = productos.map((p) => p.numerodeproducto).toList();
      
      for (final id in productosIds) {
        await ProductoLocalStorage.agregarProductoEscaneado(id);
      }
    } catch (e) {
      throw Exception('Error al guardar productos escaneados localmente: ${e.toString()}');
    }
  }
  
  void navegarAListaProductos(BuildContext context, List<Producto> productos) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaProductosPage(
          productos: productos,
          hospitalId: hospitalSeleccionado?.id ?? 0,
        ),
      ),
    );
  }
}
