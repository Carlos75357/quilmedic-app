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

class QrCodeScannedEvent extends EscanerEvent {
  final String qrCode;
  
  QrCodeScannedEvent(this.qrCode);
}

class GuardarProductosEvent extends EscanerEvent {}

class IrAListaProductosEvent extends EscanerEvent {
  final List<Producto> productos;
  
  IrAListaProductosEvent(this.productos);
}