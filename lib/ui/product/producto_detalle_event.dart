part of 'producto_detalle_bloc.dart';

@immutable
sealed class ProductoDetalleEvent {}

class CargarHospitalesEvent extends ProductoDetalleEvent {}

class TrasladarProductoEvent extends ProductoDetalleEvent {
  final int productoId;
  final int nuevoHospitalId;
  final bool confirmarTraslado;
  
  TrasladarProductoEvent({
    required this.productoId,
    required this.nuevoHospitalId,
    this.confirmarTraslado = false,
  });
}

class ConfirmarTrasladoProductoEvent extends ProductoDetalleEvent {
  final int productoId;
  final int nuevoHospitalId;
  
  ConfirmarTrasladoProductoEvent({
    required this.productoId,
    required this.nuevoHospitalId,
  });
}
