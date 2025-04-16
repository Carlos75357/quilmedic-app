import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/domain/producto.dart';
// import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/ui/product/producto_detalle_page.dart';
import 'package:provider/provider.dart';
// import 'package:quilmedic/utils/theme.dart';
import 'package:quilmedic/widgets/list/empty_products_message.dart';
import 'package:quilmedic/widgets/list/product_list_section.dart';

class ListaProductosPage extends StatefulWidget {
  final List<Producto>? productos;
  final Location? location;
  final List<String>? notFounds;
  final int hospitalId;
  final int? locationId;
  final String almacenName;

  const ListaProductosPage({
    super.key,
    this.productos,
    this.location,
    this.notFounds,
    required this.hospitalId,
    required this.locationId,
    required this.almacenName,
  });

  @override
  State<ListaProductosPage> createState() => _ListaProductosPageState();
}

class _ListaProductosPageState extends State<ListaProductosPage> {
  late List<Producto> productos;
  final Map<String, List<Producto>> groupedProducts = {};

  // late List<Hospital> _hospitales = [];
  // String? _errorCargaHospitales;

  @override
  void initState() {
    super.initState();
    productos = widget.productos ?? [];

    if (productos.isEmpty && context.read<ListaProductosBloc?>() != null) {
      BlocProvider.of<ListaProductosBloc>(context).add(CargarProductosEvent());
    }
  }

