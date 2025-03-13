import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../domain/producto_scaneado.dart';
import 'package:quilmedic/domain/hospital.dart';

part 'escaner_event.dart';
part 'escaner_state.dart';

class EscanerBloc extends Bloc<EscanerEvent, EscanerState> {
  // Lista temporal para simular una base de datos
  List<ProductoScaneado> productosEscaneados = [];
  Hospital? hospitalSeleccionado;

  EscanerBloc() : super(EscanerInitial()) {
    on<LoadHospitales>(cargarHospitales);
    on<EscanerarCodigoEvent>(escanearCodigo);
    on<VerListadoProductosEscaneadosEvent>(listarProductos);
    on<ElegirHospitalEvent>(elegirHospitales);
    on<QrCodeScannedEvent>(_processQrCode);
  }

  cargarHospitales(LoadHospitales event, Emitter<EscanerState> emit) {
    emit(EscanerLoading());

    List<Hospital> hospitales = [
      Hospital(1, 'Hospital 1'),
      Hospital(2, 'Hospital 2'),
      Hospital(3, 'Hospital 3'),
      Hospital(4, 'Hospital 4'),
    ];

    emit(HospitalesCargados(hospitales));
  }

  escanearCodigo(EscanerarCodigoEvent event, Emitter<EscanerState> emit) {
    if (hospitalSeleccionado == null) {
      emit(EscanerError("Debe seleccionar un hospital primero"));
      return;
    }
    emit(EscanearCodigosState());
  }

  void _processQrCode(QrCodeScannedEvent event, Emitter<EscanerState> emit) {
    try {
      if (hospitalSeleccionado == null) {
        emit(EscanerError("Debe seleccionar un hospital primero"));
        return;
      }

      final String barcode = event.qrCode.trim();
      
      if (!RegExp(r'^\d+$').hasMatch(barcode)) {
        emit(EscanerError("Código de barras inválido: Debe contener solo números"));
        return;
      }
      
      final int barcodeNumber = int.parse(barcode);
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final ProductoScaneado nuevoProducto = ProductoScaneado(
        timestamp,
        barcodeNumber,
      );
      
      final productoExistente = productosEscaneados.any(
        (p) => p.serie == nuevoProducto.serie
      );
      
      if (productoExistente) {
        emit(ProductoScaneadoExistenteState(nuevoProducto));
      } else {
        productosEscaneados.add(nuevoProducto);
        emit(ProductoScaneadoGuardadoState(nuevoProducto));
        // Emitimos el estado con la lista actualizada solo si se añadió un producto nuevo
        emit(ProductosListadosState(productosEscaneados));
      }
    } catch (e) {
      emit(EscanerError("Error al procesar el código de barras: ${e.toString()}"));
    }
  }

  listarProductos(VerListadoProductosEscaneadosEvent event, Emitter<EscanerState> emit) {
    emit(ProductosListadosState(productosEscaneados));
  }

  elegirHospitales(ElegirHospitalEvent event, Emitter<EscanerState> emit) {
    hospitalSeleccionado = event.hospital;
    emit(EscanerSuccess());
    // Emitir la lista de productos actualizada después de seleccionar hospital
    emit(ProductosListadosState(productosEscaneados));
  }

  guardarProductos(GuardarProductosEvent event, Emitter<EscanerState> emit) {
    emit(GuardarSuccess());
  }
}