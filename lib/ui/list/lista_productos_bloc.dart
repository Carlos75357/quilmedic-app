import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quilmedic/data/respository/alarm_repository.dart';
import 'package:quilmedic/data/respository/hospital_repository.dart';
import 'package:quilmedic/data/respository/transfer_repository.dart';
import 'package:quilmedic/domain/alarm.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/producto_repository.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:quilmedic/domain/transfer_request.dart';
import 'package:quilmedic/utils/alarm_utils.dart';
import 'package:quilmedic/services/auth_service.dart';

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
  late TransferRepository transferRepository = TransferRepository(
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

      final authService = AuthService();
      final user = await authService.getCurrentUser();
      final int userId = user?.id ?? 0;

      try {
        final response = await transferRepository.transferProducts(
          TransferRequest(
            email: event.email,
            fromStoreId:
                event.productos.isNotEmpty
                    ? event.productos.first.locationid
                    : 0,
            toStoreId: event.hospitalDestinoId,
            userId: userId,
            products: event.productos.map((p) => p.serialnumber).toList(),
          ),
        );

        if (response.success) {
          emit(
            SolicitudTrasladoEnviadaState(
              'Solicitud de traslado enviada correctamente a ${event.hospitalDestinoNombre}',
            ),
          );
        } else {
          emit(
            ErrorSolicitudTrasladoState(
              'Error al enviar la solicitud de traslado: Respuesta vacía del servidor',
            ),
          );
        }
      } catch (e) {
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Connection refused') ||
            e.toString().contains('Network is unreachable')) {
          emit(
            SolicitudTrasladoEnviadaState(
              'Solicitud de traslado registrada (pendiente de sincronización)',
            ),
          );

          // TODO: Guardar la solicitud localmente para reintento posterior
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
