import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ManualCodeInput extends StatefulWidget {
  final Function(String) onCodeSubmitted;
  
  const ManualCodeInput({
    super.key,
    required this.onCodeSubmitted,
  });

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
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ingresar código manualmente',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: isSmallScreen ? 14 : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Código de barras',
                  hintText: 'Ingrese el código',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.qr_code,
                    size: isSmallScreen ? 18 : 24,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un código';
                  }
                  return null;
                },
                autofocus: true,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onCodeSubmitted(_controller.text);
                    _controller.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                ),
                child: Text(
                  'Añadir producto',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
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
