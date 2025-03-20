import 'package:flutter/material.dart';

class ProductExpiryBadge extends StatelessWidget {
  final DateTime expiryDate;
  final String formattedDate;

  const ProductExpiryBadge({
    super.key,
    required this.expiryDate,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColorForExpiryDate(expiryDate),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        formattedDate,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
}
