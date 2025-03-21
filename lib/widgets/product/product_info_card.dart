import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/widgets/product/product_info_row.dart';
import 'package:quilmedic/widgets/product/product_stock_row.dart';

class ProductInfoCard extends StatelessWidget {
  final Producto producto;

  const ProductInfoCard({
    super.key,
    required this.producto,
  });

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              producto.descripcion ?? 'Sin descripción',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            
            const Divider(height: 32),
            
            ProductInfoRow(
              label: 'Serie:', 
              value: producto.serie,
              icon: Icons.qr_code,
            ),
            
            const SizedBox(height: 16),
            
            ProductInfoRow(
              label: 'ID Producto:', 
              value: producto.numerodeproducto.toString(),
              icon: Icons.tag,
            ),
            
            const SizedBox(height: 16),
            
            ProductInfoRow(
              label: 'Lote:', 
              value: producto.numerolote.toString(),
              icon: Icons.inventory_2,
            ),
            
            const SizedBox(height: 16),
            
            ProductInfoRow(
              label: 'Fecha de caducidad:', 
              value: _formatDate(producto.fechacaducidad),
              icon: Icons.calendar_today,
            ),
            
            const SizedBox(height: 16),
            
            ProductStockRow(stock: producto.cantidad),
            
            const SizedBox(height: 16),
            
            ProductInfoRow(
              label: 'Código de almacén:', 
              value: producto.codigoalmacen.toString(),
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
