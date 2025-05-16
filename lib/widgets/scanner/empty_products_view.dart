import 'package:flutter/material.dart';

/// Widget que muestra un mensaje cuando no hay productos escaneados
/// Presenta un icono y texto informativo para indicar al usuario
/// que debe escanear productos

class EmptyProductsView extends StatelessWidget {
  /// Constructor del widget EmptyProductsView
  const EmptyProductsView({super.key});

  /// Construye la interfaz del mensaje de lista vacía
  /// Muestra un icono de escáner y mensajes informativos
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay productos escaneados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Escanea un código de barras para comenzar',
                style: TextStyle(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
