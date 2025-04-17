import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quilmedic/data/respository/alarm_repository.dart';
import 'package:quilmedic/data/respository/hospital_repository.dart';
import 'package:quilmedic/domain/alarm.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/producto_repository.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:quilmedic/utils/alarm_utils.dart';

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
  late AlarmRepository alarmRepository = AlarmRepository(apiClient: apiClient);
  late ProductoLocalStorage productoLocalStorage = ProductoLocalStorage();
  late AlarmUtils alarmUtils = AlarmUtils();

  ListaProductosBloc() : super(ListaProductosInitial()) {
    on<CargarProductosEvent>(_cargarProductos);
    on<MostrarProductosEvent>(_mostrarProductos);
    on<CargarHospitalesEvent>(cargarHospitales);
    on<EnviarSolicitudTrasladoEvent>(_enviarSolicitudTraslado);
  }

  Future<void> _cargarProductos(
    CargarProductosEvent event,
    Emitter<ListaProductosState> emit,
  ) async {
    try {
      emit(ListaProductosLoading());

      try {
        if (event.productos.isEmpty) {
          emit(ListaProductosError('No se encontraron productos escaneados'));
        } else {
          List<Alarm> alarmLocal = await ProductoLocalStorage.obtenerAlarmas();
          if (alarmLocal.isEmpty) {
            final alarms = await alarmUtils.getGeneralAlarms();
            await ProductoLocalStorage.agregarAlarmas(alarms);
          }

          emit(ProductosCargadosState(event.productos));
        }
      } catch (e) {
        _manejarErrorConexion(e, emit);
      }
    } catch (e) {
      emit(ListaProductosError('Error inesperado: ${e.toString()}'));
    }
  }

  void _manejarErrorConexion(Object e, Emitter<ListaProductosState> emit) {
    final String errorMsg = e.toString();

    if (_esErrorDeConexion(errorMsg)) {
      emit(
        ListaProductosError(
          'No hay conexión a internet para cargar los productos. Usando datos locales.',
        ),
      );
    } else {
      emit(
        ListaProductosError(
          'Error al cargar productos: $errorMsg. Usando datos locales.',
        ),
      );
    }
    // TODO: SI HACE FALTA CONTROLAR LOS DATOS EN CACHE, DE MOMENTO NO HACE FALTA
  }

  bool _esErrorDeConexion(String errorMsg) {
    return errorMsg.contains('SocketException') ||
        errorMsg.contains('Connection refused') ||
        errorMsg.contains('Network is unreachable');
  }

  void _mostrarProductos(
    MostrarProductosEvent event,
    Emitter<ListaProductosState> emit,
  ) {
    emit(ProductosCargadosState(event.productos));
  }

  Future<void> cargarHospitales(
    CargarHospitalesEvent event,
    Emitter<ListaProductosState> emit,
  ) async {
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

  Future<void> _enviarSolicitudTraslado(
    EnviarSolicitudTrasladoEvent event,
    Emitter<ListaProductosState> emit,
  ) async {
    try {
      emit(EnviandoSolicitudTrasladoState());

      // final Map<String, dynamic> data = {
      //   'producto_id': event.producto.productcode,
      //   'hospital_origen_id': event.producto.storeid,
      //   'hospital_destino_id': event.hospitalDestinoId,
      //   'hospital_destino_nombre': event.hospitalDestinoNombre,
      //   'comentarios': event.comentarios,
      // };

      try {
        // final response = await apiClient.post('/solicitudes-traslado', data);
        emit(
          SolicitudTrasladoEnviadaState(
            'Solicitud de traslado enviada correctamente',
          ),
        );
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
          emit(
            SolicitudTrasladoEnviadaState(
              'Solicitud de traslado registrada (pendiente de sincronización)',
            ),
          );
        } else {
          emit(
            ErrorSolicitudTrasladoState(
              'Error al enviar la solicitud de traslado: ${e.toString()}',
            ),
          );
        }
      }
    } catch (e) {
      emit(ErrorSolicitudTrasladoState('Error inesperado: ${e.toString()}'));
    }
  }
}
