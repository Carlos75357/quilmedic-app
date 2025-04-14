import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

class RecentScannedProductsPanel extends StatefulWidget {
  final List<ProductoEscaneado> productos;
  final VoidCallback onClose;

  const RecentScannedProductsPanel({
    Key? key,
    required this.productos,
    required this.onClose,
  }) : super(key: key);

  @override
  State<RecentScannedProductsPanel> createState() => _RecentScannedProductsPanelState();
}

class _RecentScannedProductsPanelState extends State<RecentScannedProductsPanel> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
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
