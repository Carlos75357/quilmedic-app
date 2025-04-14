part of 'escaner_bloc.dart';

@immutable
sealed class EscanerEvent {}

class EscanearCodigoEvent extends EscanerEvent {}

class VerListadoProductosEscaneadosEvent extends EscanerEvent {} 

class ChooseStoreEvent extends EscanerEvent {
  final Hospital hospital;
  
  ChooseStoreEvent(this.hospital);
}

class ChooseLocationEvent extends EscanerEvent {
  final Location location;
  
  ChooseLocationEvent(this.location);
}

class LoadHospitales extends EscanerEvent {}

class LoadLocations extends EscanerEvent {}

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

class ResetSelectionsEvent extends EscanerEvent {}