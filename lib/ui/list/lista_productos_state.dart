part of 'lista_productos_bloc.dart';

@immutable
sealed class ListaProductosState {}

final class ListaProductosInitial extends ListaProductosState {}

final class ListaProductosLoading extends ListaProductosState {}

final class ListaProductosSuccess extends ListaProductosState {}

final class ListaProductosError extends ListaProductosState {
  final String message;

  ListaProductosError(this.message);
}

final class ProductosCargadosState extends ListaProductosState {
  final List<Producto> productos;

  ProductosCargadosState(this.productos);
}

// Estados para la carga de hospitales
final class CargandoHospitalesState extends ListaProductosState {}

final class HospitalesCargadosState extends ListaProductosState {
  final List<Hospital> hospitales;

  HospitalesCargadosState(this.hospitales);
}

final class ErrorCargaHospitalesState extends ListaProductosState {
  final String mensaje;

  ErrorCargaHospitalesState(this.mensaje);
}

// Estados para el envío de solicitudes de traslado
final class EnviandoSolicitudTrasladoState extends ListaProductosState {}

final class SolicitudTrasladoEnviadaState extends ListaProductosState {
  final String mensaje;

  SolicitudTrasladoEnviadaState(this.mensaje);
}

final class ErrorSolicitudTrasladoState extends ListaProductosState {
  final String mensaje;

  ErrorSolicitudTrasladoState(this.mensaje);
}
