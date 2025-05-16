import 'package:flutter/material.dart';

/// Widget que muestra el encabezado de una sección de lista de productos
/// Presenta el título de la sección y la cantidad de productos
/// con un estilo visual personalizable mediante colores

class ProductListHeader extends StatelessWidget {
  /// Título de la sección de productos a mostrar
  final String title;
  /// Cantidad de productos en la sección
  final int count;
  /// Color para personalizar el estilo visual del encabezado
  final Color color;

  /// Constructor del widget ProductListHeader
  /// @param title Título de la sección
  /// @param count Cantidad de productos
  /// @param color Color para el encabezado
  const ProductListHeader({
    super.key,
    required this.title,
    required this.count,
    required this.color,
  });

  /// Construye la interfaz del encabezado de la sección
  /// Adapta el tamaño del texto según el ancho de la pantalla
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title ($count)',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
