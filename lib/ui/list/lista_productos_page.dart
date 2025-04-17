import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/widgets/list/product_list_components.dart';
import 'package:quilmedic/widgets/list/product_serial_dialog.dart';
import 'package:quilmedic/widgets/list/product_traslado_handler.dart';

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
  late List<Hospital> _hospitales = [];
  String? _errorCargaHospitales;

  @override
  void initState() {
    super.initState();
    productos = widget.productos ?? [];

    if (productos.isEmpty && context.read<ListaProductosBloc?>() != null) {
      BlocProvider.of<ListaProductosBloc>(context).add(CargarProductosEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    showDialog(
                      context: context,
                      builder:
                          (context) =>
                              ProductSerialDialog(notFounds: widget.notFounds),
                    );
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
              child: BlocListener<ListaProductosBloc, ListaProductosState>(
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
                  } else if (state is HospitalesCargadosState) {
                    setState(() {
                      _hospitales = state.hospitales;
                    });

                    Navigator.of(context).pop();

                    ProductTrasladoHandler.mostrarDialogoConfirmacionTraslado(
                      context,
                      _hospitales,
                      productos,
                      widget.hospitalId,
                    );
                  } else if (state is ErrorCargaHospitalesState) {
                    Navigator.of(context).pop();

                    setState(() {
                      _errorCargaHospitales = state.mensaje;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_errorCargaHospitales!),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.only(
                          bottom: 80,
                          right: 20,
                          left: 20,
                        ),
                      ),
                    );
                  }
                },
                child:
                    widget.productos != null
                        ? ProductListContent(
                          productos: productos,
                          hospitalId: widget.hospitalId,
                          locationId: widget.locationId,
                          almacenName: widget.almacenName,
                          location: widget.location,
                          predefinedProductos: widget.productos,
                          onProductUpdated: () {
                            if (mounted) {
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
                          },
                        )
                        : BlocBuilder<ListaProductosBloc, ListaProductosState>(
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
                            return ProductListContent(
                              productos: productos,
                              hospitalId: widget.hospitalId,
                              locationId: widget.locationId,
                              almacenName: widget.almacenName,
                              location: widget.location,
                              onProductUpdated: () {},
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
