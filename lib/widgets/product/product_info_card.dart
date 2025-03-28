import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/widgets/product/product_info_row.dart';
import 'package:quilmedic/utils/alarm_utils.dart';

class ProductInfoCard extends StatefulWidget {
  final Producto producto;

  const ProductInfoCard({
    super.key,
    required this.producto,
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
      
      final expColor = await _alarmUtils.setColorExpirationDate(
        widget.producto.fechacaducidad,
        widget.producto.numerodeproducto,
      );
      
      final stColor = _getStockColor(widget.producto.cantidad);

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
          expiryColor = _getDefaultExpiryColor(widget.producto.fechacaducidad);
          stockColor = _getStockColor(widget.producto.cantidad);
          isLoading = false;
        });
      }
    }
  }

  Color _getStockColor(int stock) {
    if (stock < 1) {
      return Colors.grey; // Sin stock
    } else {
      return Colors.green; // Con stock
    }
  }

  Color _getDefaultExpiryColor(DateTime expiryDate) {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry <= 1) return Colors.grey;
    if (daysUntilExpiry < 30) return Colors.red;
    if (daysUntilExpiry < 180) return Colors.yellow;
    if (daysUntilExpiry < 365) return Colors.green;
    return Colors.lightGreen;
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
                    widget.producto.descripcion ?? 'Sin descripción',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  
                  const Divider(height: 32),
                  
                  ProductInfoRow(
                    label: 'Serie:', 
                    value: widget.producto.serie,
                    icon: Icons.qr_code,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ProductInfoRow(
                    label: 'ID Producto:', 
                    value: widget.producto.numerodeproducto.toString(),
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
                    value: _formatDate(widget.producto.fechacaducidad),
                    icon: Icons.calendar_today,
                    color: expiryColor,
                  ),
                  
                  const SizedBox(height: 16),

                  ProductInfoRow(
                    label: 'Cantidad:', 
                    value: widget.producto.cantidad.toString(),
                    icon: Icons.inventory,
                    color: stockColor,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ProductInfoRow(
                    label: 'Código de almacén:', 
                    value: widget.producto.codigoalmacen.toString(),
                    icon: Icons.warehouse,
                  ),
                ],
              ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
