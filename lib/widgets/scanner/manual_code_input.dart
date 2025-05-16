import 'package:flutter/material.dart';

/// Widget que permite la entrada manual de códigos de barras
/// También detecta automáticamente cuando se utiliza un escáner de códigos
/// de barras físico, procesando la entrada rápida como un escaneo

class ManualCodeInput extends StatefulWidget {
  /// Función que se ejecuta cuando se envía un código
  /// Recibe el código como parámetro
  final Function(String) onCodeSubmitted;
  /// Función que se ejecuta cuando se cierra el campo de entrada
  final VoidCallback onClose;

  /// Constructor del widget ManualCodeInput
  /// @param onCodeSubmitted Función que se ejecuta al enviar un código
  /// @param onClose Función que se ejecuta al cerrar el campo de entrada
  const ManualCodeInput({
    super.key,
    required this.onCodeSubmitted,
    required this.onClose,
  });

  /// Crea el estado mutable para este widget
  @override
  State<ManualCodeInput> createState() => _ManualCodeInputState();
}

/// Estado interno del widget ManualCodeInput
/// Maneja la lógica de entrada de códigos y detección de escaneo
class _ManualCodeInputState extends State<ManualCodeInput> {
  /// Controlador para el campo de texto de entrada de códigos
  final TextEditingController _controller = TextEditingController();
  /// Clave para acceder y validar el formulario
  final _formKey = GlobalKey<FormState>();
  /// Nodo de enfoque para el campo de texto
  final FocusNode _textFieldFocusNode = FocusNode();

  /// Marca de tiempo de la última entrada de texto
  /// Utilizado para detectar si la entrada es de un escáner
  DateTime _lastInputTime = DateTime.now();
  /// Indica si actualmente se está procesando un código de barras
  bool _processingBarcode = false;
  /// Longitud del texto en la última comprobación
  /// Utilizado para detectar cambios rápidos en la entrada
  int _lastTextLength = 0;

  /// Inicializa el estado del widget
  /// Configura el enfoque inicial y los listeners
  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.requestFocus();

    _controller.addListener(_checkForScannerInput);
  }

  /// Último código escaneado
  /// Almacena temporalmente el código para verificar si cambia
  String _lastScannedCode = '';

  /// Detecta si la entrada de texto proviene de un escáner de códigos de barras
  /// Analiza la velocidad y patrón de entrada para determinar si es un escaneo
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

      _lastScannedCode = text;

      _processingBarcode = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        final currentText = _controller.text;

        if (currentText == _lastScannedCode) {
          final codeToSubmit = currentText;
          _controller.clear();

          widget.onCodeSubmitted(codeToSubmit);
        }

        _processingBarcode = false;
      });
    }
  }

  /// Libera recursos cuando el widget se elimina
  /// Elimina listeners y controladores
  @override
  void dispose() {
    _controller.removeListener(_checkForScannerInput);
    _controller.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  /// Procesa y envía el código ingresado
  /// Valida el formulario, envía el código y limpia el campo
  void _submitCode() {
    if (_formKey.currentState!.validate()) {
      final code = _controller.text.trim();
      widget.onCodeSubmitted(code);
      _controller.clear();
      _textFieldFocusNode.requestFocus();
    }
  }

  /// Construye la interfaz del campo de entrada manual
  /// Muestra un campo de texto con un botón para enviar el código
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
                        autofocus: true,
                        focusNode: _textFieldFocusNode,
                        style: const TextStyle(fontSize: 14),
                        onFieldSubmitted: (_) => _submitCode(),
                        onChanged: (value) {

                          if (value.contains('\n') || value.contains('\r')) {
                            final cleanCode = value
                                .replaceAll('\n', '')
                                .replaceAll('\r', '');
                            _controller.text = cleanCode;

                            Future.microtask(() => _submitCode());
                          } else if (value.isNotEmpty &&
                              value.codeUnitAt(value.length - 1) == 13) {
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
