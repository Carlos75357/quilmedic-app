import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/widgets/list/product_data_table.dart';
import 'package:quilmedic/widgets/list/product_list_header.dart';

class ProductListSection extends StatelessWidget {
  final String title;
  final List<Producto> productos;
  final Color headerColor;
  final Color rowColor;
  final Function(Producto) onProductTap;

  const ProductListSection({
    super.key,
    required this.title,
    required this.productos,
    required this.headerColor,
    required this.rowColor,
    required this.onProductTap,
  });

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
        ),
      ],
    );
  }
}
