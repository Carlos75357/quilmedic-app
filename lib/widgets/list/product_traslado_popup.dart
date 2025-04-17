import 'package:flutter/material.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/utils/theme.dart';

class ProductTrasladoPopup extends StatefulWidget {
  final List<Producto> productos;
  final List<Hospital> hospitales;
  final int hospitalIdOrigen;
  final Function(int hospitalId, String hospitalName) onTrasladoConfirmado;

  const ProductTrasladoPopup({
    super.key,
    required this.productos,
    required this.hospitales,
    required this.hospitalIdOrigen,
    required this.onTrasladoConfirmado,
  });

  @override
  State<ProductTrasladoPopup> createState() => _ProductTrasladoPopupState();
}

class _ProductTrasladoPopupState extends State<ProductTrasladoPopup> {
  int? selectedHospitalId;
  String? selectedHospitalName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            'Trasladar productos',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Seleccione el hospital destino para trasladar todos los productos',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Hospital Destino',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: const Icon(Icons.local_hospital_outlined),
            ),
            items: widget.hospitales
                .where((h) => h.id != widget.hospitalIdOrigen)
                .map((hospital) {
              return DropdownMenuItem<int>(
                value: hospital.id,
                child: Text(hospital.description),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedHospitalId = value;
                if (value != null) {
                  selectedHospitalName = widget.hospitales
                      .firstWhere((h) => h.id == value)
                      .description;
                }
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (selectedHospitalId != null && selectedHospitalName != null) {
              Navigator.of(context).pop();

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.swap_horiz, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Trasladando productos'),
                      ],
                    ),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Procesando traslado de productos...'),
                      ],
                    ),
                  );
                },
              );

              // Llamar a la función de callback para realizar el traslado
              widget.onTrasladoConfirmado(
                selectedHospitalId!,
                selectedHospitalName!,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Debes seleccionar un hospital destino',
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          icon: const Icon(Icons.send),
          label: const Text('Enviar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductTrasladoLoadingDialog extends StatelessWidget {
  const ProductTrasladoLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.local_hospital, color: Colors.blue),
          SizedBox(width: 8),
          Text('Cargando hospitales'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando lista de hospitales...'),
        ],
      ),
    );
  }
}