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
      alignment: Alignment.center,
      child: Text(
        '$stock',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: isSmallScreen ? 11 : null,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
