import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HardwareScannerListener extends StatefulWidget {
  final Widget child;
  
  final Function(String) onBarcodeScanned;
  
  final String scannerEndChar;
  
  final int scanTimeout;

  const HardwareScannerListener({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
    this.scannerEndChar = '\n',
    this.scanTimeout = 100,
  });

  @override
  State<HardwareScannerListener> createState() => _HardwareScannerListenerState();
}

class _HardwareScannerListenerState extends State<HardwareScannerListener> {
  String _scannedChars = '';
  DateTime? _lastScanTime;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _resetScanner() {
    _scannedChars = '';
    _lastScanTime = null;
  }

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
