import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    super.dispose();
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
