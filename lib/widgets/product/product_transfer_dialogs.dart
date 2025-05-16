import 'package:flutter/material.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';

/// Clase utilitaria que proporciona diálogos para el proceso de traslado de productos
/// Contiene métodos estáticos para mostrar diferentes diálogos relacionados con
/// la selección de hospital destino, confirmación y envío de solicitudes por email

class ProductTransferDialogs {
  /// Muestra un diálogo para seleccionar el hospital destino del traslado
  /// 
  /// @param context Contexto de la aplicación para mostrar el diálogo
  /// @param hospitales Lista de hospitales disponibles como destino
  /// @param onHospitalSelected Función que se ejecuta cuando se selecciona un hospital
  /// @param onCancel Función que se ejecuta cuando se cancela la operación
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

  /// Muestra un diálogo de confirmación para el traslado de productos
  /// 
  /// @param context Contexto de la aplicación para mostrar el diálogo
  /// @param mensaje Mensaje de confirmación a mostrar
  /// @param onConfirm Función que se ejecuta cuando se confirma la operación
  /// @param onCancel Función que se ejecuta cuando se cancela la operación
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
  
  /// Muestra un diálogo para solicitar el traslado de un producto por email
  /// Permite seleccionar el hospital destino y añadir comentarios opcionales
  /// 
  /// @param context Contexto de la aplicación para mostrar el diálogo
  /// @param producto Producto que se desea trasladar
  /// @param hospitales Lista de hospitales disponibles como destino
  /// @param onSendEmail Función que se ejecuta cuando se envía la solicitud
  /// @param onCancel Función que se ejecuta cuando se cancela la operación
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
                'Producto: ${producto.description ?? producto.productcode}',
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
