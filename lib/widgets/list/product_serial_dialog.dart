import 'package:flutter/material.dart';

/// Widget que muestra un diálogo con la lista de códigos de barras no encontrados
/// Presenta una interfaz modal con la lista de números de serie que no pudieron
/// ser encontrados en el sistema, con opciones para cerrar el diálogo

class ProductSerialDialog extends StatelessWidget {
  /// Lista de números de serie que no fueron encontrados
  /// Puede ser null si no hay productos no encontrados
  final List<String>? notFounds;

  /// Constructor del widget ProductSerialDialog
  /// @param [notFounds] Lista de números de serie no encontrados
  const ProductSerialDialog({super.key, required this.notFounds});

  /// Construye la interfaz del diálogo de números de serie no encontrados
  /// Muestra un encabezado, una lista desplazable de códigos y botones de acción
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Row(
              children: [
                const Icon(Icons.qr_code, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Productos no encontrados (${notFounds?.length ?? 0})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(),
            // List of not found products
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child:
                  notFounds != null && notFounds!.isNotEmpty
                      ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: notFounds!.length,
                        itemBuilder: (context, index) {
                          final serialNumber = notFounds![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.qr_code,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    serialNumber,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'No encontrado',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                      : const Center(
                        child: Text('No hay productos no encontrados'),
                      ),
            ),
            const SizedBox(height: 16),
            // Close button at the bottom
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
