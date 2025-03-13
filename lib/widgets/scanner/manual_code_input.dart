import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ManualCodeInput extends StatefulWidget {
  final Function(String) onCodeSubmitted;
  
  const ManualCodeInput({
    Key? key,
    required this.onCodeSubmitted,
  }) : super(key: key);

  @override
  State<ManualCodeInput> createState() => _ManualCodeInputState();
}

class _ManualCodeInputState extends State<ManualCodeInput> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ingresar código manualmente',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Código de barras',
                  hintText: 'Ingrese el código numérico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un código';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'El código debe contener solo números';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onCodeSubmitted(_controller.text);
                    _controller.clear();
                  }
                },
                child: const Text('Añadir producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
