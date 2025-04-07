import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final FocusNode _keyListenerFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.requestFocus();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _textFieldFocusNode.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }
  
  void _submitCode() {
    if (_formKey.currentState!.validate()) {
      final code = _controller.text.trim();
      widget.onCodeSubmitted(code);
      // Limpiamos el campo para permitir escanear de nuevo
      _controller.clear();
      // Mantenemos el foco para seguir escaneando
      _textFieldFocusNode.requestFocus();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Ingresar código manualmente',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: isSmallScreen ? 14 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                    tooltip: 'Cerrar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: isSmallScreen ? 18 : 24,
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Código de barras',
                  hintText: 'Ingrese o escanee el código',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.qr_code,
                    size: isSmallScreen ? 18 : 24,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  helperText: null, // Eliminamos el texto de ayuda para ahorrar espacio
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un código';
                  }
                  return null;
                },
                autofocus: true,
                focusNode: _textFieldFocusNode,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                onFieldSubmitted: (_) => _submitCode(),
                onChanged: (value) {
                  // Detectar si el último carácter es un retorno de carro (escáner PDA)
                  if (value.isNotEmpty && value.endsWith('\n')) {
                    // Eliminar el retorno de carro antes de procesar
                    _controller.text = value.replaceAll('\n', '');
                    _submitCode();
                  }
                },
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              SizedBox(
                height: isSmallScreen ? 36 : 40,
                child: ElevatedButton(
                  onPressed: _submitCode,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 4 : 8,
                    ),
                  ),
                  child: Text(
                    'Añadir producto',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

