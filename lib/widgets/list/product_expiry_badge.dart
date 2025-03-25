import 'package:flutter/material.dart';

class ProductExpiryBadge extends StatelessWidget {
  final DateTime expiryDate;
  final String formattedDate;
  final bool isSmallScreen;

  const ProductExpiryBadge({
    super.key,
    required this.expiryDate,
    required this.formattedDate,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8, 
        vertical: isSmallScreen ? 4 : 6
      ),
      alignment: Alignment.center,
      child: Text(
        formattedDate,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: isSmallScreen ? 11 : 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
