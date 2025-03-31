import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/hospital_repository.dart';
import 'package:quilmedic/data/respository/producto_repository.dart';
import 'package:quilmedic/domain/alarm.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/ui/list/lista_productos_page.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:quilmedic/utils/connectivity_service.dart';
import 'package:quilmedic/utils/alarm_utils.dart';

part 'escaner_event.dart';
part 'escaner_state.dart';

class EscanerBloc extends Bloc<EscanerEvent, EscanerState> {
  List<ProductoEscaneado> productosEscaneados = [];
  Hospital? hospitalSeleccionado;
  bool hayProductosPendientes = false;

  final ApiClient apiClient = ApiClient();
  late HospitalRepository hospitalRepository = HospitalRepository(
    apiClient: apiClient,
  );
  late ProductoRepository productoRepository = ProductoRepository(
    apiClient: apiClient,
  );
  late ProductoLocalStorage productoLocalStorage = ProductoLocalStorage();
  late AlarmUtils alarmUtils = AlarmUtils();

  EscanerBloc() : super(EscanerInitial()) {
    on<LoadHospitales>(cargarHospitales);
    on<SubmitCodeEvent>(_procesarCodigoDeBarras);
    on<ElegirHospitalEvent>(elegirHospitales);
    on<GuardarProductosEvent>(guardarProductos);
    on<GuardarProductosForzadoEvent>(_guardarProductosForzado);
    on<EliminarProductoEvent>(_eliminarProducto);
    on<SincronizarProductosPendientesEvent>(_sincronizarProductosPendientes);
    on<CargarProductosPendientesEvent>(_cargarProductosPendientes);

    add(CargarProductosPendientesEvent());
  }

