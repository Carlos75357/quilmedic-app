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
              height: screenSize.height * 0.3,
              width: double.infinity,
              child: MobileScanner(
                controller: controller,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      onBarcodeDetected(barcode);
                      break;
                    }
                  }
                },
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
          // Guía visual para el escaneo de códigos de barras
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            width: screenSize.width * 0.7,
            height: 100,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
