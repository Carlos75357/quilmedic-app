part of 'lista_productos_bloc.dart';

@immutable
sealed class ListaProductosState {}

final class ListaProductosInitial extends ListaProductosState {}

final class ListaProductosLoading extends ListaProductosState {}

final class ListaProductosSuccess extends ListaProductosState {}

final class ListaProductosError extends ListaProductosState {
  final String message;

  ListaProductosError(this.message);
}

final class ProductosCargadosState extends ListaProductosState {
  final List<Producto> productos;

  ProductosCargadosState(this.productos);
}
