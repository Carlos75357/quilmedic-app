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

final class ProductoEnOtroAlmacenState extends EscanerState {
  final ProductoEscaneado productoEscaneado;
  final dynamic productoExistente;
  final int almacenActual;
  final int almacenCorrecto;

  ProductoEnOtroAlmacenState({
    required this.productoEscaneado,
    required this.productoExistente,
    required this.almacenActual,
    required this.almacenCorrecto,
  });
}

final class ProductosListadosState extends EscanerState {
  final List<ProductoEscaneado> productos;

  ProductosListadosState(this.productos);
}

class GuardarSuccess extends EscanerState {
  final List<Producto> productos;
  
  GuardarSuccess({required this.productos});
}

class ProductosRecibidosState extends EscanerState {
  final List<Producto> productos;
  
  ProductosRecibidosState(this.productos);
}

final class ProductosEnOtroAlmacenState extends EscanerState {
  final List<ProductoEscaneado> productosEnAlmacenCorrecto;
  final List<ProductoEscaneado> productosEnOtroAlmacen;
  final List<ProductoEscaneado> productosNuevos;
  final int almacenActual;

  ProductosEnOtroAlmacenState({
    required this.productosEnAlmacenCorrecto,
    required this.productosEnOtroAlmacen,
    required this.productosNuevos,
    required this.almacenActual,
  });
}

class GuardarOfflineSuccess extends EscanerState {
  final String message;
  
  GuardarOfflineSuccess({this.message = "Productos guardados localmente. Se sincronizarán automáticamente cuando haya conexión a internet. También puede sincronizarlos manualmente usando el botón de sincronización."});
}

class SincronizacionCompletaState extends EscanerState {
  final List<Producto> productos;
  
  SincronizacionCompletaState(this.productos);
}

class SinProductosPendientesState extends EscanerState {
  final String message;
  
  SinProductosPendientesState({this.message = "No hay productos pendientes para sincronizar."});
}
