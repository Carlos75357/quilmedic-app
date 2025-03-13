part of 'lista_productos_bloc.dart';

@immutable
sealed class ListaProductosState {}

final class ListaProductosInitial extends ListaProductosState {}

final class ProductosCargadosState extends ListaProductosState {
  final List<ProductoScaneado> productos;

  ProductosCargadosState(this.productos);
}

