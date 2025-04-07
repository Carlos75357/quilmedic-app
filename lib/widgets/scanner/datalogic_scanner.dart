import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class DatalogicScanner extends StatefulWidget {
  final Widget child;
  
  final Function(String) onBarcodeScanned;

  final String scannerEndChar;
  
  final int scanTimeout;

  const DatalogicScanner({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
    this.scannerEndChar = '\n',
    this.scanTimeout = 100,
  });

  @override
  State<DatalogicScanner> createState() => _DatalogicScannerState();
}

class _DatalogicScannerState extends State<DatalogicScanner> {
  String _scannedChars = '';
  DateTime _lastScanTime = DateTime.now();
  final FocusNode _focusNode = FocusNode();
  
  final MobileScannerController _scannerController = MobileScannerController();
  
  bool _isCameraScannerOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  void _resetScanner() {
    _scannedChars = '';
    _lastScanTime = DateTime.now();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scannerController.dispose();
    super.dispose();
  }
  
  void _showCameraScanner() {
    setState(() {
      _isCameraScannerOpen = true;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          setState(() {
            _isCameraScannerOpen = false;
          });
          return true;
        },
        child: Dialog(
          insetPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: const Text('Escanear código de barras'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _isCameraScannerOpen = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    actions: [
                      // Botón de ayuda que muestra instrucciones
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Ayuda'),
                              content: const Text(
                                'Apunta la cámara al código de barras para escanearlo.\n\n'
                                'Puedes escanear varios códigos consecutivamente.\n\n'
                                'Presiona el botón X para cerrar el escáner cuando hayas terminado.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Entendido'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    centerTitle: true,
                    elevation: 0,
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          controller: _scannerController,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            if (barcodes.isNotEmpty && _isCameraScannerOpen) {
                              final String? code = barcodes.first.rawValue;
                              if (code != null && code.isNotEmpty) {
                                debugPrint('Barcode scanned with camera: $code');
                                widget.onBarcodeScanned(code);
                                
                                // Mostrar un mensaje temporal en lugar de cerrar el escáner
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Código escaneado: $code'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(milliseconds: 1000),
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.only(
                                      bottom: 80,
                                      right: 20,
                                      left: 20,
                                    ),
                                  ),
                                );
                                
                                // Pausar brevemente el escáner para evitar escaneos duplicados
                                _scannerController.stop();
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (_isCameraScannerOpen) {
                                    _scannerController.start();
                                  }
                                });
                              }
                            }
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.red,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: 200,
                          height: 200,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Apunta la cámara al código de barras',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      if (_isCameraScannerOpen) {
        setState(() {
          _isCameraScannerOpen = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (keyEvent) {
            if (keyEvent is KeyDownEvent) {
              final now = DateTime.now();
              final timeDiff = now.difference(_lastScanTime).inMilliseconds;
              if (timeDiff > widget.scanTimeout && _scannedChars.isNotEmpty) {
                _resetScanner();
              }
              _lastScanTime = now;
              
              String? char;
              if (keyEvent.logicalKey == LogicalKeyboardKey.enter || 
                  keyEvent.logicalKey == LogicalKeyboardKey.numpadEnter) {
                char = widget.scannerEndChar;
              } else {
                char = keyEvent.character;
              }

              if (char != null) {
                if (char == widget.scannerEndChar) {
                  if (_scannedChars.isNotEmpty) {
                    debugPrint('Barcode scanned: $_scannedChars');
                    widget.onBarcodeScanned(_scannedChars);
                  }
                  _resetScanner();
                } else {
                  _scannedChars += char;
                }
              }
            }
          },
          autofocus: true,
          child: widget.child,
        ),
        
        Positioned(
          right: 16,
          bottom: 80,
          child: FloatingActionButton(
            heroTag: 'camera_scanner_button',
            mini: true,
            onPressed: _showCameraScanner,
            tooltip: 'Escanear con cámara',
            child: const Icon(Icons.qr_code_scanner),
          ),
        ),
      ],
    );
  }
}
