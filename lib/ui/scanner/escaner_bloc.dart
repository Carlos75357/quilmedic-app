import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/hospital_repository.dart';
import 'package:quilmedic/data/respository/location_repository.dart';
import 'package:quilmedic/data/respository/producto_repository.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:quilmedic/utils/connectivity_service.dart';
import 'package:quilmedic/utils/alarm_utils.dart';

part 'escaner_event.dart';
part 'escaner_state.dart';

/// Bloc que gestiona el estado del escáner de productos en la aplicación.
/// Maneja eventos relacionados con el escaneo de códigos de barras, selección de hospitales
/// y ubicaciones, y sincronización de productos con el servidor.
class EscanerBloc extends Bloc<EscanerEvent, EscanerState> {
  /// Lista de productos escaneados actualmente
  List<ProductoEscaneado> productosEscaneados = [];
  /// Hospital seleccionado actualmente
  Hospital? hospitalSeleccionado;
  /// Ubicación seleccionada dentro del hospital
  Location? locationSeleccionada;
  /// Indica si hay productos pendientes de sincronización
  bool hayProductosPendientes = false;

  /// Cliente API para realizar peticiones al servidor
  final ApiClient apiClient = ApiClient();
  /// Repositorio para gestionar operaciones con hospitales
  late HospitalRepository hospitalRepository = HospitalRepository(
    apiClient: apiClient,
  );
  /// Repositorio para gestionar operaciones con productos
  late ProductoRepository productoRepository = ProductoRepository(
    apiClient: apiClient,
  );
  /// Repositorio para gestionar operaciones con ubicaciones
  late LocationRepository locationRepository = LocationRepository(
    apiClient: apiClient,
  );
  /// Servicio para almacenamiento local de productos
  late ProductoLocalStorage productoLocalStorage = ProductoLocalStorage();
  /// Utilidad para gestionar alarmas de productos
  late AlarmUtils alarmUtils = AlarmUtils();

  /// Constructor del [EscanerBloc]
  /// Registra los manejadores de eventos y carga los productos pendientes
  EscanerBloc() : super(EscanerInitial()) {
    on<LoadHospitales>(cargarHospitales);
    on<LoadLocations>(loadLocationsForAStore);
    on<SubmitCodeEvent>(_procesarCodigoDeBarras);
    on<ChooseStoreEvent>(elegirHospitales);
    on<ChooseLocationEvent>(chooseLocation);
    on<GuardarProductosEvent>(guardarProductos);
    on<EliminarProductoEvent>(_eliminarProducto);
    on<CargarProductosPendientesEvent>(_cargarProductosPendientes);
    on<ResetSelectionsEvent>(resetSelections);

    add(CargarProductosPendientesEvent());
  }

  /// Carga la lista de hospitales desde el servidor
  /// @param [event] Evento para cargar hospitales
  /// @param [emit] Emisor para cambiar el estado
  Future<void> cargarHospitales(
    LoadHospitales event,
    Emitter<EscanerState> emit,
  ) async {
    emit(EscanerLoading());

    try {
      hospitalSeleccionado = null;
      locationSeleccionada = null;

      List<Hospital> hospitales = await hospitalRepository
          .getAllHospitals()
          .then((value) => value.data);

      emit(HospitalesCargados(hospitales));
    } catch (e) {
      await _guardarProductosEnCacheEnCasoDeError(emit);

      emit(EscanerError('Error al cargar hospitales'));
    }
  }

  /// Guarda los productos escaneados en caché local en caso de error
  /// Se utiliza cuando hay problemas de conexión o errores del servidor
  /// @param [emitter] Emisor opcional para cambiar el estado
  Future<void> _guardarProductosEnCacheEnCasoDeError([
    Emitter<EscanerState>? emitter,
  ]) async {
    if (productosEscaneados.isNotEmpty) {
      try {
        int hospitalId = hospitalSeleccionado?.id ?? 0;
        int locationId = locationSeleccionada?.id ?? 0;

        await ProductoLocalStorage.guardarProductosPendientes(
          productosEscaneados,
          hospitalId,
          locationId,
        );

        hayProductosPendientes = true;

        if (emitter != null && !emitter.isDone) {
          emitter.call(
            ProductosListadosState(
              productosEscaneados,
              hayProductosPendientes: true,
            ),
          );
        }
      } catch (e) {
        emitter!(EscanerError('Error al guardar productos en caché'));
      }
    }
  }

