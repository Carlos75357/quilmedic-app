part of 'escaner_bloc.dart';

@immutable
sealed class EscanerEvent {}

class EscanearCodigoEvent extends EscanerEvent {}

class VerListadoProductosEscaneadosEvent extends EscanerEvent {} // guardar

class ElegirHospitalEvent extends EscanerEvent {
  final Hospital hospital;
  
  ElegirHospitalEvent(this.hospital);
}

class LoadHospitales extends EscanerEvent {}

class QrCodeScannedEvent extends EscanerEvent {
  final String qrCode;
  
  QrCodeScannedEvent(this.qrCode);
}

class GuardarProductosEvent extends EscanerEvent {
  final List<ProductoEscaneado> productos;
  
  GuardarProductosEvent(this.productos);
}
