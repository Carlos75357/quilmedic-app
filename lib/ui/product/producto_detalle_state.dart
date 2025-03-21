part of 'producto_detalle_bloc.dart';

@immutable
sealed class ProductoDetalleState {}

final class ProductoDetalleInitial extends ProductoDetalleState {}

final class CargandoHospitalesState extends ProductoDetalleState {}

final class HospitalesCargadosState extends ProductoDetalleState {
  final List<dynamic> hospitales;

  HospitalesCargadosState(this.hospitales);
}

final class ErrorCargaHospitalesState extends ProductoDetalleState {
  final String mensaje;

  ErrorCargaHospitalesState(this.mensaje);
}

final class TrasladandoProductoState extends ProductoDetalleState {}

final class ProductoTrasladadoState extends ProductoDetalleState {
  final String mensaje;

  ProductoTrasladadoState(this.mensaje);
}

final class ProductoEnOtroAlmacenState extends ProductoDetalleState {
  final String mensaje;
  final dynamic producto;
  final String almacenActual;
  final String almacenDestino;

  ProductoEnOtroAlmacenState(
    this.mensaje,
    this.producto,
    this.almacenActual, {
    this.almacenDestino = "0",
  });
}

final class ErrorTrasladoProductoState extends ProductoDetalleState {
  final String mensaje;

  ErrorTrasladoProductoState(this.mensaje);
}
