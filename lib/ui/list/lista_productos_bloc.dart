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
  
  Future<void> _cargarProductos(CargarProductosEvent event, Emitter<ListaProductosState> emit) async {
    try {
      emit(ListaProductosLoading());
      
      final response = await apiClient.getAll(
        '/productos',
        null,
      );
      
      if (response is List) {
        List<Producto> productos = [];
        for (var item in response) {
          if (item is Map<String, dynamic>) {
            try {
              productos.add(
                Producto(
                  item['numproducto'] ?? 0,
                  item['descripcion'] ?? '',
                  item['codigoalmacen'] ?? 0,
                  item['ubicacion'] ?? '',
                  item['numerolote'] ?? 0,
                  item['descripcionlote'] ?? '',
                  item['numerodeproducto'] ?? 0,
                  item['descripcion1'] ?? 'Sin descripción',
                  item['codigoalmacen1'] ?? 0,
                  item['serie'] ?? '',
                  item['fechacaducidad'] != null
                      ? DateTime.parse(item['fechacaducidad'])
                      : DateTime.now(),
                ),
              );
            } catch (e) {
              emit(ListaProductosError('Error al cargar productos: ${e.toString()}'));
            }
          }
        }
        
        emit(ProductosCargadosState(productos));
      } else {
        emit(ListaProductosError('Error al cargar productos: formato de respuesta inválido'));
      }
    } catch (e) {
      emit(ListaProductosError('Error al cargar productos: ${e.toString()}'));
    }
  }
  
  void _mostrarProductos(
    MostrarProductosEvent event,
    Emitter<ListaProductosState> emit,
  ) {
    emit(ProductosCargadosState(event.productos));
  }
}
