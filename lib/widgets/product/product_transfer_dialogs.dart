import 'package:flutter/material.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';

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
              child: Text(hospital.description),
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
  
  static void showEmailTransferDialog({
    required BuildContext context,
    required Producto producto,
    required List<Hospital> hospitales,
    required Function(int, String, String) onSendEmail,
    required VoidCallback onCancel,
  }) {
    int? selectedHospitalId;
    final TextEditingController commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar Traslado de Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Producto: ${producto.descripcion ?? producto.numerodeproducto}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta acción enviará un correo electrónico para solicitar el traslado del producto.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Hospital Destino',
                  border: OutlineInputBorder(),
                ),
                items: hospitales.map((hospital) {
                  return DropdownMenuItem<int>(
                    value: hospital.id,
                    child: Text(hospital.description),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedHospitalId = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comentarios (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
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
                final hospitalName = hospitales
                    .firstWhere((h) => h.id == selectedHospitalId)
                    .description;
                onSendEmail(
                  selectedHospitalId!,
                  hospitalName,
                  commentController.text,
                );
              }
            },
            child: const Text('Enviar Solicitud'),
          ),
        ],
      ),
    );
  }
}
