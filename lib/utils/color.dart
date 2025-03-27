import 'package:flutter/material.dart';

class ColorAlarm {
  static Color getColorForExpiryDate(DateTime expiryDate) {
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
      return const Color.fromARGB(255, 0, 252, 8).withValues(alpha: 0.3); // > 6 meses
    } else {
      return const Color.fromARGB(255, 18, 143, 24).withValues(alpha: 0.3); // > 1 año
    }
  }

  static Color getColorForStock(int stock) {
    if (stock <= 0) {
      return Colors.red[400]!.withValues(alpha: 0.3); // Sin stock
    } else {
      return Colors.green[400]!.withValues(alpha: 0.3); // Con stock
    }
  }
}