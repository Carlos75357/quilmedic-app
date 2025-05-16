import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

/// Widget que muestra un panel con los últimos productos escaneados
/// Presenta una lista desplazable con los códigos de barras recientemente
/// escaneados y permite cerrar el panel

class RecentScannedProductsPanel extends StatefulWidget {
  /// Lista de productos escaneados recientemente a mostrar
  final List<ProductoEscaneado> productos;
  /// Función que se ejecuta cuando se cierra el panel
  final VoidCallback onClose;

  /// Constructor del widget RecentScannedProductsPanel
  /// @param productos Lista de productos escaneados recientemente
  /// @param onClose Función que se ejecuta al cerrar el panel
  const RecentScannedProductsPanel({
    super.key,
    required this.productos,
    required this.onClose,
  });

  /// Crea el estado mutable para este widget
  @override
  State<RecentScannedProductsPanel> createState() => _RecentScannedProductsPanelState();
}

/// Estado interno del widget RecentScannedProductsPanel
class _RecentScannedProductsPanelState extends State<RecentScannedProductsPanel> {
  /// Construye la interfaz del panel de productos escaneados recientemente
  /// Muestra un encabezado con título y botón de cierre, seguido de una
  /// lista desplazable con los códigos de barras
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Últimos productos escaneados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.productos.length,
                itemBuilder: (context, index) {
                  final producto = widget.productos[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            producto.serialnumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
