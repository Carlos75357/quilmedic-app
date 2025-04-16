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
  
  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.requestFocus();
  }
  
  @override
  void dispose() {
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese un código';
                          }
                          return null;
                        },
                        autofocus: true,
                        focusNode: _textFieldFocusNode,
                        style: const TextStyle(fontSize: 14),
                        onFieldSubmitted: (_) => _submitCode(),
                        onChanged: (value) {
                          if (value.isNotEmpty && value.endsWith('\n')) {
                            _controller.text = value.replaceAll('\n', '');
                            _submitCode();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _submitCode,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text('Añadir', style: TextStyle(fontSize: 13)),
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