  Future<void> cargarHospitales(
    LoadHospitales event,
    Emitter<EscanerState> emit,
  ) async {
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

      final productosPendientes =
          await ProductoLocalStorage.obtenerProductosPendientes();
      if (productosPendientes.any((p) => p.serie == nuevoProducto.serie)) {
        emit(ProductoEscaneadoExistenteState(nuevoProducto));
        return;
      }

      productosEscaneados.add(nuevoProducto);
      emit(ProductoEscaneadoGuardadoState(nuevoProducto));
      emit(
        ProductosListadosState(
          productosEscaneados,
          hayProductosPendientes: hayProductosPendientes,
        ),
      );
    } catch (e) {
      emit(
        EscanerError("Error al procesar el código de barras: ${e.toString()}"),
      );
    }
  }

  void elegirHospitales(ElegirHospitalEvent event, Emitter<EscanerState> emit) {
    hospitalSeleccionado = event.hospital;
    emit(EscanerSuccess());
    emit(
      ProductosListadosState(
        productosEscaneados,
        hayProductosPendientes: hayProductosPendientes,
      ),
    );
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

    ProductoLocalStorage.eliminarProductoPendiente(event.producto.serie);

    emit(
      ProductosListadosState(
        productosEscaneados,
        hayProductosPendientes: hayProductosPendientes,
      ),
    );
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
      emit(
        EscanerError(
          "Error general durante la sincronización: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> _cargarProductosPendientes(
    CargarProductosPendientesEvent event,
    Emitter<EscanerState> emit,
  ) async {
    try {
      bool hayPendientes = await ProductoLocalStorage.hayProductosPendientes();
      hayProductosPendientes = hayPendientes;

      if (hayPendientes) {
        final productosPendientes = await _obtenerProductosPendientes(emit);
        if (productosPendientes != null && productosPendientes.isNotEmpty) {
          for (var producto in productosPendientes) {
            if (!productosEscaneados.any((p) => p.serie == producto.serie)) {
              productosEscaneados.add(producto);
            }
          }

          emit(
            ProductosListadosState(
              productosEscaneados,
              hayProductosPendientes: false,
            ),
          );
        }
      } else {
        emit(
          ProductosListadosState(
            productosEscaneados,
            hayProductosPendientes: false,
          ),
        );
      }
    } catch (e) {
      emit(
        ProductosListadosState(
          productosEscaneados,
          hayProductosPendientes: false,
        ),
      );
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
      emit(GuardarOfflineSuccess());
      emit(
        ProductosListadosState(
          productosEscaneados,
          hayProductosPendientes: true,
        ),
      );
    } catch (storageError) {
      emit(
        EscanerError(
          "Error al guardar productos localmente: ${storageError.toString()}",
        ),
      );
    }
  }

  Future<void> _comprobarProductosPendientes(Emitter<EscanerState> emit) async {
    try {
      final productosPendientes =
          await ProductoLocalStorage.obtenerProductosPendientes();
      final hospitalIdPendiente =
          await ProductoLocalStorage.obtenerHospitalPendiente();

      if (productosPendientes.isNotEmpty &&
          hospitalIdPendiente == hospitalSeleccionado!.id) {
        for (var productoPendiente in productosPendientes) {
          if (!productosEscaneados.any(
            (p) => p.serie == productoPendiente.serie,
          )) {
            productosEscaneados.add(productoPendiente);
          }
        }

        await ProductoLocalStorage.limpiarProductosPendientes();
        emit(
          ProductosListadosState(
            productosEscaneados,
            hayProductosPendientes: hayProductosPendientes,
          ),
        );
      }
    } catch (e) {
      emit(
        EscanerError(
          "Error al comprobar productos pendientes: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> _guardarProductosEnServidor(Emitter<EscanerState> emit) async {
    try {
      List<ProductoEscaneado> productosCopia = List.from(productosEscaneados);

      try {
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

          List<Alarm> alarmLocal = await ProductoLocalStorage.obtenerAlarmas();
          if (alarmLocal.isEmpty) {
            final alarms = await alarmUtils.getGeneralAlarms();
            await ProductoLocalStorage.agregarAlarmas(alarms);
          }

          try {
            await alarmUtils.loadStockColorsForProducts(productos);
            
            await alarmUtils.loadExpiryColorsForProducts(productos);
          } catch (e) {
            print('Error al precargar colores de alarmas: $e');
          }

          // List<Alarm> alarmasEspecificas = await ProductoLocalStorage.obtenerAlarmasEspecificas();
          // if (alarmasEspecificas.isEmpty) {
          //   final alarms = await alarmUtils.getAlarmasEspecificas();
          //   await ProductoLocalStorage.agregarAlarmasEspecificas(alarms);
          // }

          if (response.message?.contains("No se encontraron") ?? false) {
            emit(
              GuardarSuccess(productos: productos, mensaje: response.message),
            );
            emit(ProductosRecibidosState(productos, mensaje: response.message));
          } else {
            emit(GuardarSuccess(productos: productos));
            emit(ProductosRecibidosState(productos));
          }
        } else {
          emit(
            EscanerError(
              response.message ?? "Error desconocido al guardar productos",
            ),
          );
        }
      } catch (connectionError) {
        await ProductoLocalStorage.guardarProductosPendientes(
          productosCopia,
          hospitalSeleccionado!.id,
        );

        productosEscaneados.clear();
        emit(GuardarOfflineSuccess());
      }
    } catch (e) {
      emit(EscanerError("Error general al guardar productos: ${e.toString()}"));
    }
  }

  Future<void> _enviarProductosAlServidor(Emitter<EscanerState> emit) async {
    try {
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

        if (response.message?.contains("No se encontraron") ?? false) {
          emit(GuardarSuccess(productos: productos, mensaje: response.message));
          emit(ProductosRecibidosState(productos, mensaje: response.message));
        } else {
          emit(GuardarSuccess(productos: productos));
          emit(ProductosRecibidosState(productos));
        }
      } else {
        emit(
          EscanerError(
            response.message ?? "Error desconocido al guardar productos",
          ),
        );
      }
    } catch (e) {
      emit(EscanerError("Error al guardar productos: ${e.toString()}"));
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

  Future<List<ProductoEscaneado>?> _obtenerProductosPendientes(
    Emitter<EscanerState> emit,
  ) async {
    try {
      return await ProductoLocalStorage.obtenerProductosPendientes();
    } catch (e) {
      emit(
        EscanerError("Error al obtener productos pendientes: ${e.toString()}"),
      );
      return null;
    }
  }

  Future<void> _sincronizarConServidor(
    Emitter<EscanerState> emit,
    int hospitalId,
    List<ProductoEscaneado> productosPendientes,
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

        if (response.message?.contains("No se encontraron") ?? false) {
          emit(
            SincronizacionCompletaState(productos, mensaje: response.message),
          );
          emit(GuardarSuccess(productos: productos, mensaje: response.message));
          emit(ProductosRecibidosState(productos, mensaje: response.message));
        } else {
          emit(SincronizacionCompletaState(productos));
          emit(GuardarSuccess(productos: productos));
          emit(ProductosRecibidosState(productos));
        }
      } else {
        emit(
          EscanerError(
            response.message ?? "Error desconocido al sincronizar productos",
          ),
        );
      }
    } catch (e) {
      emit(EscanerError("Error durante la sincronización: ${e.toString()}"));
    }
  }

  Future<void> _actualizarHospitalSeleccionado(
    Emitter<EscanerState> emit,
    int hospitalId,
  ) async {
    if (hospitalSeleccionado == null ||
        hospitalSeleccionado!.id != hospitalId) {
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

  Future<void> _guardarProductosEscaneadosLocalmente(
    List<Producto> productos,
  ) async {
    try {
      final List<String> productosIds =
          productos.map((p) => p.numerodeproducto).toList();

      for (final id in productosIds) {
        await ProductoLocalStorage.agregarProductoEscaneado(id);
      }
    } catch (e) {
      throw Exception(
        'Error al guardar productos escaneados localmente: ${e.toString()}',
      );
    }
  }

  void navegarAListaProductos(BuildContext context, List<Producto> productos) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ListaProductosPage(
              productos: productos,
              hospitalId: hospitalSeleccionado?.id ?? 0,
            ),
      ),
    );
  }
}
