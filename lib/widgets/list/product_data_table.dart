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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 360;
    final isExtremelySmallScreen = screenWidth < 320;
    final isWideScreen = screenWidth > 1200;
    
    if (isExtremelySmallScreen) {
      return _buildCompactList(context);
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive widths based on available space
        final availableWidth = constraints.maxWidth;
        final descriptionWidth = isWideScreen 
            ? (availableWidth * 0.4).toDouble() 
            : (isVerySmallScreen ? 80.0 : (isSmallScreen ? 100.0 : 150.0));
        final expiryWidth = isWideScreen 
            ? (availableWidth * 0.2).toDouble() 
            : (isVerySmallScreen ? 70.0 : (isSmallScreen ? 80.0 : 100.0));
        final stockWidth = isWideScreen 
            ? (availableWidth * 0.15).toDouble() 
            : (isVerySmallScreen ? 40.0 : (isSmallScreen ? 60.0 : 80.0));
        final actionsWidth = isWideScreen 
            ? (availableWidth * 0.15).toDouble() 
            : (isVerySmallScreen ? 50.0 : (isSmallScreen ? 70.0 : 90.0));
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: availableWidth,
              maxWidth: isWideScreen ? availableWidth : double.infinity,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith(
                  (states) => headerColor,
                ),
                dataRowMinHeight: 64,
                dataRowMaxHeight: 80,
                columnSpacing: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 24),
                horizontalMargin: isVerySmallScreen ? 4 : (isSmallScreen ? 8 : 24),
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                ),
                dataTextStyle: TextStyle(fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16)),
                columns: [
                  DataColumn(
                    label: SizedBox(
                      width: descriptionWidth,
                      child: const Text('Descripción'),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: expiryWidth,
                      child: const Text('Caducidad'),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: stockWidth,
                      child: const Text('Stock'),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: actionsWidth,
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
                        SizedBox(
                          width: descriptionWidth,
                          child: Text(
                            productos[index].descripcion ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 11 : null,
                            ),
                          ),
                        ),
                        onTap: () => onProductTap(productos[index]),
                      ),
                      DataCell(
                        SizedBox(
                          width: expiryWidth,
                          child: ProductExpiryBadge(
                            expiryDate: productos[index].fechacaducidad,
                            formattedDate: _formatDate(productos[index].fechacaducidad),
                            isSmallScreen: isVerySmallScreen,
                          ),
                        ),
                        onTap: () => onProductTap(productos[index]),
                      ),
                      DataCell(
                        SizedBox(
                          width: stockWidth,
                          child: ProductStockBadge(
                            stock: productos[index].cantidad,
                            isSmallScreen: isVerySmallScreen,
                          ),
                        ),
                        onTap: () => onProductTap(productos[index]),
                      ),
                      DataCell(
                        SizedBox(
                          width: actionsWidth,
                          child: isSmallScreen 
                            ? IconButton(
                                icon: Icon(
                                  Icons.visibility, 
                                  color: Colors.blue,
                                  size: isVerySmallScreen ? 18 : 24,
                                ),
                                onPressed: () => onProductTap(productos[index]),
                                tooltip: 'Ver detalles',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
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
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildCompactList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: index % 2 == 0 ? rowColor : null,
          child: InkWell(
            onTap: () => onProductTap(producto),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.descripcion ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text('Cad: ', style: TextStyle(fontSize: 12)),
                            ProductExpiryBadge(
                              expiryDate: producto.fechacaducidad,
                              formattedDate: _formatDate(producto.fechacaducidad),
                              isSmallScreen: true,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Text('Cantidad: ', style: TextStyle(fontSize: 12)),
                          ProductStockBadge(
                            stock: producto.cantidad,
                            isSmallScreen: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
