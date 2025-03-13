import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

part 'lista_productos_event.dart';
part 'lista_productos_state.dart';

class ListaProductosBloc
    extends Bloc<ListaProductosEvent, ListaProductosState> {
  ListaProductosBloc() : super(ListaProductosInitial()) {
    // on<ListaProductosEvent>();
  }
}
