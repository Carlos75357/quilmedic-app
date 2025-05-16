import 'package:flutter/material.dart';

/// Widget que muestra una fila de información de producto con etiqueta y valor
/// Utilizado en la pantalla de detalle de producto para mostrar cada campo
/// de información con un icono, etiqueta y valor correspondiente

class ProductInfoRow extends StatelessWidget {
  /// Etiqueta o nombre del campo a mostrar
  final String label;
  /// Valor del campo (puede ser nulo, en cuyo caso se muestra 'No disponible')
  final String? value;
  /// Icono que representa visualmente el tipo de información
  final IconData icon;
  /// Color de fondo opcional para la fila
  final Color? color;

  /// Constructor del widget ProductInfoRow
  const ProductInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  /// Construye la interfaz de la fila de información
  /// Muestra un icono a la izquierda y la etiqueta con su valor a la derecha
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Ink(
      color: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'No disponible',
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
