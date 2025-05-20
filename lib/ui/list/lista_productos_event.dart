part of 'lista_productos_bloc.dart';

/// Clase base abstracta para todos los eventos de la lista de productos
/// Todos los eventos que puede manejar el ListaProductosBloc deben extender esta clase
@immutable
sealed class ListaProductosEvent {}

/// Evento para cargar productos en la lista
class CargarProductosEvent extends ListaProductosEvent {
  /// [List] Lista de productos a cargar
  final List<Producto> productos;

  /// Constructor que recibe opcionalmente una lista de productos
  /// Por defecto, la lista está vacía
  CargarProductosEvent({this.productos = const []});
}

/// Evento para mostrar productos en la interfaz de usuario
class MostrarProductosEvent extends ListaProductosEvent {
  /// [List] Lista de productos a mostrar
  final List<Producto> productos;

  /// Constructor que recibe la lista de productos a mostrar
  MostrarProductosEvent(this.productos);
}

/// Evento para cargar la lista de hospitales desde el servidor
class CargarHospitalesEvent extends ListaProductosEvent {}

/// Evento para enviar una solicitud de traslado de productos entre hospitales
class EnviarSolicitudTrasladoEvent extends ListaProductosEvent {
  /// [List] Lista de productos a trasladar
  final List<Producto> productos;
  /// [int] ID del hospital de destino
  final int hospitalDestinoId;
  /// [String] Nombre del hospital de destino (para mostrar en mensajes)
  final String hospitalDestinoNombre;
  /// [String] Correo electrónico para notificaciones sobre el traslado
  final String email;

  /// Constructor que recibe todos los datos necesarios para el traslado
  EnviarSolicitudTrasladoEvent({
    required this.productos,
    required this.hospitalDestinoId,
    required this.hospitalDestinoNombre,
    required this.email,
  });
}