  /// Carga las ubicaciones disponibles para el hospital seleccionado
  /// @param [event] Evento para cargar ubicaciones
  /// @param [emit] Emisor para cambiar el estado
  Future<void> loadLocationsForAStore(
    LoadLocations event,
    Emitter<EscanerState> emit,
  ) async {
    emit(EscanerLoading());

    try {
      locationSeleccionada = null;

      if (hospitalSeleccionado == null) {
        emit(EscanerError('No hay hospital seleccionado'));
        return;
      }

      await locationRepository
          .getLocationsForAStore(hospitalSeleccionado!.id)
          .then((value) => value.data)
          .then((locations) {
            if (!emit.isDone) {
              emit(LocationsCargadas(locations));
            }
          });
    } catch (e) {
      await _guardarProductosEnCacheEnCasoDeError(emit);

      emit(EscanerError('Error al cargar ubicaciones'));
    }
  }

  /// Procesa un código de barras escaneado o ingresado manualmente
  /// Crea un objeto [ProductoEscaneado] y lo agrega a la lista
  /// @param [event] Evento con el código escaneado
  /// @param [emit] Emisor para cambiar el estado
  Future<void> _procesarCodigoDeBarras(
    SubmitCodeEvent event,
    Emitter<EscanerState> emit,
  ) async {
    try {
      final code = event.code.trim();
      if (code.isEmpty) {
        emit(EscanerError("El código de barras no puede estar vacío"));
        return;
      }

      final ProductoEscaneado nuevoProducto = ProductoEscaneado(code);

      if (productosEscaneados.any(
        (p) => p.serialnumber == nuevoProducto.serialnumber,
      )) {
        emit(ProductoEscaneadoExistenteState(nuevoProducto));
        return;
      }

      final productosPendientes =
          await ProductoLocalStorage.obtenerProductosPendientes();
      if (productosPendientes.any(
        (p) => p.serialnumber == nuevoProducto.serialnumber,
      )) {
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
      await _guardarProductosEnCacheEnCasoDeError(emit);

      emit( 
        EscanerError("Error al procesar el código de barras"),
      );
    }
  }

  /// Maneja la selección de un hospital
  /// @param [event] Evento con el hospital seleccionado
  /// @param [emit] Emisor para cambiar el estado
  Future<void> elegirHospitales(
    ChooseStoreEvent event,
    Emitter<EscanerState> emit,
  ) async {
    hospitalSeleccionado = event.hospital;
    emit(HospitalSeleccionadoState(event.hospital));

    if (hayProductosPendientes && productosEscaneados.isNotEmpty) {
      int locationId = locationSeleccionada?.id ?? 0;
      await ProductoLocalStorage.guardarProductosPendientes(
        productosEscaneados,
        hospitalSeleccionado!.id,
        locationId,
      );
    }

    add(LoadLocations());
  }

  /// Maneja la selección de una ubicación dentro del hospital
  /// @param [event] Evento con la ubicación seleccionada
  /// @param [emit] Emisor para cambiar el estado
  Future<void> chooseLocation(
    ChooseLocationEvent event,
    Emitter<EscanerState> emit,
  ) async {
    locationSeleccionada = event.location;
    emit(LocationSeleccionadaState(event.location));

    if (hayProductosPendientes &&
        productosEscaneados.isNotEmpty &&
        hospitalSeleccionado != null) {
      await ProductoLocalStorage.guardarProductosPendientes(
        productosEscaneados,
        hospitalSeleccionado!.id,
        locationSeleccionada!.id,
      );
    }

    if (hospitalSeleccionado != null) {
      emit(HospitalSeleccionadoState(hospitalSeleccionado!));
    }
  }

  /// Guarda los productos escaneados en el servidor o localmente
  /// Verifica la conexión y el estado de selección de hospital/ubicación
  /// @param [event] Evento para guardar productos
  /// @param [emit] Emisor para cambiar el estado
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

        emit(
          GuardarOfflineSuccess(
            message:
                "No hay conexión a Internet. Los productos se han guardado localmente.",
          ),
        );
        return;
      }

