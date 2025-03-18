import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/widgets/list/product_expiry_badge.dart';
import 'package:quilmedic/widgets/list/product_stock_badge.dart';

class ProductDataTable extends StatelessWidget {
  final List<Producto> productos;
  final Color headerColor;
  final Color rowColor;
  final Function(Producto) onProductTap;

  const ProductDataTable({
    super.key,
    required this.productos,
    required this.headerColor,
    required this.rowColor,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        headingRowColor: WidgetStateColor.resolveWith(
          (states) => headerColor,
        ),
        dataRowMinHeight: 64,
        dataRowMaxHeight: 80,
        columnSpacing: 24,
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        dataTextStyle: const TextStyle(fontSize: 16),
        columns: const [
          DataColumn(label: Expanded(child: Text('Descripción'))),
          DataColumn(label: Expanded(child: Text('Caducidad'))),
          DataColumn(label: Expanded(child: Text('Stock'))),
          DataColumn(label: Expanded(child: Text('Acciones'))),
        ],
        rows: List<DataRow>.generate(
          productos.length,
          (index) => DataRow(
            color: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (index % 2 == 0) {
                return rowColor;
              }
              return null;
            }),
            cells: [
              DataCell(
                SizedBox(
                  width: 100,
                  child: Text(
                    productos[index].descripcion ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                onTap: () => onProductTap(productos[index]),
              ),
              DataCell(
                ProductExpiryBadge(
                  expiryDate: productos[index].fechacaducidad,
                  formattedDate: _formatDate(productos[index].fechacaducidad),
                ),
                onTap: () => onProductTap(productos[index]),
              ),
              DataCell(
                ProductStockBadge(stock: productos[index].stock),
                onTap: () => onProductTap(productos[index]),
              ),
              DataCell(
                ElevatedButton.icon(
                  onPressed: () => onProductTap(productos[index]),
                  icon: const Icon(Icons.visibility, size: 20),
                  label: const Text('Ver'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
