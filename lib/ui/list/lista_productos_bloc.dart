import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/producto_repository.dart';

part 'lista_productos_event.dart';
part 'lista_productos_state.dart';

class ListaProductosBloc
    extends Bloc<ListaProductosEvent, ListaProductosState> {
  final ApiClient apiClient = ApiClient();
  late ProductoRepository productoRepository = ProductoRepository(apiClient: apiClient);
  
  ListaProductosBloc() : super(ListaProductosInitial()) {
    on<CargarProductosEvent>(_cargarProductos);
    on<MostrarProductosEvent>(_mostrarProductos);
  }
  
  Future<void> _cargarProductos(
    CargarProductosEvent event,
    Emitter<ListaProductosState> emit,
  ) async {
    try {
      emit(ListaProductosLoading());
      
      // Aquí iría la lógica para cargar productos desde el repositorio
      // Por ahora, como ejemplo, devolvemos una lista vacía
      List<Producto> productos = [];
      
      emit(ProductosCargadosState(productos));
    } catch (e) {
      emit(ListaProductosError(e.toString()));
    }
  }
  
  void _mostrarProductos(
    MostrarProductosEvent event,
    Emitter<ListaProductosState> emit,
  ) {
    emit(ProductosCargadosState(event.productos));
  }
}
