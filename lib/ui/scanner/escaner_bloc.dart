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
    on<QrCodeScannedEvent>(_procesarCodigoDeBarras);
    on<GuardarProductosEvent>(guardarProductos);
    on<GuardarProductosForzadoEvent>(_guardarProductosForzado);
    on<EliminarProductoEvent>(_eliminarProducto);
    on<SincronizarProductosPendientesEvent>(_sincronizarProductosPendientes);
  }

  cargarHospitales(LoadHospitales event, Emitter<EscanerState> emit) async {
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

  void _procesarCodigoDeBarras(
    QrCodeScannedEvent event,
    Emitter<EscanerState> emit,
  ) async {
    try {
      if (hospitalSeleccionado == null) {
        emit(EscanerError("Debe seleccionar un hospital primero"));
        return;
      }

      final String barcode = event.qrCode.trim();

      if (barcode.isEmpty) {
        emit(EscanerError("Código de barras inválido: No puede estar vacío"));
        return;
      }

      final int timestamp = DateTime.now().millisecondsSinceEpoch;

      final ProductoEscaneado nuevoProducto = ProductoEscaneado(
        timestamp,
        barcode,
      );

      final productoExistenteActual = productosEscaneados.any(
        (p) => p.serie == nuevoProducto.serie,
      );

      if (productoExistenteActual) {
        emit(ProductoEscaneadoExistenteState(nuevoProducto));
        return;
      }

      final productosPendientes =
          await ProductoLocalStorage.obtenerProductosPendientes();
      final productoExistentePendiente = productosPendientes.any(
        (p) => p.serie == nuevoProducto.serie,
      );

      if (productoExistentePendiente) {
        emit(ProductoEscaneadoExistenteState(nuevoProducto));
        return;
      }

      productosEscaneados.add(nuevoProducto);
      emit(ProductoEscaneadoGuardadoState(nuevoProducto));
      emit(ProductosListadosState(productosEscaneados));
    } catch (e) {
      emit(
        EscanerError("Error al procesar el código de barras: ${e.toString()}"),
      );
    }
  }

  elegirHospitales(ElegirHospitalEvent event, Emitter<EscanerState> emit) {
    hospitalSeleccionado = event.hospital;
    emit(EscanerSuccess());
    emit(ProductosListadosState(productosEscaneados));
  }

  guardarProductos(
    GuardarProductosEvent event,
    Emitter<EscanerState> emit,
  ) async {
    try {
      if (hospitalSeleccionado == null) {
        emit(EscanerError("Debe seleccionar un hospital primero"));
        return;
      }

      emit(EscanerLoading());

      List<ProductoEscaneado> productosPendientes = [];
      String? hospitalIdPendiente;

      try {
        productosPendientes =
            await ProductoLocalStorage.obtenerProductosPendientes();
        hospitalIdPendiente =
            await ProductoLocalStorage.obtenerHospitalPendiente();
      } catch (e) {
        emit(EscanerError(e.toString()));
        return;
      }

      if (productosPendientes.isNotEmpty &&
          hospitalIdPendiente == hospitalSeleccionado!.id) {
        for (var productoPendiente in productosPendientes) {
          bool yaExiste = productosEscaneados.any(
            (p) => p.serie == productoPendiente.serie,
          );
          if (!yaExiste) {
            productosEscaneados.add(productoPendiente);
          }
        }

        await ProductoLocalStorage.limpiarProductosPendientes();

        emit(ProductosListadosState(productosEscaneados));
      }

      if (productosEscaneados.isEmpty) {
        emit(EscanerError("No hay productos escaneados para guardar"));
        return;
      }

      bool hayConexion = false;
      try {
        hayConexion = await ConnectivityService.hayConexionInternet();
      } catch (e) {
        try {
          await ProductoLocalStorage.guardarProductosPendientes(
            productosEscaneados,
            hospitalSeleccionado!.id,
          );

          productosEscaneados.clear();

          emit(GuardarOfflineSuccess());
        } catch (storageError) {
          emit(
            EscanerError(
              "Error al guardar productos localmente: ${storageError.toString()}",
            ),
          );
        }
        return;
      }

      if (!hayConexion) {
        try {
          await ProductoLocalStorage.guardarProductosPendientes(
            productosEscaneados,
            hospitalSeleccionado!.id,
          );

          productosEscaneados.clear();

          emit(GuardarOfflineSuccess());
        } catch (storageError) {
          emit(
            EscanerError(
              "Error al guardar productos localmente: ${storageError.toString()}",
            ),
          );
        }
        return;
      }

      try {
        await Future.delayed(const Duration(milliseconds: 300));

        var response = await productoRepository.enviarProductosEscaneados(
          hospitalSeleccionado!.id,
          productosEscaneados,
        );

        productosEscaneados.clear();

        if (response.success) {
          List<Producto> productos = [];
          productos = List<Producto>.from(
            response.data.map((item) => _convertirMapaAProducto(item)),
          );

          await _guardarProductosEscaneadosLocalmente(productos);

          emit(GuardarSuccess(productos: productos));
          emit(ProductosRecibidosState(productos));
        } else {
          List<ProductoEscaneado> productosCopia = List.from(
            productosEscaneados,
          );
          productosEscaneados.clear();

          await ProductoLocalStorage.guardarProductosPendientes(
            productosCopia,
            hospitalSeleccionado!.id,
          );

          emit(
            EscanerError(
              "Error al guardar productos en el servidor. Se han guardado localmente: ${response.message}",
            ),
          );
        }
      } catch (e) {
        try {
          await ProductoLocalStorage.guardarProductosPendientes(
            productosEscaneados,
            hospitalSeleccionado!.id,
          );

          productosEscaneados.clear();

          emit(GuardarOfflineSuccess());
        } catch (storageError) {
          emit(
            EscanerError(
              "Error al guardar productos: ${e.toString()}. Error al guardar localmente: ${storageError.toString()}",
            ),
          );
        }
      }
    } catch (e) {
      emit(EscanerError("Error general al guardar productos: ${e.toString()}"));
    }
  }

  void _guardarProductosForzado(
    GuardarProductosForzadoEvent event,
    Emitter<EscanerState> emit,
  ) async {
    try {
      if (hospitalSeleccionado == null) {
        emit(EscanerError("Debe seleccionar un hospital primero"));
        return;
      }

      if (productosEscaneados.isEmpty) {
        emit(EscanerError("No hay productos escaneados para guardar"));
        return;
      }

      emit(EscanerLoading());

      var response = await productoRepository.enviarProductosEscaneados(
        hospitalSeleccionado!.id,
        productosEscaneados,
      );

      productosEscaneados.clear();

      if (response.success) {
        List<Producto> productos = [];
        productos = List<Producto>.from(
          response.data.map((item) => _convertirMapaAProducto(item)),
        );

        await _guardarProductosEscaneadosLocalmente(productos);

        emit(GuardarSuccess(productos: productos));

        emit(ProductosRecibidosState(productos));
      } else {
        emit(
          EscanerError("No se encontraron productos con las series escaneadas"),
        );
      }
    } catch (e) {
      emit(EscanerError("Error al guardar productos: ${e.toString()}"));
    }
  }

  void _eliminarProducto(
    EliminarProductoEvent event,
    Emitter<EscanerState> emit,
  ) {
    productosEscaneados.removeWhere((p) => p.id == event.producto.id);

    _eliminarProductoPorSerie(event.producto.serie);

    emit(ProductosListadosState(productosEscaneados));
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
            final int numProducto = item['numproducto'];
            await ProductoLocalStorage.eliminarProductoEscaneado(numProducto);
            break;
          }
        }
      }
    } catch (e) {
      throw Exception('Error al eliminar producto por serie: ${e.toString()}');
    }
  }

  Producto _convertirMapaAProducto(Map<String, dynamic> mapa) {
    try {
      return Producto(
        mapa['numerodeproducto'] ?? 0,
        mapa['descripcion'],
        mapa['codigoalmacen'] ?? 0,
        mapa['numerolote'] ?? 0,
        mapa['serie'] ?? '',
        mapa['fechacaducidad'] != null
            ? DateTime.parse(mapa['fechacaducidad'])
            : DateTime.now(),
        mapa['cantidad'] ?? 0,
      );
    } catch (e) {
      return Producto(
        "0",
        'Error al procesar producto',
        "0",
        0,
        "",
        DateTime.now(),
        0,
      );
    }
  }

  navegarAListaProductos(BuildContext context, List<Producto> productos) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ListaProductosPage(
              productos: productos,
              hospitalId: hospitalSeleccionado?.id ?? "0",
            ),
      ),
    );
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

      bool hayConexion = false;
      try {
        hayConexion = await ConnectivityService.hayConexionInternet();
      } catch (e) {
        emit(
          EscanerError("Error al verificar la conectividad: ${e.toString()}"),
        );
        return;
      }

      if (!hayConexion) {
        emit(EscanerError("No hay conexión a internet para sincronizar"));
        return;
      }

      emit(EscanerLoading());

      List<ProductoEscaneado> productosPendientes = [];
      String? hospitalId;

      try {
        productosPendientes =
            await ProductoLocalStorage.obtenerProductosPendientes();
        hospitalId = await ProductoLocalStorage.obtenerHospitalPendiente();
      } catch (e) {
        emit(
          EscanerError(
            "Error al obtener productos pendientes: ${e.toString()}",
          ),
        );
        return;
      }

      if (productosPendientes.isEmpty || hospitalId == null) {
        await ProductoLocalStorage.limpiarProductosPendientes();
        emit(SinProductosPendientesState());
        return;
      }

      await Future.delayed(const Duration(milliseconds: 300));

      try {
        var response = await productoRepository.enviarProductosEscaneados(
          hospitalId,
          productosPendientes,
        );

        if (response.success) {
          await ProductoLocalStorage.limpiarProductosPendientes();

          List<Producto> productos = [];
          productos = List<Producto>.from(
            response.data.map((item) => _convertirMapaAProducto(item)),
          );

          await _guardarProductosEscaneadosLocalmente(productos);

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
              emit(
                EscanerError("Error al obtener hospitales: ${e.toString()}"),
              );
            }
          }

          productosEscaneados.clear();

          emit(SincronizacionCompletaState(productos));
          emit(GuardarSuccess(productos: productos));
          emit(ProductosRecibidosState(productos));
        } else {
          emit(
            EscanerError(
              "Error al sincronizar productos pendientes: ${response.message}",
            ),
          );
        }
      } catch (e) {
        emit(EscanerError("Error durante la sincronización: ${e.toString()}"));
      }
    } catch (e) {
      emit(
        EscanerError(
          "Error general durante la sincronización: ${e.toString()}",
        ),
      );
    }
  }
}
