part of 'lista_productos_bloc.dart';

@immutable
sealed class ListaProductosEvent {}

class CargarProductosEvent extends ListaProductosEvent {}

class MostrarProductosEvent extends ListaProductosEvent {
  final List<Producto> productos;
  
  MostrarProductosEvent(this.productos);
}
