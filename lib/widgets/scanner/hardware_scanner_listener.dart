import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that listens for hardware barcode scanner input
/// and passes it to a callback function when a complete scan is detected.
class HardwareScannerListener extends StatefulWidget {
  /// The child widget to render
  final Widget child;
  
  /// Callback function that is called when a barcode is scanned
  final Function(String) onBarcodeScanned;
  
  /// The character that marks the end of a barcode scan (usually a return/enter key)
  final String scannerEndChar;
  
  /// Maximum time between keystrokes to be considered part of the same scan (milliseconds)
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

  void _processKeyEvent(RawKeyEvent event) {
    // Only process key down events
    if (event is! RawKeyDownEvent) {
      return;
    }

    // Check if this is part of a scan based on timing
    final now = DateTime.now();
    if (_lastScanTime != null) {
      final timeDiff = now.difference(_lastScanTime!).inMilliseconds;
      if (timeDiff > widget.scanTimeout) {
        // Too much time has passed, reset the scanner
        _resetScanner();
      }
    }
    _lastScanTime = now;

    // Get the character from the key event
    String? char;
    if (event.logicalKey == LogicalKeyboardKey.enter || 
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      char = widget.scannerEndChar;
    } else {
      // Try to get the character from the event
      char = event.character;
    }

    if (char != null) {
      if (char == widget.scannerEndChar) {
        // End of scan detected, process the barcode
        if (_scannedChars.isNotEmpty) {
          widget.onBarcodeScanned(_scannedChars);
        }
        _resetScanner();
      } else {
        // Add character to the current scan
        _scannedChars += char;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _processKeyEvent,
      autofocus: true,
      child: widget.child,
    );
  }
}
