import 'package:flutter/material.dart';

class ProductStockBadge extends StatelessWidget {
  final int stock;
  final bool isSmallScreen;

  const ProductStockBadge({
    super.key,
    required this.stock,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 4 : 8, 
        vertical: isSmallScreen ? 2 : 4
      ),
      decoration: BoxDecoration(
        color: _getColorForStock(stock),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$stock',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: isSmallScreen ? 11 : null,
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
