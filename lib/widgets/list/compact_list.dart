import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/utils/alarm_utils.dart';
import 'package:quilmedic/utils/services.dart';
import 'package:quilmedic/widgets/list/product_expiry_badge.dart';
import 'package:quilmedic/widgets/list/product_stock_badge.dart';

class CompactList extends StatelessWidget {
  final List<Producto> productos;
  final Function(Producto) onProductTap;
  final Function(Producto)? onTransferTap;
  const CompactList({super.key, required this.productos, required this.onProductTap, required this.onTransferTap});

  @override
  Widget build(BuildContext context) {
    final alarmUtils = AlarmUtils();
  
    return ListView.separated(
      itemCount: productos.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final producto = productos[index];
        
        return InkWell(
          onTap: () => onProductTap(producto),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.description ?? 'Sin descripción',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: alarmUtils.getColorForExpiryFromCache(producto.serialnumber),
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
                                expiryDate: producto.expirationdate,
                                formattedDate: formatDate(
                                  producto.expirationdate,
                                ),
                                isSmallScreen: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: alarmUtils.getColorForStockFromCache(producto.stock, producto.serialnumber),
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
                              stock: producto.stock,
                              isSmallScreen: true,
                            ),
                          ],
                        ),
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
        );
      },
    );
  }
}