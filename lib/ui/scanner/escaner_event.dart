part of 'escaner_bloc.dart';

@immutable
sealed class EscanerEvent {}

class EscanearCodigoEvent extends EscanerEvent {}

class VerListadoProductosEscaneadosEvent extends EscanerEvent {} 

class ElegirHospitalEvent extends EscanerEvent {
  final Hospital hospital;
  
  ElegirHospitalEvent(this.hospital);
}

class LoadHospitales extends EscanerEvent {}

class SubmitCodeEvent extends EscanerEvent {
  final String code;
  
  SubmitCodeEvent(this.code);
}

class GuardarProductosEvent extends EscanerEvent {}

class IrAListaProductosEvent extends EscanerEvent {
  final List<Producto> productos;
  
  IrAListaProductosEvent(this.productos);
}

class GuardarProductosForzadoEvent extends EscanerEvent {}

class EliminarProductoEvent extends EscanerEvent {
  final ProductoEscaneado producto;
  
  EliminarProductoEvent(this.producto);
}

class SincronizarProductosPendientesEvent extends EscanerEvent {}

class CargarProductosPendientesEvent extends EscanerEvent {}