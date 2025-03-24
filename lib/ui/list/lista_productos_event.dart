part of 'lista_productos_bloc.dart';

@immutable
sealed class ListaProductosEvent {}

class CargarProductosEvent extends ListaProductosEvent {}

class MostrarProductosEvent extends ListaProductosEvent {
  final List<Producto> productos;

  MostrarProductosEvent(this.productos);
}

class CargarHospitalesEvent extends ListaProductosEvent {}

class EnviarSolicitudTrasladoEvent extends ListaProductosEvent {
  final Producto producto;
  final String hospitalDestinoId;
  final String hospitalDestinoNombre;
  final String comentarios;

  EnviarSolicitudTrasladoEvent({
    required this.producto,
    required this.hospitalDestinoId,
    required this.hospitalDestinoNombre,
    required this.comentarios,
  });
}
