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
  final List<Color> alarmColors;

  const ProductDataTable({
    super.key,
    required this.productos,
    required this.headerColor,
    required this.rowColor,
    required this.onProductTap,
    this.onTransferTap,
    required this.alarmColors,
  });

  @override
  Widget build(BuildContext context) {
    final alarmUtils = AlarmUtils();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      alarmUtils.loadAlarmsFromCache();
    });

    final Map<String, List<Producto>> groupedProducts = {};
    for (final producto in productos) {
      groupedProducts.putIfAbsent(producto.productcode, () => []).add(producto);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 360;
    final isExtremelySmallScreen = screenWidth < 320;
    final isWideScreen = screenWidth > 1200;

    if (isExtremelySmallScreen) {
      return CompactList(
        productos: productos,
        onProductTap: onProductTap,
        onTransferTap: onTransferTap,
        alarmColors: alarmColors,
      );
    }

    if (productos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No hay productos para mostrar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final expiryWidth =
            isWideScreen
                ? (availableWidth * 0.2).toDouble()
                : (isVerySmallScreen ? 85.0 : (isSmallScreen ? 95.0 : 110.0));
        final stockWidth =
            isWideScreen
                ? (availableWidth * 0.15).toDouble()
                : (isVerySmallScreen ? 40.0 : (isSmallScreen ? 60.0 : 80.0));
        final codeWidth =
            isWideScreen
                ? (availableWidth * 0.15).toDouble()
                : (isVerySmallScreen ? 70.0 : (isSmallScreen ? 80.0 : 100.0));

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
                          width: codeWidth,
                          child: Row(
                            children: [
                              Icon(
                                Icons.code_outlined,
                                size: isVerySmallScreen ? 14 : 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: isVerySmallScreen ? 2 : 4),
                              const Text('Código'),
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
                    rows: List<DataRow>.generate(productos.length, (index) {
                      final producto = productos[index];
                      final totalStock =
                          groupedProducts[producto.productcode]?.fold<int>(
                            0,
                            (sum, p) => sum + p.stock,
                          ) ??
                          0;

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
                              width: codeWidth,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      producto.productcode,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isVerySmallScreen ? 11 : null,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    Text(
                                      producto.serialnumber,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isVerySmallScreen ? 10 : 12,
                                        color: Colors.grey.shade700,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                                ),
                              ),
                            onTap: () => onProductTap(producto),
                            ),
                          DataCell(
                            SizedBox.expand(
                              child: Container(
                                decoration: BoxDecoration(
                                color: alarmUtils.getColorForExpiryFromCache(producto.id, producto.expirationdate),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                width: expiryWidth,
                                child: ProductExpiryBadge(
                                  expiryDate: producto.expirationdate,
                                  formattedDate: formatDate(
                                    producto.expirationdate,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox.expand(
                              child: Container(
                                decoration: BoxDecoration(
                                color: alarmUtils.getColorForStockFromCache(totalStock, producto.id, producto.locationid),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                width: stockWidth,
                                child: ProductStockBadge(
                                  stock: totalStock,
                                  alarmUtils: alarmUtils,
                                  productId: producto.id,
                                  locationId: producto.locationid,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
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
