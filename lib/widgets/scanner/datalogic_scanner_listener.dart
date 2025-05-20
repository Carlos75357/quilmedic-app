import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Widget que escucha eventos de teclado para detectar escaneos de códigos de barras
/// provenientes de un escáner Datalogic. Captura las pulsaciones de teclas,
/// las procesa y notifica cuando se ha completado un escaneo.

class DatalogicScannerListener extends StatefulWidget {
  /// Widget hijo que será envuelto por el listener del escáner
  final Widget child;
  /// Función que se ejecuta cuando se detecta un código de barras escaneado
  /// Recibe el código escaneado como parámetro
  final Function(String) onBarcodeScanned;

  /// Constructor del widget DatalogicScannerListener
  /// @param [child] Widget hijo que será envuelto por el listener
  /// @param [onBarcodeScanned] Función que se ejecuta cuando se detecta un código
  const DatalogicScannerListener({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
  });

  /// Crea el estado mutable para este widget
  @override
  State<DatalogicScannerListener> createState() => _DatalogicScannerListenerState();
}

/// Estado interno del widget DatalogicScannerListener
/// Maneja la lógica de captura y procesamiento de eventos de teclado
class _DatalogicScannerListenerState extends State<DatalogicScannerListener> {
  /// Nodo de enfoque para capturar eventos de teclado
  final FocusNode _focusNode = FocusNode();
  /// Caracteres acumulados durante el proceso de escaneo
  String _scannedChars = '';
  /// Marca de tiempo de la última pulsación de tecla detectada
  DateTime _lastScanTime = DateTime.now();
  /// Temporizador para gestionar el enfoque del escáner
  Timer? _focusTimer;

  /// Tiempo máximo en milisegundos entre pulsaciones de tecla para considerarlas parte del mismo escaneo
  final int _scanTimeout = 100;

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
  /// Cancela temporizadores y libera el nodo de enfoque
  @override
  void dispose() {
    _focusTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  /// Construye el widget KeyboardListener que captura eventos de teclado
  /// y procesa las pulsaciones para detectar códigos de barras
  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (keyEvent) {
        if (keyEvent is KeyDownEvent) {
          final now = DateTime.now();
          final timeDiff = now.difference(_lastScanTime).inMilliseconds;

          if (timeDiff > _scanTimeout && _scannedChars.isNotEmpty) {
            _resetScanner();
          }
          _lastScanTime = now;

          if (keyEvent.logicalKey == LogicalKeyboardKey.enter ||
              keyEvent.logicalKey == LogicalKeyboardKey.numpadEnter) {
            if (_scannedChars.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onBarcodeScanned(_scannedChars);
              });

              _resetScanner();
            }
          } else {
            String? char = keyEvent.character;

            if (char == null || char.isEmpty) {
              final keyLabel = keyEvent.logicalKey.keyLabel;
              if (keyLabel.length == 1) {
                char = keyLabel;
              }
            }

            if (char != null && char.isNotEmpty) {
              _scannedChars += char;
            }
          }
        }

        if (keyEvent is KeyUpEvent) {
          if (keyEvent.logicalKey.keyLabel == 'STB Input') {
            Future.delayed(const Duration(milliseconds: 100), () {
              _findTextFieldAndSubmit(context);
            });
          }
        }
      },
      autofocus: true,
      child: widget.child,
    );
  }

  /// Busca campos de texto en el árbol de widgets que puedan contener un código escaneado
  /// y luego intenta encontrar y activar el botón de añadir
  void _findTextFieldAndSubmit(BuildContext context) {
    String? foundCode;

    /// Función recursiva que busca widgets EditableText en el árbol de elementos
    /// y extrae el texto si cumple con los criterios de un código de barras
    void findTextFields(Element element) {
      if (element.widget is EditableText) {
        final EditableText textField = element.widget as EditableText;
        final String currentValue = textField.controller.text;

        if (currentValue.isNotEmpty && currentValue.length > 3) {
          foundCode = currentValue;
          return;
        }
      }

      if (foundCode == null) {
        element.visitChildren(findTextFields);
      }
    }

    context.visitChildElements(findTextFields);

    if (foundCode != null) {
      _findAddButton(context, foundCode);
    }
  }

  /// Busca un botón "Añadir" en el árbol de widgets y lo activa
  /// @param scannedCode Código escaneado que se procesará al pulsar el botón
  void _findAddButton(BuildContext context, String? scannedCode) {
    bool buttonFound = false;

    /// Función recursiva que busca un botón ElevatedButton con el texto "Añadir"
    /// y lo activa cuando lo encuentra
    void findButton(Element element) {
      if (buttonFound) return;

      if (element.widget is ElevatedButton) {
        final ElevatedButton button = element.widget as ElevatedButton;

        if (button.child is Text) {
          final Text text = button.child as Text;
          if (text.data == 'Añadir') {
            buttonFound = true;
            button.onPressed?.call();
            return;
          }
        }
      }

      if (!buttonFound) {
        element.visitChildren(findButton);
      }
    }

    context.visitChildElements(findButton);
  }
}
