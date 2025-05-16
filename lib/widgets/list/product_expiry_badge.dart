import 'package:flutter/material.dart';

/// Widget que muestra la fecha de caducidad de un producto
/// Presenta la fecha en un formato legible dentro de un contenedor
/// que puede adaptarse a diferentes tamaños de pantalla.

class ProductExpiryBadge extends StatelessWidget {
  /// Fecha de caducidad del producto
  final DateTime expiryDate;
  /// Fecha formateada como texto para mostrar (ej: "31/12/2025")
  final String formattedDate;
  /// Indica si se debe usar un tamaño más compacto para pantallas pequeñas
  final bool isSmallScreen;

  /// Constructor del widget ProductExpiryBadge
  const ProductExpiryBadge({
    super.key,
    required this.expiryDate,
    required this.formattedDate,
    this.isSmallScreen = false,
  });

  /// Construye la interfaz del badge de fecha de caducidad
  /// adaptando su tamaño según la configuración
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 4 : 6,
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
