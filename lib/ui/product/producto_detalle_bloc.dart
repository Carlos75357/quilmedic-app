import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/hospital_repository.dart';
import 'package:quilmedic/data/respository/producto_repository.dart';
import 'package:quilmedic/domain/hospital.dart';

part 'producto_detalle_event.dart';
part 'producto_detalle_state.dart';

class ProductoDetalleBloc extends Bloc<ProductoDetalleEvent, ProductoDetalleState> {
  final ApiClient apiClient = ApiClient();
  late final HospitalRepository hospitalRepository = HospitalRepository(apiClient: apiClient);
  late final ProductoRepository productoRepository = ProductoRepository(apiClient: apiClient);
  
  ProductoDetalleBloc() : super(ProductoDetalleInitial()) {
    on<CargarHospitalesEvent>(_onCargarHospitales);
    on<TrasladarProductoEvent>(_onTrasladarProducto);
    on<ConfirmarTrasladoProductoEvent>(_onConfirmarTrasladoProducto);
  }
  
  Future<void> _onCargarHospitales(CargarHospitalesEvent event, Emitter<ProductoDetalleState> emit) async {
    emit(CargandoHospitalesState());
    
    try {
      final response = await hospitalRepository.getAllHospitals();
      
      if (response.success) {
        final hospitales = List<Hospital>.from(response.data);
        emit(HospitalesCargadosState(hospitales));
      } else {
        emit(ErrorCargaHospitalesState(
          response.message ?? 'Error al cargar hospitales'
        ));
      }
    } catch (e) {
      emit(ErrorCargaHospitalesState('Error al cargar hospitales: ${e.toString()}'));
    }
  }
  
  Future<void> _onTrasladarProducto(TrasladarProductoEvent event, Emitter<ProductoDetalleState> emit) async {
    emit(TrasladandoProductoState());
    
    try {
      // Primero verificamos si el producto existe y en qué almacén está
      final verificacionResponse = await productoRepository.getProductoByNumeroAndAlmacen(
        event.productoId,
        event.nuevoHospitalId,
      );
      
      // Si el producto ya está en el almacén correcto, no es necesario trasladarlo
      if (verificacionResponse.success) {
        emit(ProductoTrasladadoState(
          verificacionResponse.message ?? 'El producto ya se encuentra en el almacén especificado'
        ));
        return;
      }
      
      // Si el producto existe pero está en otro almacén, emitimos un estado especial
      if (!verificacionResponse.success && verificacionResponse.data != null) {
        final producto = verificacionResponse.data;
        final almacenActual = producto['codigoalmacen'];
        
        // Si el usuario quiere trasladar el producto, procedemos con el traslado
        if (event.confirmarTraslado) {
          final response = await productoRepository.trasladarProducto(
            event.productoId,
            event.nuevoHospitalId,
          );
          
          if (response.success) {
            emit(ProductoTrasladadoState(
              response.message ?? 'Producto trasladado correctamente'
            ));
          } else {
            emit(ErrorTrasladoProductoState(
              response.message ?? 'Error al trasladar producto'
            ));
          }
        } else {
          // Si el usuario no ha confirmado el traslado, emitimos el estado para mostrar la confirmación
          emit(ProductoEnOtroAlmacenState(
            verificacionResponse.message ?? 'El producto existe pero está en otro almacén',
            producto,
            almacenActual,
          ));
        }
        return;
      }
      
      // Si el producto no existe, emitimos un error
      emit(ErrorTrasladoProductoState(
        verificacionResponse.message ?? 'No se encontró el producto'
      ));
    } catch (e) {
      emit(ErrorTrasladoProductoState('Error al trasladar producto: ${e.toString()}'));
    }
  }
  
  Future<void> _onConfirmarTrasladoProducto(ConfirmarTrasladoProductoEvent event, Emitter<ProductoDetalleState> emit) async {
    emit(TrasladandoProductoState());
    
    try {
      // Aquí realizamos el traslado con la confirmación
      final response = await productoRepository.trasladarProducto(
        event.productoId,
        event.nuevoHospitalId,
      );
      
      if (response.success) {
        emit(ProductoTrasladadoState(
          response.message ?? 'Producto trasladado correctamente'
        ));
      } else {
        emit(ErrorTrasladoProductoState(
          response.message ?? 'Error al trasladar producto'
        ));
      }
    } catch (e) {
      emit(ErrorTrasladoProductoState('Error al trasladar producto: ${e.toString()}'));
    }
  }
}
