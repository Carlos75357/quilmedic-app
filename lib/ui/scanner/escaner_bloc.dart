import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../domain/producto_scaneado.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'dart:convert';

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

      // Intentar decodificar el QR como JSON
      // Formato esperado: {"id": 123, "nombre": "Producto X", "serie": 456}
      final Map<String, dynamic>? qrData;
      try {
        qrData = jsonDecode(event.qrCode);
      } catch (_) {
        emit(EscanerError("QR inválido: No es un JSON válido"));
        return;
      }

      // Verificar si el QR contiene los datos necesarios
      if (!qrData!.containsKey('id') || !qrData.containsKey('nombre') || !qrData.containsKey('serie')) {
        emit(EscanerError("QR inválido: No contiene la información necesaria de un producto"));
        return;
      }
      
      final ProductoScaneado nuevoProducto = ProductoScaneado(
        qrData['id'],
        qrData['nombre'],
        qrData['serie'],
      );
      
      // Verificar si el producto ya existe en la lista
      final productoExistente = productosEscaneados.any(
        (p) => p.id == nuevoProducto.id && p.serie == nuevoProducto.serie
      );
      
      if (productoExistente) {
        emit(ProductoScaneadoExistenteState(nuevoProducto));
      } else {
        // Guardar el producto en la lista (simulando base de datos)
        productosEscaneados.add(nuevoProducto);
        emit(ProductoScaneadoGuardadoState(nuevoProducto));
      }
      
      // Emitir estado con la lista actualizada de productos
      emit(ProductosListadosState(productosEscaneados));
    } catch (e) {
      emit(EscanerError("Error al procesar el QR: ${e.toString()}"));
    }
  }

  listarProductos(VerListadoProductosEscaneadosEvent event, Emitter<EscanerState> emit) {
    emit(ProductosListadosState(productosEscaneados));
  }

  elegirHospitales(ElegirHospitalEvent event, Emitter<EscanerState> emit) {
    hospitalSeleccionado = event.hospital;
    emit(EscanerSuccess());
  }

  guardarProductos(GuardarProductosEvent event, Emitter<EscanerState> emit) {
    emit(GuardarSuccess());
  }
}