import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/widgets/list/product_expiry_badge.dart';
import 'package:quilmedic/widgets/list/product_stock_badge.dart';
import 'package:quilmedic/utils/color.dart';

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
                        fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                      ),
                      dataTextStyle: TextStyle(
                        fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                      ),
                    ),
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => headerColor,
                    ),
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 80,
                    columnSpacing: isVerySmallScreen ? 4 : (isSmallScreen ? 8 : 24),
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
                      (index) => DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>((
                          Set<WidgetState> states,
                        ) {
                          if (states.contains(WidgetState.hovered)) {
                            return Colors.grey.shade100;
                          }
                          if (index % 2 == 0) {
                            return rowColor;
                          }
                          return null;
                        }),
                        cells: [
                          DataCell(
                            SizedBox(
                              width: descriptionWidth,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  productos[index].descripcion ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 11 : null,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            onTap: () => onProductTap(productos[index]),
                          ),
                          DataCell(
                            SizedBox.expand(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ColorAlarm.getColorForExpiryDate(
                                    productos[index].fechacaducidad,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                width: expiryWidth,
                                child: ProductExpiryBadge(
                                  expiryDate: productos[index].fechacaducidad,
                                  formattedDate: _formatDate(
                                    productos[index].fechacaducidad,
                                  ),
                                  isSmallScreen: isVerySmallScreen,
                                ),
                              ),
                            ),
                            onTap: () => onProductTap(productos[index]),
                          ),
                          DataCell(
                            SizedBox.expand(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ColorAlarm.getColorForStock(
                                    productos[index].cantidad,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                width: stockWidth,
                                child: ProductStockBadge(
                                  stock: productos[index].cantidad,
                                  isSmallScreen: isVerySmallScreen,
                                ),
                              ),
                            ),
                            onTap: () => onProductTap(productos[index]),
                          ),
                        ],
                      ),
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

  String _formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();

    return '$day/$month/$year';
  }

  Widget _buildCompactList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: index % 2 == 0 ? rowColor : Colors.white,
          child: InkWell(
            onTap: () => onProductTap(producto),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.medication_outlined,
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          producto.descripcion ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorAlarm.getColorForExpiryDate(
                              producto.fechacaducidad,
                            ).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: ProductExpiryBadge(
                                  expiryDate: producto.fechacaducidad,
                                  formattedDate: _formatDate(
                                    producto.fechacaducidad,
                                  ),
                                  isSmallScreen: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: ColorAlarm.getColorForStock(
                            producto.cantidad,
                          ).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 4),
                            ProductStockBadge(
                              stock: producto.cantidad,
                              isSmallScreen: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (onTransferTap != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => onTransferTap!(producto),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: const Text('Trasladar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
