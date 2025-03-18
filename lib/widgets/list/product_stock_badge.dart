import 'package:flutter/material.dart';

class ProductStockBadge extends StatelessWidget {
  final int stock;

  const ProductStockBadge({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColorForStock(stock),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$stock',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColorForStock(int stock) {
    if (stock <= 0) {
      return Colors.red[400]!.withValues(alpha: 0.3); // Sin stock
    } else {
      return Colors.green[400]!.withValues(alpha: 0.3); // Con stock
    }
  }
}
