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
      final verificacionResponse = await productoRepository.getProductoByNumeroAndAlmacen(
        event.productoId,
        event.nuevoHospitalId,
      );
      
      if (verificacionResponse.success) {
        emit(ProductoTrasladadoState(
          verificacionResponse.message ?? 'El producto ya se encuentra en el almacén especificado'
        ));
        return;
      }
      
      if (!verificacionResponse.success && verificacionResponse.data != null) {
        final producto = verificacionResponse.data;
        final almacenActual = producto['codigoalmacen'];
        
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
          emit(ProductoEnOtroAlmacenState(
            verificacionResponse.message ?? 'El producto existe pero está en otro almacén',
            producto,
            almacenActual,
            almacenDestino: event.nuevoHospitalId,
          ));
        }
        return;
      }
      
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
