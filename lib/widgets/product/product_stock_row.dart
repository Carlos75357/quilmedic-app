import 'package:flutter/material.dart';

/// Widget que muestra la información de stock de un producto
/// Presenta el nivel de stock actual con un formato visual destacado
/// para facilitar su visualización en la pantalla de detalle

class ProductStockRow extends StatelessWidget {
  /// Cantidad actual en stock del producto
  final int stock;

  /// Constructor del widget ProductStockRow
  const ProductStockRow({
    super.key,
    required this.stock,
  });

  /// Construye la interfaz de la fila de stock
  /// Muestra un icono de inventario y el valor numérico del stock
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.inventory,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stock:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  '$stock',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
