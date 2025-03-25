import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'producto_detalle_event.dart';
part 'producto_detalle_state.dart';

class ProductoDetalleBloc extends Bloc<ProductoDetalleEvent, ProductoDetalleState> {

  ProductoDetalleBloc() : super(ProductoDetalleInitial()) {
    //
  }

  
}