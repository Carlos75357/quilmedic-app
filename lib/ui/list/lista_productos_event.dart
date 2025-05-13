part of 'lista_productos_bloc.dart';

@immutable
sealed class ListaProductosEvent {}

class CargarProductosEvent extends ListaProductosEvent {
  final List<Producto> productos;

  CargarProductosEvent({this.productos = const []});
}

class MostrarProductosEvent extends ListaProductosEvent {
  final List<Producto> productos;

  MostrarProductosEvent(this.productos);
}

class CargarHospitalesEvent extends ListaProductosEvent {}

class EnviarSolicitudTrasladoEvent extends ListaProductosEvent {
  final List<Producto> productos;
  final int hospitalDestinoId;
  final String hospitalDestinoNombre;
  final String email;

  EnviarSolicitudTrasladoEvent({
    required this.productos,
    required this.hospitalDestinoId,
    required this.hospitalDestinoNombre,
    required this.email,
  });
}
