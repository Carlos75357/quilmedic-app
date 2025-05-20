part of 'producto_detalle_bloc.dart';

/// Clase base abstracta para todos los estados del detalle de producto
/// Todos los estados posibles del [ProductoDetalleBloc] deben extender esta clase
@immutable
sealed class ProductoDetalleState {}

/// Estado inicial del detalle de producto, antes de cualquier acción
/// Actualmente es el único estado implementado, pendiente de desarrollo futuro
final class ProductoDetalleInitial extends ProductoDetalleState {}