      await _guardarProductosEnServidor(emit);
    } catch (e) {
      await _guardarProductosEnCacheEnCasoDeError(emit);

      emit(EscanerError("Error general al guardar productos"));
    }
  }

  /// Elimina un producto de la lista de productos escaneados
  /// @param [event] Evento con el producto a eliminar
  /// @param [emit] Emisor para cambiar el estado
  Future<void> _eliminarProducto(
    EliminarProductoEvent event,
    Emitter<EscanerState> emit,
  ) async {
    productosEscaneados.removeWhere(
      (p) => p.serialnumber == event.producto.serialnumber,
    );
    _eliminarProductoPorserialnumber(event.producto.serialnumber);

    ProductoLocalStorage.eliminarProductoPendiente(event.producto.serialnumber);

    emit(
      ProductosListadosState(
        productosEscaneados,
        hayProductosPendientes: hayProductosPendientes,
      ),
    );
  }

  /// Carga los productos pendientes de sincronización almacenados localmente
  /// @param [event] Evento para cargar productos pendientes
  /// @param [emit] Emisor para cambiar el estado
  Future<void> _cargarProductosPendientes(
    CargarProductosPendientesEvent event,
    Emitter<EscanerState> emit,
  ) async {
    try {
      final productosPendientes =
          await ProductoLocalStorage.obtenerProductosPendientes();

      if (productosPendientes.isNotEmpty) {
        productosEscaneados = List.from(productosPendientes);
        hayProductosPendientes = true;

        emit(
          ProductosListadosState(
            productosEscaneados,
            hayProductosPendientes: hayProductosPendientes,
          ),
        );

        final hospitalId =
            await ProductoLocalStorage.obtenerHospitalPendiente();
        final locationId =
            await ProductoLocalStorage.obtenerLocationPendiente();

        if (hospitalId != null) {
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

            if (hospitalSeleccionado != null) {
              emit(HospitalSeleccionadoState(hospitalSeleccionado!));

              if (locationId != null) {
                try {
                  List<Location> locations = await locationRepository
                      .getLocationsForAStore(hospitalSeleccionado!.id)
                      .then((value) => value.data);

                  for (var location in locations) {
                    if (location.id == locationId) {
                      locationSeleccionada = location;
                      break;
                    }
                  }

                  if (locationSeleccionada != null) {
                    emit(LocationSeleccionadaState(locationSeleccionada!));
                  }
                } catch (e) {
                  // Ignorar errores al cargar ubicación
                }
              }
            }
          } catch (e) {
            // Ignorar errores al cargar hospital
          }
        }
      }
    } catch (e) {
      emit(EscanerError("Error al cargar productos pendientes"));
    }
  }

  /// Valida si hay un hospital seleccionado
  /// @param [emit] Emisor para cambiar el estado en caso de error
  /// @return [bool] true si hay un hospital seleccionado, false en caso contrario
  Future<bool> _validarHospitalSeleccionado(Emitter<EscanerState> emit) async {
    if (hospitalSeleccionado == null) {
      emit(EscanerError("Debe seleccionar un hospital primero"));
      return false;
    }
    return true;
  }

  /// Valida si hay productos escaneados para guardar
  /// @param [emit] Emisor para cambiar el estado en caso de error
  /// @return [bool] true si hay productos escaneados, false en caso contrario
  Future<bool> _validarProductosEscaneados(Emitter<EscanerState> emit) async {
    if (productosEscaneados.isEmpty) {
      emit(EscanerError("No hay productos escaneados para guardar"));
      return false;
    }
    return true;
  }

  /// Verifica si hay conexión a Internet
  /// @return [bool] true si hay conexión, false en caso contrario
  Future<bool> _verificarConexion() async {
    try {
      return await ConnectivityService.hayConexionInternet();
    } catch (e) {
      return false;
    }
  }

  /// Guarda los productos escaneados localmente cuando no hay conexión
  /// @param [emit] Emisor para cambiar el estado
  Future<void> _guardarProductosLocal(Emitter<EscanerState> emit) async {
    try {
      if (hospitalSeleccionado == null) {
        emit(
          EscanerError(
            "Debes seleccionar un almacén antes de guardar los productos",
          ),
        );
        return;
      }

      int? locationId;
      if (locationSeleccionada != null) {
        locationId = locationSeleccionada!.id;
      }

      await ProductoLocalStorage.guardarProductosPendientes(
        productosEscaneados,
        hospitalSeleccionado!.id,
        locationId,
      );

      hayProductosPendientes = true;
      emit(ProductosGuardadosLocalState(productosEscaneados));
    } catch (e) {
      emit(EscanerError("Error al guardar productos"));
    }
  }

  /// Comprueba si hay productos pendientes de sincronización
  /// @param [emit] Emisor para cambiar el estado
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
            (p) => p.serialnumber == productoPendiente.serialnumber,
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
          "Error al comprobar productos pendientes",
        ),
      );
    }
  }

  /// Envía los productos escaneados al servidor
  /// @param [emit] Emisor para cambiar el estado
  Future<void> _guardarProductosEnServidor(Emitter<EscanerState> emit) async {
    try {
      List<ProductoEscaneado> productosCopia = List.from(productosEscaneados);

      try {
        var response = await productoRepository.enviarProductosEscaneados(
          hospitalSeleccionado!.id,
          locationSeleccionada!.id,
          productosEscaneados,
        );

        productosEscaneados.clear();

        if (response.success) {
          final responseData = response.data as Map<String, dynamic>;
          final foundProducts = responseData['found'] as List<dynamic>;
          final missingSerials = responseData['missing'] as List<String>;

          List<Producto> productos = List<Producto>.from(
            foundProducts.map((item) => Producto.fromApiMap(item)),
          );

          await _guardarProductosEscaneadosLocalmente(productos);

          try {
            await alarmUtils.loadAlarmsForProducts(productos);
            await alarmUtils.getGeneralAlarms();
          } catch (e) {
            emit(
              EscanerError(
                "Error al cargar colores de alarmas",
              ),
            );
          }

          emit(GuardarSuccess(productos: productos, mensaje: response.message));
          emit(
            ProductosRecibidosState(
              productos,
              missingSerials,
              mensaje: response.message,
            ),
          );
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
          locationSeleccionada!.id,
        );

        productosEscaneados.clear();
        emit(GuardarOfflineSuccess());
      }
    } catch (e) {
      emit(EscanerError("Error general al guardar productos"));
    }
  }

  /// Elimina un producto por su número de serie
  /// @param [serialnumber] Número de serie del producto a eliminar
  Future<void> _eliminarProductoPorserialnumber(String serialnumber) async {
    try {
      final response = await apiClient.getAll('/productos', null);

      if (response is List) {
        for (var item in response) {
          if (item is Map<String, dynamic> &&
              item['serialnumber'] != null &&
              item['serialnumber'] == serialnumber &&
              item['numproducto'] != null) {
            final String numProducto = item['numproducto'];
            await ProductoLocalStorage.eliminarProductoEscaneado(numProducto);
            break;
          }
        }
      }
    } catch (e) {
      throw Exception(
        'Error al eliminar producto por serialnumber',
      );
    }
  }

  /// Guarda los IDs de los productos escaneados en el almacenamiento local
  /// @param [productos] Lista de productos a guardar
  Future<void> _guardarProductosEscaneadosLocalmente(
    List<Producto> productos,
  ) async {
    try {
      final List<String> productosIds =
          productos.map((p) => p.productcode).toList();

      for (final id in productosIds) {
        await ProductoLocalStorage.agregarProductoEscaneado(id);
      }
    } catch (e) {
      throw Exception(
        'Error al guardar productos escaneados localmente',
      );
    }
  }

  /// Reinicia las selecciones de hospital y ubicación
  /// @param [event] Evento para reiniciar selecciones
  /// @param [emit] Emisor para cambiar el estado
  void resetSelections(ResetSelectionsEvent event, Emitter<EscanerState> emit) {
    hospitalSeleccionado = null;
    locationSeleccionada = null;
    emit(SelectionsResetState());
  }
}
