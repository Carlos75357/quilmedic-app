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

final class LocationsCargadas extends EscanerState {
  final List<Location> locations;

  LocationsCargadas(this.locations);
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
  final bool hayProductosPendientes;

  ProductosListadosState(this.productos, {this.hayProductosPendientes = false});
}

class GuardarSuccess extends EscanerState {
  final List<Producto> productos;
  final String? mensaje;
  
  GuardarSuccess({required this.productos, this.mensaje});
}

class ProductosRecibidosState extends EscanerState {
  final List<Producto> productos;
  final List<String> productosNotFound;
  final String? mensaje;
  
  ProductosRecibidosState(this.productos, this.productosNotFound, {this.mensaje});
}

class GuardarOfflineSuccess extends EscanerState {
  final String message;
  
  GuardarOfflineSuccess({this.message = "Productos guardados localmente. Se sincronizarán automáticamente cuando haya conexión a internet. También puede sincronizarlos manualmente usando el botón de sincronización."});
}

class SincronizacionCompletaState extends EscanerState {
  final List<Producto> productos;
  final String? mensaje;
  
  SincronizacionCompletaState(this.productos, {this.mensaje});
}

class SinProductosPendientesState extends EscanerState {
  final String message;
  
  SinProductosPendientesState({this.message = "No hay productos pendientes para sincronizar."});
}

class SelectionsResetState extends EscanerState {}

class HospitalSeleccionadoState extends EscanerState {
  final Hospital hospital;
  
  HospitalSeleccionadoState(this.hospital);
}

class LocationSeleccionadaState extends EscanerState {
  final Location location;
  
  LocationSeleccionadaState(this.location);
}

class ProductosGuardadosLocalState extends EscanerState {
  final List<ProductoEscaneado> productos;
  
  ProductosGuardadosLocalState(this.productos);
}