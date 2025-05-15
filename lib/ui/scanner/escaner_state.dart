part of 'escaner_bloc.dart';

/// Clase base abstracta para todos los estados del escáner
/// Todos los estados posibles del EscanerBloc deben extender esta clase
@immutable
sealed class EscanerState {}

/// Estado inicial del escáner, antes de cualquier acción
final class EscanerInitial extends EscanerState {}

/// Estado de carga, indica que se está procesando alguna operación
final class EscanerLoading extends EscanerState {}

/// Estado de éxito genérico, indica que una operación se completó correctamente
final class EscanerSuccess extends EscanerState {}

/// Estado de error, indica que ocurrió un problema durante alguna operación
final class EscanerError extends EscanerState {
  /// Mensaje de error para mostrar al usuario
  final String message;

  /// Constructor que recibe el mensaje de error
  EscanerError(this.message);
}

/// Estado que indica que los hospitales se han cargado correctamente
final class HospitalesCargados extends EscanerState {
  /// Lista de hospitales cargados desde el servidor
  final List<Hospital> hospitales;

  /// Constructor que recibe la lista de hospitales
  HospitalesCargados(this.hospitales);
}

/// Estado que indica que las ubicaciones se han cargado correctamente
final class LocationsCargadas extends EscanerState {
  /// Lista de ubicaciones cargadas desde el servidor
  final List<Location> locations;

  /// Constructor que recibe la lista de ubicaciones
  LocationsCargadas(this.locations);
}

/// Estado que indica que se debe mostrar la interfaz para escanear códigos
final class EscanearCodigosState extends EscanerState {}

/// Estado que indica que el producto escaneado ya existe en la lista
final class ProductoEscaneadoExistenteState extends EscanerState {
  /// Producto escaneado que ya existe
  final ProductoEscaneado producto;

  /// Constructor que recibe el producto existente
  ProductoEscaneadoExistenteState(this.producto);
}

/// Estado que indica que un producto escaneado se ha guardado correctamente
final class ProductoEscaneadoGuardadoState extends EscanerState {
  /// Producto escaneado que se ha guardado
  final ProductoEscaneado producto;

  /// Constructor que recibe el producto guardado
  ProductoEscaneadoGuardadoState(this.producto);
}

/// Estado que indica que se debe mostrar la lista de productos escaneados
final class ProductosListadosState extends EscanerState {
  /// Lista de productos escaneados
  final List<ProductoEscaneado> productos;
  /// Indica si hay productos pendientes de sincronización
  final bool hayProductosPendientes;

  /// Constructor que recibe la lista de productos y opcionalmente si hay pendientes
  ProductosListadosState(this.productos, {this.hayProductosPendientes = false});
}

/// Estado que indica que los productos se han guardado correctamente en el servidor
class GuardarSuccess extends EscanerState {
  /// Lista de productos guardados y procesados por el servidor
  final List<Producto> productos;
  /// Mensaje opcional del servidor
  final String? mensaje;
  
  /// Constructor que recibe los productos guardados y opcionalmente un mensaje
  GuardarSuccess({required this.productos, this.mensaje});
}

/// Estado que indica que se han recibido productos del servidor
/// Incluye información sobre productos encontrados y no encontrados
class ProductosRecibidosState extends EscanerState {
  /// Lista de productos encontrados en el servidor
  final List<Producto> productos;
  /// Lista de códigos de productos que no se encontraron
  final List<String> productosNotFound;
  /// Mensaje opcional del servidor
  final String? mensaje;
  
  /// Constructor que recibe los productos, los no encontrados y opcionalmente un mensaje
  ProductosRecibidosState(this.productos, this.productosNotFound, {this.mensaje});
}

/// Estado que indica que los productos se han guardado localmente (modo offline)
class GuardarOfflineSuccess extends EscanerState {
  /// Mensaje informativo para el usuario
  final String message;
  
  /// Constructor con mensaje predeterminado sobre la sincronización
  GuardarOfflineSuccess({this.message = "Productos guardados localmente. Se sincronizarán automáticamente cuando haya conexión a internet. También puede sincronizarlos manualmente usando el botón de sincronización."});
}

/// Estado que indica que la sincronización de productos pendientes se ha completado
class SincronizacionCompletaState extends EscanerState {
  /// Lista de productos sincronizados con el servidor
  final List<Producto> productos;
  /// Mensaje opcional del servidor
  final String? mensaje;
  
  /// Constructor que recibe los productos sincronizados y opcionalmente un mensaje
  SincronizacionCompletaState(this.productos, {this.mensaje});
}

/// Estado que indica que no hay productos pendientes para sincronizar
class SinProductosPendientesState extends EscanerState {
  /// Mensaje informativo para el usuario
  final String message;
  
  /// Constructor con mensaje predeterminado
  SinProductosPendientesState({this.message = "No hay productos pendientes para sincronizar."});
}

/// Estado que indica que las selecciones de hospital y ubicación se han reiniciado
class SelectionsResetState extends EscanerState {}

/// Estado que indica que se ha seleccionado un hospital
class HospitalSeleccionadoState extends EscanerState {
  /// Hospital seleccionado
  final Hospital hospital;
  
  /// Constructor que recibe el hospital seleccionado
  HospitalSeleccionadoState(this.hospital);
}

/// Estado que indica que se ha seleccionado una ubicación
class LocationSeleccionadaState extends EscanerState {
  /// Ubicación seleccionada
  final Location location;
  
  /// Constructor que recibe la ubicación seleccionada
  LocationSeleccionadaState(this.location);
}

/// Estado que indica que los productos se han guardado en el almacenamiento local
class ProductosGuardadosLocalState extends EscanerState {
  /// Lista de productos guardados localmente
  final List<ProductoEscaneado> productos;
  
  /// Constructor que recibe la lista de productos guardados
  ProductosGuardadosLocalState(this.productos);
}