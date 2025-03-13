part of 'escaner_bloc.dart';

@immutable
sealed class EscanerState {}

final class EscanerInitial extends EscanerState {}

final class EscanerLoading extends EscanerState {}

final class EscanerSuccess extends EscanerState {}

final class EscanerError extends EscanerState {
  final String message;

  EscanerError(this.message);
}

final class HospitalesCargados extends EscanerState {
  final List<Hospital> hospitales;

  HospitalesCargados(this.hospitales);
}

final class EscanearCodigosState extends EscanerState {}

final class ProductoEscaneadoExistenteState extends EscanerState {
  final ProductoEscaneado producto;

  ProductoEscaneadoExistenteState(this.producto);
}

final class ProductoEscaneadoGuardadoState extends EscanerState {
  final ProductoEscaneado producto;

  ProductoEscaneadoGuardadoState(this.producto);
}

final class ProductosListadosState extends EscanerState {
  final List<ProductoEscaneado> productos;

  ProductosListadosState(this.productos);
}

class GuardarSuccess extends EscanerState {}
