import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/widgets/list/empty_products_message.dart';
import 'package:quilmedic/widgets/list/product_list_components.dart';
import 'package:quilmedic/widgets/list/product_serial_dialog.dart';
import 'package:quilmedic/widgets/list/product_traslado_handler.dart';

/// Pantalla que muestra la lista de productos escaneados
/// Permite ver detalles de los productos y gestionar traslados entre hospitales
class ListaProductosPage extends StatefulWidget {
  /// [List] Lista de productos a mostrar
  final List<Producto>? productos;
  /// [Location] Ubicación actual de los productos
  final Location? location;
  /// [List] Lista de códigos de productos que no se encontraron
  final List<String>? notFounds;
  /// [int] ID del hospital actual
  final int hospitalId;
  /// [int] ID de la ubicación actual
  final int locationId;
  /// [String] Nombre del almacén o hospital
  final String almacenName;

  /// Constructor de la página de lista de productos
  /// @param [key] Clave del widget
  /// @param [productos] Lista de productos a mostrar
  /// @param [location] Ubicación actual de los productos
  /// @param [notFounds] Lista de códigos que no se encontraron
  /// @param [hospitalId] ID del hospital actual
  /// @param [locationId] ID de la ubicación actual
  /// @param [almacenName] Nombre del almacén o hospital
  const ListaProductosPage({
    super.key,
    this.productos,
    this.location,
    this.notFounds,
    required this.hospitalId,
    required this.locationId,
    required this.almacenName,
  });

  /// Crea el estado mutable para este widget
  /// @return Una instancia de [_ListaProductosPageState]
  @override
  State<ListaProductosPage> createState() => _ListaProductosPageState();
}

/// Estado mutable para la pantalla de lista de productos
class _ListaProductosPageState extends State<ListaProductosPage> {
  /// [List] Lista de productos a mostrar
  late List<Producto> productos;
  /// [List] Lista de hospitales disponibles para traslados
  late List<Hospital> _hospitales = [];
  /// [String] Mensaje de error en caso de fallo al cargar hospitales
  String? _errorCargaHospitales;

  /// Inicializa el estado del widget
  /// Carga los productos y solicita más datos si es necesario
  @override
  void initState() {
    super.initState();
    productos = widget.productos ?? [];

    // Si no hay productos predefinidos, intenta cargarlos desde el bloc
    if (productos.isEmpty && context.read<ListaProductosBloc?>() != null) {
      BlocProvider.of<ListaProductosBloc>(context).add(CargarProductosEvent());
    }
  }

  /// Construye la interfaz de usuario de la pantalla de lista de productos
  /// @param [context] Contexto de construcción
  /// @return [Widget] con la estructura completa de la pantalla
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
                  icon: const Icon(Icons.warning_amber_outlined),
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
                        ? (productos.isEmpty && widget.notFounds != null && widget.notFounds!.isNotEmpty
                            ? EmptyProductsMessage(notFoundSerials: widget.notFounds)
                            : ProductListContent(
                                productos: productos,
                                hospitalId: widget.hospitalId,
                                locationId: widget.locationId,
                                almacenName: widget.almacenName,
                                location: widget.location,
                                predefinedProductos: widget.productos,
                                alarmColors: const [],
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
                                              notFounds: widget.notFounds,
                                            ),
                                      ),
                                    );
                                  }
                                },
                              )
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
                            return productos.isEmpty
                                ? EmptyProductsMessage(notFoundSerials: widget.notFounds)
                                : ProductListContent(
                                    productos: productos,
                                    hospitalId: widget.hospitalId,
                                    locationId: widget.locationId,
                                    almacenName: widget.almacenName,
                                    location: widget.location,
                                    alarmColors: const [],
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
