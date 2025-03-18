import 'package:flutter/material.dart';
import 'package:quilmedic/domain/hospital.dart';

class ProductTransferDialogs {
  static void showHospitalSelectionDialog({
    required BuildContext context,
    required List<Hospital> hospitales,
    required Function(int) onHospitalSelected,
    required VoidCallback onCancel,
  }) {
    int? selectedHospitalId;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trasladar Producto'),
        content: DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Seleccionar Hospital Destino',
            border: OutlineInputBorder(),
          ),
          items: hospitales.map((hospital) {
            return DropdownMenuItem<int>(
              value: hospital.id,
              child: Text(hospital.nombre),
            );
          }).toList(),
          onChanged: (value) {
            selectedHospitalId = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (selectedHospitalId != null) {
                onHospitalSelected(selectedHospitalId!);
              }
            },
            child: const Text('Trasladar'),
          ),
        ],
      ),
    );
  }

  static void showConfirmationDialog({
    required BuildContext context,
    required String mensaje,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Traslado'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
