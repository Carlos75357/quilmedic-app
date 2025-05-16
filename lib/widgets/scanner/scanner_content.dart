import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';
import 'package:quilmedic/widgets/scanner/empty_products_view.dart';
import 'package:quilmedic/widgets/scanner/manual_code_input.dart';
import 'package:quilmedic/widgets/scanner/productos_list.dart';
import 'package:quilmedic/widgets/scanner/save_button.dart';
import 'package:quilmedic/widgets/scanner/selector.dart';

/// Widget principal que muestra el contenido de la pantalla de escaneo
/// Organiza los diferentes componentes de la interfaz como el selector de hospital,
/// entrada manual de códigos, lista de productos escaneados y botón de guardar

class ScannerContent extends StatelessWidget {
  /// Estado actual del BLoC de escaneo
  final EscanerState state;
  /// Lista de hospitales disponibles para seleccionar
  final List<Hospital> hospitales;
  /// Lista de ubicaciones disponibles para seleccionar
  final List<Location> locations;
  /// Lista de productos que han sido escaneados
  final List<ProductoEscaneado> productos;
  /// Hospital seleccionado actualmente (puede ser null)
  final Hospital? selectedHospital;
  /// Ubicación seleccionada actualmente (puede ser null)
  final Location? selectedLocation;
  /// Indica si el modo de entrada manual está activo
  final bool isManualInput;
  /// Indica si hay conexión a Internet disponible
  final bool hayConexion;
  
  /// Función que se ejecuta cuando se selecciona un hospital
  final Function(Hospital) onHospitalSelected;
  /// Función que se ejecuta cuando se selecciona una ubicación
  final Function(Location) onLocationSelected;
  /// Función que se ejecuta para activar/desactivar el modo de entrada manual
  final Function() onToggleManualInput;
  /// Función que se ejecuta cuando se envía un código manual
  final Function(String, BuildContext) onManualCodeSubmitted;
  /// Función que se ejecuta para cerrar el modo de entrada manual
  final Function() onCloseManualInput;
  /// Función que se ejecuta para eliminar un producto de la lista
  final Function(ProductoEscaneado) onRemoveProduct;
  /// Función que se ejecuta para deshacer la eliminación de un producto
  final Function(ProductoEscaneado, int) onUndoRemoveProduct;
  /// Función que se ejecuta para guardar todos los productos escaneados
  final Function() onSaveProducts;

  /// Constructor del widget ScannerContent
  const ScannerContent({
    super.key,
    required this.state,
    required this.hospitales,
    required this.locations,
    required this.productos,
    required this.selectedHospital,
    required this.selectedLocation,
    required this.isManualInput,
    required this.hayConexion,
    required this.onHospitalSelected,
    required this.onLocationSelected,
    required this.onToggleManualInput,
    required this.onManualCodeSubmitted,
    required this.onCloseManualInput,
    required this.onRemoveProduct,
    required this.onUndoRemoveProduct,
    required this.onSaveProducts,
  });

  /// Construye la interfaz principal de la pantalla de escaneo
  /// Organiza los componentes en una columna vertical
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          BlocBuilder<EscanerBloc, EscanerState>(
            builder: (context, state) {
              return Selector(
                hospitales: hospitales,
                selectedHospital: selectedHospital,
                onOptionsSelected: onHospitalSelected,
                locations: locations,
                onLocationSelected: onLocationSelected,
              );
            },
          ),

          const SizedBox(height: 12),

          if (isManualInput)
            ManualCodeInput(
              onCodeSubmitted: (code) => onManualCodeSubmitted(code, context),
              onClose: onCloseManualInput,
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: onToggleManualInput,
                  icon: const Icon(Icons.keyboard, size: 18),
                  label: const Text('Ingresar código manualmente'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          if (productos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Productos escaneados (${productos.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: productos.isNotEmpty
                ? ProductosList(
                    productos: productos,
                    onRemove: onRemoveProduct,
                    onUndoRemove: onUndoRemoveProduct,
                  )
                : const EmptyProductsView(),
          ),

          if (state is! EscanerLoading) ...[
            if (selectedHospital != null)
              SaveButton(
                onPressed: onSaveProducts,
                hayConexion: hayConexion,
              ),
          ],
        ],
        ),
      ),
    );
  }
}
