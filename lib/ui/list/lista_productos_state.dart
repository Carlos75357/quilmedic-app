part of 'lista_productos_bloc.dart';

/// Clase base abstracta para todos los estados de la lista de productos
/// Todos los estados posibles del ListaProductosBloc deben extender esta clase
@immutable
sealed class ListaProductosState {}

/// Estado inicial de la lista de productos, antes de cualquier acción
final class ListaProductosInitial extends ListaProductosState {}

/// Estado de carga, indica que se está procesando alguna operación
final class ListaProductosLoading extends ListaProductosState {}

/// Estado de éxito genérico, indica que una operación se completó correctamente
final class ListaProductosSuccess extends ListaProductosState {}

/// Estado de error genérico, indica que ocurrió un problema durante alguna operación
final class ListaProductosError extends ListaProductosState {
  /// [String] Mensaje de error para mostrar al usuario
  final String message;

  /// Constructor que recibe el mensaje de error
  ListaProductosError(this.message);
}

/// Estado que indica que los productos se han cargado correctamente
final class ProductosCargadosState extends ListaProductosState {
  /// [List] Lista de productos cargados
  final List<Producto> productos;

  /// Constructor que recibe la lista de productos
  ProductosCargadosState(this.productos);
}

/// Estado que indica que se están cargando los hospitales
final class CargandoHospitalesState extends ListaProductosState {}

/// Estado que indica que los hospitales se han cargado correctamente
final class HospitalesCargadosState extends ListaProductosState {
  /// [List] Lista de hospitales cargados
  final List<Hospital> hospitales;

  /// Constructor que recibe la lista de hospitales
  HospitalesCargadosState(this.hospitales);
}

/// Estado que indica que ocurrió un error al cargar los hospitales
final class ErrorCargaHospitalesState extends ListaProductosState {
  /// [String] Mensaje de error para mostrar al usuario
  final String mensaje;

  /// Constructor que recibe el mensaje de error
  ErrorCargaHospitalesState(this.mensaje);
}

/// Estado que indica que se está enviando una solicitud de traslado
final class EnviandoSolicitudTrasladoState extends ListaProductosState {}

/// Estado que indica que la solicitud de traslado se ha enviado correctamente
final class SolicitudTrasladoEnviadaState extends ListaProductosState {
  /// [String] Mensaje de éxito para mostrar al usuario
  final String mensaje;

  /// Constructor que recibe el mensaje de éxito
  SolicitudTrasladoEnviadaState(this.mensaje);
}

/// Estado que indica que ocurrió un error al enviar la solicitud de traslado
final class ErrorSolicitudTrasladoState extends ListaProductosState {
  /// [String] Mensaje de error para mostrar al usuario
  final String mensaje;

  /// Constructor que recibe el mensaje de error
  ErrorSolicitudTrasladoState(this.mensaje);
}
