import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/data/respository/hospital_repository.dart';
import 'package:quilmedic/data/respository/producto_repository.dart';
import 'package:quilmedic/data/json/api_client.dart';

part 'escaner_event.dart';
part 'escaner_state.dart';

class EscanerBloc extends Bloc<EscanerEvent, EscanerState> {
  List<ProductoEscaneado> productosEscaneados = [];
  Hospital? hospitalSeleccionado;

  final ApiClient apiClient = ApiClient();
  late HospitalRepository hospitalRepository = HospitalRepository(apiClient: apiClient);
  late ProductoRepository productoRepository = ProductoRepository(apiClient: apiClient);

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
      // List<Hospital> hospitales = [
      //   Hospital(1, 'Hospital 1'),
      //   Hospital(2, 'Hospital 2'),
      //   Hospital(3, 'Hospital 3'),
      //   Hospital(4, 'Hospital 4'),
      // ];

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

      if (!RegExp(r'^\d+$').hasMatch(barcode)) {
        emit(
          EscanerError("Código de barras inválido: Debe contener solo números"),
        );
        return;
      }

      final int barcodeNumber = int.parse(barcode);
      final int timestamp = DateTime.now().millisecondsSinceEpoch;

      final ProductoEscaneado nuevoProducto = ProductoEscaneado(
        timestamp,
        barcodeNumber,
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

  guardarProductos(GuardarProductosEvent event, Emitter<EscanerState> emit) async {
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
      
      // Enviar los productos escaneados al servidor
      await productoRepository.enviarProductosEscaneados(
        hospitalSeleccionado!.codigo,
        productosEscaneados,
      );
      
      // Limpiar la lista de productos escaneados después de guardarlos
      productosEscaneados.clear();
      
      emit(GuardarSuccess());
      emit(ProductosListadosState(productosEscaneados));
    } catch (e) {
      emit(EscanerError("Error al guardar productos: ${e.toString()}"));
    }
  }
}
