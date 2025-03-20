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
    // Detectar si estamos en una pantalla pequeña
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: WidgetStateProperty.resolveWith(
            (states) => headerColor,
          ),
          dataRowMinHeight: 64,
          dataRowMaxHeight: 80,
          // Reducir el espaciado entre columnas en pantallas pequeñas
          columnSpacing: isSmallScreen ? 12 : 24,
          horizontalMargin: isSmallScreen ? 8 : 24,
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 14 : 16,
          ),
          dataTextStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
          columns: [
            DataColumn(
              label: Container(
                width: isSmallScreen ? 100 : 150,
                child: const Text('Descripción'),
              ),
            ),
            DataColumn(
              label: Container(
                width: isSmallScreen ? 80 : 100,
                child: const Text('Caducidad'),
              ),
            ),
            DataColumn(
              label: Container(
                width: isSmallScreen ? 60 : 80,
                child: const Text('Stock'),
              ),
            ),
            DataColumn(
              label: Container(
                width: isSmallScreen ? 70 : 90,
                child: const Text('Acciones'),
              ),
            ),
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
                  Container(
                    width: isSmallScreen ? 100 : 150,
                    child: Text(
                      productos[index].descripcion ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  onTap: () => onProductTap(productos[index]),
                ),
                DataCell(
                  Container(
                    width: isSmallScreen ? 80 : 100,
                    child: ProductExpiryBadge(
                      expiryDate: productos[index].fechacaducidad,
                      formattedDate: _formatDate(productos[index].fechacaducidad),
                    ),
                  ),
                  onTap: () => onProductTap(productos[index]),
                ),
                DataCell(
                  Container(
                    width: isSmallScreen ? 60 : 80,
                    child: ProductStockBadge(stock: productos[index].stock),
                  ),
                  onTap: () => onProductTap(productos[index]),
                ),
                DataCell(
                  Container(
                    width: isSmallScreen ? 70 : 90,
                    child: isSmallScreen 
                      ? IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blue),
                          onPressed: () => onProductTap(productos[index]),
                          tooltip: 'Ver detalles',
                        )
                      : ElevatedButton.icon(
                          onPressed: () => onProductTap(productos[index]),
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text('Ver'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
