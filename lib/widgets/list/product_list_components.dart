import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/ui/product/producto_detalle_page.dart';
import 'package:quilmedic/widgets/list/empty_products_message.dart';
import 'package:quilmedic/widgets/list/product_list_section.dart';

class ProductListContent extends StatelessWidget {
  final List<Producto> productos;
  final int hospitalId;
  final int? locationId;
  final String almacenName;
  final Location? location;
  final List<Producto>? predefinedProductos;
  final List<Color> alarmColors;
  final Function() onProductUpdated;

  const ProductListContent({
    super.key,
    required this.productos,
    required this.hospitalId,
    required this.locationId,
    required this.almacenName,
    this.location,
    this.predefinedProductos,
    required this.alarmColors,
    required this.onProductUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) {
      return const EmptyProductsMessage();
    }

    return _buildProductosLayout(context);
  }

  Widget _buildProductosLayout(BuildContext context) {
    final List<Producto> productosAlmacenActual = [];
    final List<Producto> productosOtrosAlmacenes = [];
    
    for (var producto in productos) {
      if (locationId != null) {
        if (producto.locationid == locationId) {
          productosAlmacenActual.add(producto);
        } else {
          productosOtrosAlmacenes.add(producto);
        }
      } else if (location?.storeId == hospitalId) {
        productosAlmacenActual.add(producto);
      } else {
        productosOtrosAlmacenes.add(producto);
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
          stops: const [0.0, 0.3],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.blue.shade200, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProductListSection(
                              title:
                                  'Productos del almacén $almacenName',
                              productos: productosAlmacenActual,
                              headerColor: Colors.blue,
                              rowColor: Colors.grey.shade50,
                              onProductTap:
                                  (producto) =>
                                      _navegarADetalle(context, producto),
                              alarmColors: alarmColors,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.touch_app,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Toca para detalles',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (productosOtrosAlmacenes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ProductListSection(
                                title: 'Productos de otros almacenes',
                                productos: productosOtrosAlmacenes,
                                headerColor: Colors.orange,
                                rowColor: Colors.grey.shade50,
                                onProductTap:
                                    (producto) =>
                                        _navegarADetalle(context, producto),
                                alarmColors: alarmColors,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.touch_app,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Toca para detalles',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (productos.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _cargarHospitalesYMostrarDialogo(context),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Trasladar todos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 241, 241, 241),
                  foregroundColor: Colors.black,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Color.fromARGB(255, 37, 37, 37),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _navegarADetalle(BuildContext context, Producto producto) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProductoDetallePage(
              producto: producto,
              almacenName: almacenName,
              location: location,
            ),
      ),
    );

    if (result == true && context.mounted) {
      if (predefinedProductos == null &&
          Provider.of<ListaProductosBloc?>(context, listen: false) != null) {
        Provider.of<ListaProductosBloc>(
          context,
          listen: false,
        ).add(CargarProductosEvent());
      } else if (predefinedProductos != null) {
        onProductUpdated();
      }
    }
  }

  void _cargarHospitalesYMostrarDialogo(BuildContext context) {
    // Esta función ahora se maneja en la página principal
    Provider.of<ListaProductosBloc>(context, listen: false)
        .add(CargarHospitalesEvent());
  }
}
