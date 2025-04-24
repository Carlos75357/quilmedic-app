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

class ScannerContent extends StatelessWidget {
  final EscanerState state;
  final List<Hospital> hospitales;
  final List<Location> locations;
  final List<ProductoEscaneado> productos;
  final Hospital? selectedHospital;
  final Location? selectedLocation;
  final bool isManualInput;
  final bool hayConexion;
  
  final Function(Hospital) onHospitalSelected;
  final Function(Location) onLocationSelected;
  final Function() onToggleManualInput;
  final Function(String, BuildContext) onManualCodeSubmitted;
  final Function() onCloseManualInput;
  final Function(ProductoEscaneado) onRemoveProduct;
  final Function(ProductoEscaneado, int) onUndoRemoveProduct;
  final Function() onSaveProducts;

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

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
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
                    side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
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
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: const EmptyProductsView(),
                        ),
                      );
                    },
                  ),
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
    );
  }
}
