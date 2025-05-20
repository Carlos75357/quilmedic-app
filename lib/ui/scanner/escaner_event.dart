part of 'escaner_bloc.dart';

/// Clase base abstracta para todos los eventos del escáner
/// Todos los eventos que puede manejar el [EscanerBloc] deben extender esta clase
@immutable
sealed class EscanerEvent {}

/// Evento para iniciar el proceso de escaneo de código de barras
class EscanearCodigoEvent extends EscanerEvent {}

/// Evento para mostrar el listado de productos escaneados actualmente
class VerListadoProductosEscaneadosEvent extends EscanerEvent {} 

/// Evento para seleccionar un hospital
class ChooseStoreEvent extends EscanerEvent {
  /// Hospital seleccionado por el usuario
  final Hospital hospital;
  
  /// Constructor que recibe el hospital seleccionado
  ChooseStoreEvent(this.hospital);
}

/// Evento para seleccionar una ubicación dentro del hospital
class ChooseLocationEvent extends EscanerEvent {
  /// Ubicación seleccionada por el usuario
  final Location location;
  
  /// Constructor que recibe la ubicación seleccionada
  ChooseLocationEvent(this.location);
}

/// Evento para cargar la lista de hospitales desde el servidor
class LoadHospitales extends EscanerEvent {}

/// Evento para cargar las ubicaciones del hospital seleccionado
class LoadLocations extends EscanerEvent {}

/// Evento para procesar un código de barras escaneado o ingresado manualmente
class SubmitCodeEvent extends EscanerEvent {
  /// Código de barras escaneado o ingresado
  final String code;
  
  /// Constructor que recibe el código de barras
  SubmitCodeEvent(this.code);
}


/// Evento para guardar los productos escaneados en el servidor o localmente
class GuardarProductosEvent extends EscanerEvent {}

/// Evento para navegar a la pantalla de lista de productos
class IrAListaProductosEvent extends EscanerEvent {
  /// Lista de productos a mostrar
  final List<Producto> productos;
  
  /// Constructor que recibe la lista de productos
  IrAListaProductosEvent(this.productos);
}


/// Evento para eliminar un producto de la lista de productos escaneados
class EliminarProductoEvent extends EscanerEvent {
  /// Producto a eliminar
  final ProductoEscaneado producto;
  
  /// Constructor que recibe el producto a eliminar
  EliminarProductoEvent(this.producto);
}

/// Evento para sincronizar los productos pendientes con el servidor
class SincronizarProductosPendientesEvent extends EscanerEvent {}

/// Evento para cargar los productos pendientes almacenados localmente
class CargarProductosPendientesEvent extends EscanerEvent {}

/// Evento para reiniciar las selecciones de hospital y ubicación
class ResetSelectionsEvent extends EscanerEvent {}