part of 'producto_detalle_bloc.dart';

@immutable
sealed class ProductoDetalleEvent {}

class CargarHospitalesEvent extends ProductoDetalleEvent {}

class TrasladarProductoEvent extends ProductoDetalleEvent {
  final String productoId;
  final String nuevoHospitalId;
  final bool confirmarTraslado;

  TrasladarProductoEvent({
    required this.productoId,
    required this.nuevoHospitalId,
    this.confirmarTraslado = false,
  });
}

class ConfirmarTrasladoProductoEvent extends ProductoDetalleEvent {
  final String productoId;
  final String nuevoHospitalId;

  ConfirmarTrasladoProductoEvent({
    required this.productoId,
    required this.nuevoHospitalId,
  });
}
