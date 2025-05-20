import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/widgets/list/product_data_table.dart';
import 'package:quilmedic/widgets/list/product_list_header.dart';

/// Widget que muestra una sección de lista de productos con un título y tabla de datos
/// Incluye un encabezado con título y contador, seguido de una tabla de productos
/// Permite personalizar colores y manejar eventos de tap en productos y transferencias
class ProductListSection extends StatelessWidget {
  /// Título de la sección de productos a mostrar
  final String title;
  /// Lista de productos a mostrar en la sección
  final List<Producto> productos;
  /// Color para el encabezado de la sección
  final Color headerColor;
  /// Color para las filas de la tabla de productos
  final Color rowColor;
  /// Función que se ejecuta cuando se toca un producto en la tabla
  final Function(Producto) onProductTap;
  /// Función opcional que se ejecuta cuando se presiona el botón de traslado
  /// Si es null, no se muestra el botón de traslado
  final Function(Producto)? onTransferTap;
  /// Lista de colores para las alarmas de los productos
  final List<Color> alarmColors;
  /// ID de la ubicación seleccionada actualmente (para evaluar alarmas de stock)
  final int selectedLocationId;

  /// Constructor del widget ProductListSection
  /// @param title Título de la sección
  /// @param productos Lista de productos a mostrar
  /// @param headerColor Color para el encabezado
  /// @param rowColor Color para las filas de la tabla
  /// @param onProductTap Función que se ejecuta al tocar un producto
  /// @param onTransferTap Función opcional para el botón de traslado
  /// @param alarmColors Lista de colores para las alarmas
  /// @param selectedLocationId ID de la ubicación seleccionada para evaluar alarmas
  const ProductListSection({
    super.key,
    required this.title,
    required this.productos,
    required this.headerColor,
    required this.rowColor,
    required this.onProductTap,
    this.onTransferTap,
    required this.alarmColors,
    required this.selectedLocationId,
  });

  /// Construye la interfaz de la sección de lista de productos
  /// Muestra un encabezado con título y contador, seguido de una tabla de productos
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ProductListHeader(
          title: title,
          count: productos.length,
          color: headerColor,
        ),
        ProductDataTable(
          productos: productos,
          headerColor: headerColor.withValues(alpha: 0.3),
          rowColor: rowColor,
          onProductTap: onProductTap,
          onTransferTap: onTransferTap,
          alarmColors: alarmColors,
          selectedLocationId: selectedLocationId,
        ),
      ],
    );
  }
}
