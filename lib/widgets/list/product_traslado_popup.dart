import 'package:flutter/material.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/utils/theme.dart';

/// Diálogo emergente que permite al usuario trasladar productos
/// entre diferentes hospitales. Permite seleccionar el hospital destino
/// y los productos a trasladar, con opciones de búsqueda y filtrado.

class ProductTrasladoPopup extends StatefulWidget {
  /// Lista de productos disponibles para trasladar
  final List<Producto> productos;
  /// Lista de hospitales disponibles como destino
  final List<Hospital> hospitales;
  /// ID del hospital de origen (no se mostrará en la lista de destinos)
  final int hospitalIdOrigen;
  /// Función que se ejecuta cuando se confirma el traslado
  /// Recibe el ID y nombre del hospital destino, el email de notificación
  /// y la lista de productos seleccionados para trasladar
  final Function(
    int hospitalId,
    String hospitalName,
    String email,
    List<Producto> selectedProducts,
  )
  onTrasladoConfirmado;

  /// Constructor del widget ProductTrasladoPopup
  const ProductTrasladoPopup({
    super.key,
    required this.productos,
    required this.hospitales,
    required this.hospitalIdOrigen,
    required this.onTrasladoConfirmado,
  });

  /// Crea el estado mutable para este widget
  @override
  State<ProductTrasladoPopup> createState() => _ProductTrasladoPopupState();
}

/// Estado interno del widget ProductTrasladoPopup
class _ProductTrasladoPopupState extends State<ProductTrasladoPopup> {
  /// ID del hospital destino seleccionado
  int? selectedHospitalId;
  /// Nombre del hospital destino seleccionado
  String? selectedHospitalName;
  /// Email estático para notificaciones de traslado
  final String staticEmail = 'kessvan.cedeno@kiobus.com'; // Email para notificaciones de traslado
  /// Lista de productos seleccionados para trasladar
  List<Producto> selectedProducts = [];
  /// Término de búsqueda para filtrar productos
  String? searchQuery;
  /// Lista de productos filtrados según el término de búsqueda
  List<Producto> filteredProducts = [];

  /// Inicializa el estado del widget
  /// Selecciona todos los productos por defecto y configura la lista filtrada
  @override
  void initState() {
    super.initState();
    selectedProducts = List.from(widget.productos);
    filteredProducts = List.from(widget.productos);
  }

  /// Libera recursos cuando el widget se elimina del árbol
  @override
  void dispose() {
    super.dispose();
  }

  /// Filtra la lista de productos basado en el término de búsqueda
  /// Busca coincidencias en el número de serie o código del producto
  void filterProducts(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredProducts = List.from(widget.productos);
      } else {
        filteredProducts =
            widget.productos.where((product) {
              final serialLower = product.serialnumber.toLowerCase();
              final productCodeLower = product.productcode.toLowerCase();
              final queryLower = query.toLowerCase();
              return serialLower.contains(queryLower) ||
                  productCodeLower.contains(queryLower);
            }).toList();
      }
    });
  }

  /// Alterna la selección de un producto
  /// Si ya está seleccionado, lo quita; si no, lo añade a la selección
  void toggleProductSelection(Producto product) {
    setState(() {
      if (selectedProducts.any((p) => p.serialnumber == product.serialnumber)) {
        selectedProducts.removeWhere(
          (p) => p.serialnumber == product.serialnumber,
        );
      } else {
        selectedProducts.add(product);
      }
    });
  }

  /// Verifica si un producto está seleccionado
  /// Compara por número de serie para identificar productos únicos
  bool isProductSelected(Producto product) {
    return selectedProducts.any((p) => p.serialnumber == product.serialnumber);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Trasladar productos',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
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
                items:
                    widget.hospitales
                        .where((h) => h.id != widget.hospitalIdOrigen)
                        .map((hospital) {
                          return DropdownMenuItem<int>(
                            value: hospital.id,
                            child: Text(hospital.description),
                          );
                        })
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedHospitalId = value;
                    if (value != null) {
                      selectedHospitalName =
                          widget.hospitales
                              .firstWhere((h) => h.id == value)
                              .description;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 4, // Dar más espacio al campo de búsqueda
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Buscar productos',
                        hintText: 'Buscar por código o descripción',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: filterProducts,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (selectedProducts.length ==
                            widget.productos.length) {
                          // Deseleccionar todos
                          selectedProducts.clear();
                        } else {
                          // Seleccionar todos
                          selectedProducts = List.from(widget.productos);
                        }
                      });
                    },
                    icon: Icon(
                      selectedProducts.length == widget.productos.length
                          ? Icons.deselect
                          : Icons.select_all,
                      color: AppTheme.primaryColor,
                    ),
                    tooltip:
                        selectedProducts.length == widget.productos.length
                            ? 'Deseleccionar todos'
                            : 'Seleccionar todos',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Productos seleccionados: ${selectedProducts.length} de ${widget.productos.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isSelected = isProductSelected(product);

                    return CheckboxListTile(
                      title: Text(
                        product.productcode,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Serial: ${product.serialnumber}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: isSelected,
                      onChanged: (_) => toggleProductSelection(product),
                      dense: true,
                      activeColor: AppTheme.primaryColor,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final email = staticEmail;

                        if (selectedHospitalId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor seleccione un hospital destino',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (selectedProducts.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor seleccione al menos un producto',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        Navigator.of(context, rootNavigator: true).pop();

                        widget.onTrasladoConfirmado(
                          selectedHospitalId!,
                          selectedHospitalName!,
                          email,
                          selectedProducts,
                        );
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo que muestra un indicador de carga mientras se obtienen
/// los hospitales disponibles para el traslado de productos
class ProductTrasladoLoadingDialog extends StatelessWidget {
  /// Constructor del widget ProductTrasladoLoadingDialog
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
