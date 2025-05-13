import 'package:flutter/material.dart';

class ManualCodeInput extends StatefulWidget {
  final Function(String) onCodeSubmitted;
  final VoidCallback onClose;

  const ManualCodeInput({
    super.key,
    required this.onCodeSubmitted,
    required this.onClose,
  });

  @override
  State<ManualCodeInput> createState() => _ManualCodeInputState();
}

class _ManualCodeInputState extends State<ManualCodeInput> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _textFieldFocusNode = FocusNode();

  DateTime _lastInputTime = DateTime.now();
  bool _processingBarcode = false;
  int _lastTextLength = 0;

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.requestFocus();

    _controller.addListener(_checkForScannerInput);
  }

  String _lastScannedCode = '';

  void _checkForScannerInput() {
    if (_processingBarcode) return;

    final now = DateTime.now();
    final text = _controller.text;

    if (text.isEmpty) {
      _lastInputTime = now;
      _lastTextLength = 0;
      return;
    }

    final timeDiff = now.difference(_lastInputTime).inMilliseconds;
    _lastInputTime = now;

    final textLengthDiff = text.length - _lastTextLength;
    _lastTextLength = text.length;

    if (timeDiff < 50 && textLengthDiff > 0) {
      debugPrint(
        'Posible escaneo detectado: $text (tiempo: $timeDiff ms, caracteres añadidos: $textLengthDiff)',
      );

      _lastScannedCode = text;

      _processingBarcode = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        final currentText = _controller.text;

        if (currentText == _lastScannedCode) {
          debugPrint('Procesando código escaneado directamente: $currentText');

          final codeToSubmit = currentText;
          _controller.clear();

          widget.onCodeSubmitted(codeToSubmit);
        }

        _processingBarcode = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_checkForScannerInput);
    _controller.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _submitCode() {
    if (_formKey.currentState!.validate()) {
      final code = _controller.text.trim();
      widget.onCodeSubmitted(code);
      _controller.clear();
      _textFieldFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(7),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.keyboard, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Text(
                    'Código de barras',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: widget.onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextFormField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Ingrese o escanee el código',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.text,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Ingrese un código';
                        //   }
                        //   return null;
                        // },
                        autofocus: true,
                        focusNode: _textFieldFocusNode,
                        style: const TextStyle(fontSize: 14),
                        onFieldSubmitted: (_) => _submitCode(),
                        onChanged: (value) {
                          debugPrint('TextField value changed: "$value"');

                          if (value.contains('\n') || value.contains('\r')) {
                            debugPrint(
                              'PDA scan detected with return character',
                            );
                            final cleanCode = value
                                .replaceAll('\n', '')
                                .replaceAll('\r', '');
                            _controller.text = cleanCode;

                            debugPrint('Auto-submitting code: $cleanCode');
                            Future.microtask(() => _submitCode());
                          } else if (value.isNotEmpty &&
                              value.codeUnitAt(value.length - 1) == 13) {
                            debugPrint(
                              'PDA scan detected with ASCII 13 (CR) at the end',
                            );
                            _controller.text = value.substring(
                              0,
                              value.length - 1,
                            );
                            Future.microtask(() => _submitCode());
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 24,
                    child: ElevatedButton(
                      onPressed: _submitCode,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Añadir',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
