import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/widgets/product/product_info_row.dart';
import 'package:quilmedic/utils/alarm_utils.dart';
import 'package:quilmedic/utils/services.dart';

class ProductInfoCard extends StatefulWidget {
  final Producto producto;
  final int totalStock;
  final Location? location;

  const ProductInfoCard({
    super.key,
    required this.producto,
    required this.totalStock,
    this.location,
  });

  @override
  State<ProductInfoCard> createState() => _ProductInfoCardState();
}

class _ProductInfoCardState extends State<ProductInfoCard> {
  final AlarmUtils _alarmUtils = AlarmUtils();
  Color expiryColor = Colors.grey;
  Color stockColor = Colors.grey;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  Future<void> _loadColors() async {
    try {
      
      final expColor = _alarmUtils.getColorForExpiryFromCache(widget.producto.productcode);
      
      final stColor = _alarmUtils.getColorForStockFromCache(widget.totalStock, widget.producto.productcode);

      if (mounted) {
        setState(() {
          expiryColor = expColor;
          stockColor = stColor;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          expiryColor = Colors.grey.withValues(alpha: 0.3);
          stockColor = Colors.grey.withValues(alpha: 0.3);
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.producto.description ?? 'Sin descripción',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  
                  const Divider(height: 32),
                  
                  ProductInfoRow(
                    label: 'serialnumber:', 
                    value: widget.producto.serialnumber,
                    icon: Icons.qr_code,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ProductInfoRow(
                    label: 'ID Producto:', 
                    value: widget.producto.productcode.toString(),
                    icon: Icons.tag,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ProductInfoRow(
                    label: 'Lote:', 
                    value: widget.producto.numerolote.toString(),
                    icon: Icons.inventory_2,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ProductInfoRow(
                    label: 'Fecha de caducidad:', 
                    value: formatDate(widget.producto.expirationdate),
                    icon: Icons.calendar_today,
                    color: expiryColor,
                  ),
                  
                  const SizedBox(height: 16),

                  ProductInfoRow(
                    label: 'stock:', 
                    value: widget.producto.stock.toString(),
                    icon: Icons.inventory,
                    color: stockColor,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (widget.location != null) 
                    ProductInfoRow(
                      label: 'Código de almacén:', 
                      value: widget.location!.storeId.toString(),
                      icon: Icons.warehouse,
                    )
                  else
                    ProductInfoRow(
                      label: 'Código de almacén:', 
                      value: 'No disponible',
                      icon: Icons.warehouse,
                      color: Colors.grey,
                    ),
                ],
              ),
      ),
    );
  }

}
