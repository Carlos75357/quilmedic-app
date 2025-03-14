import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/data/respository/hospital_repository.dart';
import 'package:quilmedic/data/respository/producto_repository.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/ui/list/lista_productos_page.dart';

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
    on<EscanearCodigoEvent>(escanearCodigo);
    on<VerListadoProductosEscaneadosEvent>(listarProductos);
    on<ElegirHospitalEvent>(elegirHospitales);
    on<QrCodeScannedEvent>(_procesarCodigoDeBarras);
    on<GuardarProductosEvent>(guardarProductos);
  }

  cargarHospitales(LoadHospitales event, Emitter<EscanerState> emit) async {
    emit(EscanerLoading());

    try {
      List<Hospital> hospitales = await hospitalRepository.getAllHospitals();

      emit(HospitalesCargados(hospitales));
    } catch (e) {
      emit(EscanerError(e.toString()));
    }
  }

  escanearCodigo(EscanearCodigoEvent event, Emitter<EscanerState> emit) {
    if (hospitalSeleccionado == null) {
      emit(EscanerError("Debe seleccionar un hospital primero"));
      return;
    }
    emit(EscanearCodigosState());
  }

  void _procesarCodigoDeBarras(
    QrCodeScannedEvent event,
    Emitter<EscanerState> emit,
  ) {
    try {
      if (hospitalSeleccionado == null) {
        emit(EscanerError("Debe seleccionar un hospital primero"));
        return;
      }

      final String barcode = event.qrCode.trim();

      // Validar que el código de barras no esté vacío
      if (barcode.isEmpty) {
        emit(EscanerError("Código de barras inválido: No puede estar vacío"));
        return;
      }

      final int timestamp = DateTime.now().millisecondsSinceEpoch;

      final ProductoEscaneado nuevoProducto = ProductoEscaneado(
        timestamp,
        barcode,
      );

      final productoExistente = productosEscaneados.any(
        (p) => p.serie == nuevoProducto.serie,
      );

      if (productoExistente) {
        emit(ProductoEscaneadoExistenteState(nuevoProducto));
      } else {
        productosEscaneados.add(nuevoProducto);
        emit(ProductoEscaneadoGuardadoState(nuevoProducto));
        emit(ProductosListadosState(productosEscaneados));
      }
    } catch (e) {
      emit(
        EscanerError("Error al procesar el código de barras: ${e.toString()}"),
      );
    }
  }

  listarProductos(
    VerListadoProductosEscaneadosEvent event,
    Emitter<EscanerState> emit,
  ) {
    emit(ProductosListadosState(productosEscaneados));
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

      if (response.isNotEmpty) {
        List<Producto> productos = [];
        productos = response.map((item) => _convertirMapaAProducto(item)).toList();
      
        emit(GuardarSuccess(productos: productos));

        emit(ProductosRecibidosState(productos));
      } else {
        emit(EscanerError("No se encontraron productos con las series escaneadas"));
      }
    } catch (e) {
      emit(EscanerError("Error al guardar productos: ${e.toString()}"));
    }
  }

  Producto _convertirMapaAProducto(Map<String, dynamic> mapa) {
    try {
      return Producto(
        mapa['numproducto'] ?? 0,
        mapa['descripcion'],
        mapa['codigoalmacen'] ?? 0,
        mapa['ubicacion'],
        mapa['numerolote'] ?? 0,
        mapa['descripcionlote'],
        mapa['numerodeproducto'] ?? 0,
        mapa['descripcion1'] ?? 'Sin descripción',
        mapa['codigoalmacen1'] ?? 0,
        mapa['serie'] ?? '',
        mapa['fechacaducidad'] != null
            ? DateTime.parse(mapa['fechacaducidad'])
            : DateTime.now(),
      );
    } catch (e) {
      return Producto(
        0,
        'Error al procesar producto',
        0,
        '',
        0,
        '',
        0,
        'Error de conversión',
        0,
        '',
        DateTime.now(),
      );
    }
  }

  navegarAListaProductos(BuildContext context, List<Producto> productos) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaProductosPage(productos: productos),
      ),
    );
  }
}
