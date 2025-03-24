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
              color: _getColorForExpiryDate(producto.fechacaducidad),
            ),
            
            const SizedBox(height: 16),

            ProductInfoRow(
              label: 'Cantidad:', 
              value: producto.cantidad.toString(),
              icon: Icons.inventory,
              color: _getColorForStock(producto.cantidad),
            ),
            
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

  Color _getColorForExpiryDate(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    
    if (difference <= 1) {
      return Colors.grey[800]!.withValues(alpha: 0.3); // <= 1 día
    } else if (difference < 30) {
      return Colors.red[400]!.withValues(alpha: 0.3); // < 1 mes
    } else if (difference < 90) {
      return const Color.fromARGB(255, 228, 137, 1).withValues(alpha: 0.3); // < 3 meses
    } else if (difference < 180) {
      return const Color.fromARGB(255, 255, 230, 0).withValues(alpha: 0.3); // < 6 meses
    } else if (difference < 365) {
      return const Color.fromARGB(255, 125, 248, 129).withValues(alpha: 0.3); // > 6 meses
    } else {
      return const Color.fromARGB(255, 18, 143, 24).withValues(alpha: 0.3); // > 1 año
    }
  }
  
  Color _getColorForStock(int stock) {
    if (stock <= 0) {
      return Colors.red[400]!.withValues(alpha: 0.3); // Sin stock
    } else {
      return Colors.green[400]!.withValues(alpha: 0.3); // Con stock
    }
  }
}
