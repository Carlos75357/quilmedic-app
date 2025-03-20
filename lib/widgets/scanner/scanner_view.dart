import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerView extends StatelessWidget {
  final MobileScannerController controller;
  final Function(Barcode) onBarcodeDetected;
  final VoidCallback onClose;
  
  const ScannerView({
    super.key,
    required this.controller,
    required this.onBarcodeDetected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scannerHeight = screenSize.height < 600 ? screenSize.height * 0.25 : screenSize.height * 0.3;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: scannerHeight,
              width: double.infinity,
              child: MobileScanner(
                controller: controller,
                onDetect: (capture) {
                  try {
                    if (capture.barcodes.isNotEmpty) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          onBarcodeDetected(barcode);
                          break;
                        }
                      }
                    }
                  } catch (e) {
                    debugPrint('Error en el escáner: $e');
                  }
                },
                errorBuilder: (context, error, child) {
                  return Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al iniciar la cámara',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: onClose,
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                scanWindow: Rect.fromCenter(
                  center: Offset(
                    screenSize.width / 2,
                    scannerHeight / 2,
                  ),
                  width: screenSize.width * 0.7,
                  height: 80,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: FloatingActionButton.small(
              onPressed: onClose,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 4,
              child: const Icon(Icons.close),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            width: screenSize.width * 0.7,
            height: 80,
            child: const Center(
              child: Text(
                'Coloque el código de barras aquí',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Colors.black54,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
