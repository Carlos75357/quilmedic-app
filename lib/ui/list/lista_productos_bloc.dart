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

/// [Bloc] que gestiona el estado de la lista de productos
/// Maneja eventos relacionados con la carga de productos, hospitales y solicitudes de traslado
class ListaProductosBloc
    extends Bloc<ListaProductosEvent, ListaProductosState> {
  /// Cliente API para realizar peticiones al servidor
  final ApiClient apiClient = ApiClient();
  /// Repositorio para gestionar operaciones con productos
  late ProductoRepository productoRepository = ProductoRepository(
    apiClient: apiClient,
  );
  /// Repositorio para gestionar operaciones con hospitales
  late HospitalRepository hospitalRepository = HospitalRepository(
    apiClient: apiClient,
  );
  /// Repositorio para gestionar operaciones de traslado de productos
  late TransferRepository transferRepository = TransferRepository(
    apiClient: apiClient,
  );
  /// Repositorio para gestionar operaciones con alarmas
  late AlarmRepository alarmRepository = AlarmRepository(apiClient: apiClient);
  /// Servicio para almacenamiento local de productos
  late ProductoLocalStorage productoLocalStorage = ProductoLocalStorage();
  /// Utilidad para gestionar alarmas de productos
  late AlarmUtils alarmUtils = AlarmUtils();

  /// Constructor del ListaProductosBloc
  /// Registra los manejadores de eventos
  ListaProductosBloc() : super(ListaProductosInitial()) {
    on<CargarProductosEvent>(_cargarProductos);
    on<MostrarProductosEvent>(_mostrarProductos);
    on<CargarHospitalesEvent>(cargarHospitales);
    on<EnviarSolicitudTrasladoEvent>(_enviarSolicitudTraslado);
  }

  /// Carga los productos recibidos y las alarmas asociadas
  /// @param [event] Evento con los productos a cargar
  /// @param [emit] Emisor para cambiar el estado
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
      emit(ListaProductosError('Error inesperado al cargar los productos'));
    }
  }

  /// Maneja los errores de conexión al cargar productos
  /// Emite estados de error apropiados según el tipo de error
  /// @param [e] Excepción que ocurrió
  /// @param [emit] Emisor para cambiar el estado
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
          'Error al cargar productos. Usando datos locales.',
        ),
      );
    }
    // TODO: SI HACE FALTA CONTROLAR LOS DATOS EN CACHE, DE MOMENTO NO HACE FALTA
  }

  /// Determina si un mensaje de error indica un problema de conexión
  /// @param [errorMsg] Mensaje de error a analizar
  /// @return [bool] true si es un error de conexión, false en caso contrario
  bool _esErrorDeConexion(String errorMsg) {
    return errorMsg.contains('SocketException') ||
        errorMsg.contains('Connection refused') ||
        errorMsg.contains('Network is unreachable');
  }

  /// Muestra la lista de productos recibidos
  /// @param [event] Evento con los productos a mostrar
  /// @param [emit] Emisor para cambiar el estado
  void _mostrarProductos(
    MostrarProductosEvent event,
    Emitter<ListaProductosState> emit,
  ) {
    emit(ProductosCargadosState(event.productos));
  }

  /// Carga la lista de hospitales desde el servidor
  /// @param [event] Evento para cargar hospitales
  /// @param [emit] Emisor para cambiar el estado
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

  /// Envía una solicitud de traslado de productos entre hospitales
  /// @param [event] Evento con los datos de la solicitud
  /// @param [emit] Emisor para cambiar el estado
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
              'Error al enviar la solicitud de traslado',
            ),
          );
        }
      }
    } catch (e) {
      emit(ErrorSolicitudTrasladoState('Error inesperado'));
    }
  }
}
