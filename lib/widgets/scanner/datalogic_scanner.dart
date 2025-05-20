import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget que captura eventos de teclado para detectar escaneos de códigos de barras
/// provenientes de un escáner Datalogic. Procesa los caracteres recibidos
/// y notifica cuando se ha completado un escaneo.

class DatalogicScanner extends StatefulWidget {
  /// Widget hijo que será envuelto por el escáner
  final Widget child;

  /// Función que se ejecuta cuando se detecta un código de barras escaneado
  /// Recibe el código escaneado como parámetro
  final Function(String) onBarcodeScanned;

  /// Caracter que indica el final de un escaneo
  /// Por defecto es el salto de línea (\n)
  final String scannerEndChar;

  /// Tiempo máximo en milisegundos entre pulsaciones de tecla
  /// para considerarlas parte del mismo escaneo
  final int scanTimeout;

  /// Constructor del widget DatalogicScanner
  /// @param [child] Widget hijo que será envuelto por el escáner
  /// @param [onBarcodeScanned] Función que se ejecuta cuando se detecta un código
  /// @param [scannerEndChar] Caracter que indica el final de un escaneo
  /// @param [scanTimeout] Tiempo máximo entre pulsaciones de tecla
  const DatalogicScanner({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
    this.scannerEndChar = '\n',
    this.scanTimeout = 100,
  });

  /// Crea el estado mutable para este widget
  @override
  State<DatalogicScanner> createState() => _DatalogicScannerState();
}

/// Estado interno del widget DatalogicScanner
/// Maneja la lógica de captura y procesamiento de eventos de teclado
class _DatalogicScannerState extends State<DatalogicScanner> {
  /// Caracteres acumulados durante el proceso de escaneo
  String _scannedChars = '';
  /// Marca de tiempo de la última pulsación de tecla detectada
  DateTime _lastScanTime = DateTime.now();
  /// Nodo de enfoque para capturar eventos de teclado
  final FocusNode _focusNode = FocusNode();

  /// Inicializa el estado del widget
  /// Solicita el enfoque para capturar eventos de teclado
  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  /// Reinicia el estado del escáner
  /// Limpia los caracteres acumulados y actualiza la marca de tiempo
  void _resetScanner() {
    _scannedChars = '';
    _lastScanTime = DateTime.now();
  }

  /// Libera recursos cuando el widget se elimina
  /// Libera el nodo de enfoque
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Construye el widget KeyboardListener que captura eventos de teclado
  /// y procesa las pulsaciones para detectar códigos de barras
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
      ],
    );
  }
}
