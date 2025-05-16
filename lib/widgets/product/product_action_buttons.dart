import 'package:flutter/material.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/ui/product/producto_detalle_bloc.dart';

/// Widget que muestra los botones de acción en la pantalla de detalle de producto
/// Proporciona botones para trasladar el producto y volver a la lista anterior

class ProductActionButtons extends StatelessWidget {
  /// Estado actual del BLoC de detalle de producto
  /// Permite habilitar/deshabilitar botones según el estado
  final ProductoDetalleState state;
  /// Función que se ejecuta cuando se presiona el botón de trasladar
  /// Recibe la lista de hospitales disponibles como destino
  final Function(List<Hospital>) onTrasladarPressed;
  /// Función que se ejecuta cuando se presiona el botón de volver
  /// Navega de regreso a la pantalla anterior
  final VoidCallback onVolverPressed;

  /// Constructor del widget ProductActionButtons
  const ProductActionButtons({
    super.key,
    required this.state,
    required this.onTrasladarPressed,
    required this.onVolverPressed,
  });

  /// Construye la interfaz de los botones de acción
  /// Muestra botones para trasladar el producto y volver a la lista
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ElevatedButton.icon(
        //   onPressed: state is HospitalesCargadosState
        //     ? () {
        //         final hospitalesState = state as HospitalesCargadosState;
        //         final List<Hospital> hospitales = List<Hospital>.from(hospitalesState.hospitales);
        //         onTrasladarPressed(hospitales);
        //       }
        //     : null,
        //   icon: const Icon(Icons.swap_horiz, size: 28),
        //   label: Text(
        //     state is TrasladandoProductoState
        //       ? 'Trasladando...'
        //       : 'Trasladar de almacén',
        //     style: const TextStyle(fontSize: 18),
        //   ),
        //   style: ElevatedButton.styleFrom(
        //     padding: const EdgeInsets.symmetric(vertical: 16),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //   ),
        // ),
        
        const SizedBox(height: 16),
        
        OutlinedButton.icon(
          onPressed: onVolverPressed,
          icon: const Icon(Icons.arrow_back, size: 28),
          label: const Text(
            'Volver a la lista',
            style: TextStyle(fontSize: 18),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
