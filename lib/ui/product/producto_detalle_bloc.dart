import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'producto_detalle_event.dart';
part 'producto_detalle_state.dart';

/// Bloc que gestiona el estado de la pantalla de detalle de producto
/// Maneja eventos relacionados con la visualización y actualización de los detalles de un producto
class ProductoDetalleBloc extends Bloc<ProductoDetalleEvent, ProductoDetalleState> {

  /// Constructor del ProductoDetalleBloc
  /// Inicializa el bloc con el estado inicial
  /// Nota: Actualmente no hay eventos registrados, pendiente de implementación
  ProductoDetalleBloc() : super(ProductoDetalleInitial()) {
    // Pendiente de implementar los manejadores de eventos
  }

  
}