import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget que captura eventos de teclado para detectar escaneos de códigos de barras
/// provenientes de escáneres de hardware genéricos. Procesa los caracteres recibidos
/// y notifica cuando se ha completado un escaneo.

class HardwareScannerListener extends StatefulWidget {
  /// Widget hijo que será envuelto por el listener del escáner
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

  /// Constructor del widget HardwareScannerListener
  /// @param [child] Widget hijo que será envuelto por el listener
  /// @param [onBarcodeScanned] Función que se ejecuta cuando se detecta un código
  /// @param [scannerEndChar] Caracter que indica el final de un escaneo
  /// @param [scanTimeout] Tiempo máximo entre pulsaciones de tecla
  const HardwareScannerListener({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
    this.scannerEndChar = '\n',
    this.scanTimeout = 100,
  });

  /// Crea el estado mutable para este widget
  @override
  State<HardwareScannerListener> createState() => _HardwareScannerListenerState();
}

/// Estado interno del widget HardwareScannerListener
/// Maneja la lógica de captura y procesamiento de eventos de teclado
class _HardwareScannerListenerState extends State<HardwareScannerListener> {
  /// Caracteres acumulados durante el proceso de escaneo
  String _scannedChars = '';
  /// Marca de tiempo de la última pulsación de tecla detectada
  /// Puede ser null si no se ha detectado ninguna pulsación
  DateTime? _lastScanTime;
  /// Nodo de enfoque para capturar eventos de teclado
  FocusNode _focusNode = FocusNode();

  /// Inicializa el estado del widget
  /// Crea un nuevo nodo de enfoque
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  /// Libera recursos cuando el widget se elimina
  /// Libera el nodo de enfoque
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Reinicia el estado del escáner
  /// Limpia los caracteres acumulados y elimina la marca de tiempo
  void _resetScanner() {
    _scannedChars = '';
    _lastScanTime = null;
  }

  /// Procesa un evento de teclado para detectar códigos de barras
  /// Acumula caracteres y detecta cuando se ha completado un escaneo
  /// @param [event] Evento de teclado a procesar
  void _processKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }

    final now = DateTime.now();
    if (_lastScanTime != null) {
      final timeDiff = now.difference(_lastScanTime!).inMilliseconds;
      if (timeDiff > widget.scanTimeout) {
        _resetScanner();
      }
    }
    _lastScanTime = now;

    String? char;
    if (event.logicalKey == LogicalKeyboardKey.enter || 
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      char = widget.scannerEndChar;
    } else {
      char = event.character;
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

  /// Construye el widget KeyboardListener que captura eventos de teclado
  /// y procesa las pulsaciones para detectar códigos de barras
  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _processKeyEvent,
      autofocus: true,
      child: widget.child,
    );
  }
}
