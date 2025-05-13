import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class DatalogicScannerListener extends StatefulWidget {
  final Widget child;
  final Function(String) onBarcodeScanned;

  const DatalogicScannerListener({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
  });

  @override
  State<DatalogicScannerListener> createState() => _DatalogicScannerListenerState();
}

class _DatalogicScannerListenerState extends State<DatalogicScannerListener> {
  final FocusNode _focusNode = FocusNode();
  String _scannedChars = '';
  DateTime _lastScanTime = DateTime.now();
  Timer? _focusTimer;

  final int _scanTimeout = 100;

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
    _focusTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

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

  void _findTextFieldAndSubmit(BuildContext context) {
    String? foundCode;

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

  void _findAddButton(BuildContext context, String? scannedCode) {
    bool buttonFound = false;

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
