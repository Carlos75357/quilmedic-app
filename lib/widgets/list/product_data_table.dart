import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/widgets/list/product_expiry_badge.dart';
import 'package:quilmedic/widgets/list/product_stock_badge.dart';
import 'package:quilmedic/utils/alarm_utils.dart';
import 'package:quilmedic/widgets/list/compact_list.dart';
import 'package:quilmedic/utils/services.dart';

class ProductDataTable extends StatelessWidget {
  final List<Producto> productos;
  final Color headerColor;
  final Color rowColor;
  final Function(Producto) onProductTap;
  final Function(Producto)? onTransferTap;

  const ProductDataTable({
    super.key,
    required this.productos,
    required this.headerColor,
    required this.rowColor,
    required this.onProductTap,
    this.onTransferTap,
  });

  @override
  Widget build(BuildContext context) {
    final alarmUtils = AlarmUtils();

    final Map<String, Map<int, List<Producto>>> groupedProducts = {};
    for (final producto in productos) {
      groupedProducts.putIfAbsent(producto.numerodeproducto, () => {}).putIfAbsent(producto.codigoalmacen, () => []).add(producto);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 360;
    final isExtremelySmallScreen = screenWidth < 320;
    final isWideScreen = screenWidth > 1200;

    if (isExtremelySmallScreen) {
      return CompactList(productos: productos, onProductTap: onProductTap, onTransferTap: onTransferTap);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final descriptionWidth =
            isWideScreen
                ? (availableWidth * 0.4).toDouble()
                : (isVerySmallScreen ? 80.0 : (isSmallScreen ? 100.0 : 150.0));
        final expiryWidth =
            isWideScreen
                ? (availableWidth * 0.2).toDouble()
                : (isVerySmallScreen ? 85.0 : (isSmallScreen ? 95.0 : 110.0));
        final stockWidth =
            isWideScreen
                ? (availableWidth * 0.15).toDouble()
                : (isVerySmallScreen ? 40.0 : (isSmallScreen ? 60.0 : 80.0));

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: availableWidth,
                maxWidth: isWideScreen ? availableWidth : double.infinity,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.grey.shade300,
                    dataTableTheme: DataTableThemeData(
                      headingTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize:
                            isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                      ),
                      dataTextStyle: TextStyle(
                        fontSize:
                            isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                      ),
                    ),
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => headerColor,
                    ),
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 80,
                    columnSpacing:
                        isVerySmallScreen ? 4 : (isSmallScreen ? 8 : 24),
                    horizontalMargin:
                        isVerySmallScreen ? 2 : (isSmallScreen ? 6 : 24),
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        width: 1,
                        color: Colors.grey.shade200,
                      ),
                    ),
                    columns: [
                      DataColumn(
                        label: SizedBox(
                          width: descriptionWidth,
                          child: Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: isVerySmallScreen ? 14 : 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: isVerySmallScreen ? 2 : 4),
                              const Text('Descripción'),
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: expiryWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: isVerySmallScreen ? 14 : 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: isVerySmallScreen ? 2 : 4),
                              const Text('Caducidad'),
                            ],
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: stockWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: isVerySmallScreen ? 14 : 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: isVerySmallScreen ? 2 : 4),
                              const Text('Stock'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    rows: List<DataRow>.generate(
                      productos.length,
                      (index) {
                        final producto = productos[index];
                        final totalStock = groupedProducts[producto.numerodeproducto]?[producto.codigoalmacen]?.fold<int>(0, (sum, p) => sum + p.cantidad) ?? 0;

                        return DataRow(
                          color: WidgetStateProperty.resolveWith<Color?>((
                            Set<WidgetState> states,
                          ) {
                            if (states.contains(WidgetState.hovered)) {
                              return Colors.grey.shade100;
                            }
                            return rowColor;
                          }),
                          cells: [
                            DataCell(
                              SizedBox(
                                width: descriptionWidth,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    producto.descripcion ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: isVerySmallScreen ? 11 : null,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () => onProductTap(producto),
                            ),
                            DataCell(
                              SizedBox.expand(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: alarmUtils.getColorForExpiryFromCache(producto.serie),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  width: expiryWidth,
                                  child: ProductExpiryBadge(
                                    expiryDate: producto.fechacaducidad,
                                    formattedDate: formatDate(
                                      producto.fechacaducidad,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox.expand(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: alarmUtils.getColorForStockFromCache(totalStock, producto.numerodeproducto),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  width: stockWidth,
                                  child: ProductStockBadge(
                                    stock: totalStock,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