  void _mostrarDialogoNumerosSerie(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.qr_code, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Productos no encontrados (${widget.notFounds?.length ?? 0})',
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.notFounds?.length ?? 0,
              itemBuilder: (context, index) {
                final serialNumber = widget.notFounds?[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          serialNumber!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'No encontrado',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final isVerySmallScreen = MediaQuery.of(context).size.width < 320;
    groupedProducts.clear(); // Limpiar el mapa antes de reconstruirlo
    
    for (final producto in productos) {
      groupedProducts
          .putIfAbsent(producto.productcode, () => [])
          .add(producto);
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          if (productos.isNotEmpty)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Ver números de serie',
                  onPressed: () {
                    _mostrarDialogoNumerosSerie(context);
                  },
                ),
                if (productos.any(
                  (p) => p.description == null || p.description!.isEmpty,
                ))
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        productos
                            .where(
                              (p) =>
                                  p.description == null ||
                                  p.description!.isEmpty,
                            )
                            .length
                            .toString(),
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  widget.productos != null
                      ? _buildProductosContent()
                      : BlocListener<ListaProductosBloc, ListaProductosState>(
                        listener: (context, state) {
                          if (state is ListaProductosError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } else if (state is ProductosCargadosState) {
                            setState(() {
                              productos = state.productos;
                            });
                          }
                        },
                        child: BlocBuilder<
                          ListaProductosBloc,
                          ListaProductosState
                        >(
                          builder: (context, state) {
                            if (state is ListaProductosLoading) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Cargando productos...',
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return _buildProductosContent();
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductosContent() {
    if (productos.isEmpty) {
      return const EmptyProductsMessage();
    }

    return _buildProductosLayout();
  }

  Widget _buildProductosLayout() {
    final List<Producto> productosAlmacenActual = [];
    final List<Producto> productosOtrosAlmacenes = [];

    final int hospitalId = widget.hospitalId;
    final int? locationId = widget.locationId;
    
    for (var producto in productos) {
      if (locationId != null) {
        if (producto.locationid == locationId) {
          productosAlmacenActual.add(producto);
        } else {
          productosOtrosAlmacenes.add(producto);
        }
      } else if (widget.location?.storeId == hospitalId) {
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
                                  'Productos del almacén ${widget.almacenName}',
                              productos: productosAlmacenActual,
                              headerColor: Colors.blue,
                              rowColor: Colors.grey.shade50,
                              onProductTap:
                                  (producto) =>
                                      _navegarADetalle(context, producto),
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
                onPressed: () => _cargarHospitalesYMostrarDialogo(),
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

  void _navegarADetalle(BuildContext context, Producto producto) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoDetallePage(producto: producto, almacenName: widget.almacenName, location: widget.location),
      ),
    );

    if (result == true && context.mounted) {
      if (widget.productos == null &&
          Provider.of<ListaProductosBloc?>(context, listen: false) != null) {
        Provider.of<ListaProductosBloc>(
          context,
          listen: false,
        ).add(CargarProductosEvent());
      } else if (widget.productos != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ListaProductosPage(
                  productos: widget.productos,
                  location: widget.location,
                  hospitalId: widget.hospitalId,
                  locationId: widget.locationId,
                  almacenName: widget.almacenName,
                ),
          ),
        );
      }
    }
  }

  Future<void> _cargarHospitalesYMostrarDialogo() async {
    // setState(() {
    //   _errorCargaHospitales = null;
    // });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.local_hospital, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('Cargando hospitales'),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
    );

    // try {
    //   final response = await _hospitalRepository.getAllHospitals();

    //   if (mounted) {
    //     Navigator.of(context).pop();

    //     if (response.success) {
    //       setState(() {
    //         _hospitales = List<Hospital>.from(response.data);
    //       });

    //       _mostrarDialogoConfirmacionTrasladoMasivo(context, _hospitales);
    //     } else {
    //       setState(() {
    //         _errorCargaHospitales =
    //             response.message ?? 'Error al cargar hospitales';
    //       });

    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text(_errorCargaHospitales!),
    //           backgroundColor: Colors.red,
    //           behavior: SnackBarBehavior.floating,
    //           shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.circular(10),
    //           ),
    //         ),
    //       );
    //     }
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     Navigator.of(context).pop();

    //     setState(() {
    //       _errorCargaHospitales = 'Error al cargar hospitales: ${e.toString()}';
    //     });

    //     if (context.mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text(_errorCargaHospitales!),
    //           backgroundColor: Colors.red,
    //           behavior: SnackBarBehavior.floating,
    //           shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.circular(10),
    //           ),
    //         ),
    //       );
    //     }
    //   }
    // }
  }

  // void _mostrarDialogoConfirmacionTrasladoMasivo(
  //   BuildContext context,
  //   List<Hospital> hospitales,
  // ) {
  //   int? selectedHospitalId;
  //   String? selectedHospitalName;

  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => Theme(
  //           data: Theme.of(context),
  //           child: AlertDialog(
  //             title: Row(
  //               children: [
  //                 Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
  //                 const SizedBox(width: 8),
  //                 Text(
  //                   'Trasladar productos',
  //                   style: TextStyle(
  //                     color: AppTheme.primaryColor,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 const Text(
  //                   'Seleccione el hospital destino para trasladar todos los productos',
  //                   style: TextStyle(fontSize: 14),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 DropdownButtonFormField<int>(
  //                   decoration: InputDecoration(
  //                     labelText: 'Hospital Destino',
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     filled: true,
  //                     fillColor: Colors.grey.shade50,
  //                     prefixIcon: const Icon(Icons.local_hospital_outlined),
  //                   ),
  //                   items:
  //                       hospitales.where((h) => h.id != widget.hospitalId).map((
  //                         hospital,
  //                       ) {
  //                         return DropdownMenuItem<int>(
  //                           value: hospital.id,
  //                           child: Text(hospital.description),
  //                         );
  //                       }).toList(),
  //                   onChanged: (value) {
  //                     selectedHospitalId = value;
  //                     if (value != null) {
  //                       selectedHospitalName =
  //                           hospitales
  //                               .firstWhere((h) => h.id == value)
  //                               .description;
  //                     }
  //                   },
  //                 ),
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text('Cancelar'),
  //               ),
  //               ElevatedButton.icon(
  //                 onPressed: () {
  //                   if (selectedHospitalId != null &&
  //                       selectedHospitalName != null) {
  //                     Navigator.of(context).pop();
  //                   } else {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                         content: const Text(
  //                           'Debes seleccionar un hospital destino',
  //                         ),
  //                         backgroundColor: Colors.red,
  //                         behavior: SnackBarBehavior.floating,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                       ),
  //                     );
  //                   }
  //                 },
  //                 icon: const Icon(Icons.send),
  //                 label: const Text('Enviar'),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.blueAccent,
  //                   foregroundColor: Colors.white,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //   );
  // }
}
