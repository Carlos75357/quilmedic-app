import 'package:flutter/material.dart';

/// Botón para guardar productos escaneados
/// Muestra un botón de acción principal en la parte inferior de la pantalla
/// que permite al usuario guardar los productos escaneados

class SaveButton extends StatelessWidget {
  /// Función que se ejecuta cuando se presiona el botón
  final VoidCallback onPressed;
  /// Indica si hay conexión a Internet disponible
  /// Si no hay conexión, el botón podría mostrar un estado visual diferente
  final bool hayConexion;
  
  /// Constructor del widget SaveButton
  /// @param onPressed Función que se ejecuta al presionar el botón
  /// @param hayConexion Indica si hay conexión a Internet (por defecto es true)
  const SaveButton({
    super.key,
    required this.onPressed,
    this.hayConexion = true,
  });

  /// Construye la interfaz del botón de guardar
  /// Aplica estilos visuales según el tema de la aplicación
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.save),
        label: const Text('GUARDAR PRODUCTOS'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
