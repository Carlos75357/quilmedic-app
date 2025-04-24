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
  final Producto producto;
  final int hospitalDestinoId;
  final String hospitalDestinoNombre;

  EnviarSolicitudTrasladoEvent({
    required this.producto,
    required this.hospitalDestinoId,
    required this.hospitalDestinoNombre,
  });
}
