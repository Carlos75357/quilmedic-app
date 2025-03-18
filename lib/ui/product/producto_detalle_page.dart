import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/ui/product/producto_detalle_bloc.dart';
import 'package:quilmedic/widgets/product/product_info_card.dart';
import 'package:quilmedic/widgets/product/product_action_buttons.dart';
import 'package:quilmedic/widgets/product/product_transfer_dialogs.dart';

class ProductoDetallePage extends StatefulWidget {
  final Producto producto;

  const ProductoDetallePage({super.key, required this.producto});

  @override
  State<ProductoDetallePage> createState() => _ProductoDetallePageState();
}

class _ProductoDetallePageState extends State<ProductoDetallePage> {
  late final ProductoDetalleBloc _productoDetalleBloc;
  
  @override
  void initState() {
    super.initState();
    _productoDetalleBloc = ProductoDetalleBloc();
    _productoDetalleBloc.add(CargarHospitalesEvent());
  }
  
  @override
  void dispose() {
    _productoDetalleBloc.close();
    super.dispose();
  }

  void _mostrarDialogoTraslado(List<Hospital> hospitales) {
    final hospitalesFiltrados = hospitales
        .where((h) => h.id != widget.producto.codigoalmacen)
        .toList();

    if (hospitalesFiltrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay otros hospitales disponibles para trasladar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ProductTransferDialogs.showHospitalSelectionDialog(
      context: context,
      hospitales: hospitalesFiltrados,
      onHospitalSelected: (hospitalId) {
        _productoDetalleBloc.add(
          TrasladarProductoEvent(
            productoId: widget.producto.numproducto,
            nuevoHospitalId: hospitalId,
          ),
        );
      },
      onCancel: () {},
    );
  }

  void _mostrarDialogoConfirmacionTraslado(
    BuildContext context,
    String mensaje,
    dynamic producto,
    int almacenDestino,
  ) {
    ProductTransferDialogs.showConfirmationDialog(
      context: context,
      mensaje: mensaje,
      onConfirm: () {
        _productoDetalleBloc.add(
          ConfirmarTrasladoProductoEvent(
            productoId: widget.producto.numproducto,
            nuevoHospitalId: almacenDestino,
          ),
        );
      },
      onCancel: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _productoDetalleBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Producto'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: BlocListener<ProductoDetalleBloc, ProductoDetalleState>(
          listener: (context, state) {
            if (state is ErrorCargaHospitalesState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensaje),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ProductoTrasladadoState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensaje),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is ErrorTrasladoProductoState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensaje),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ProductoEnOtroAlmacenState) {
              _mostrarDialogoConfirmacionTraslado(
                context,
                state.mensaje,
                state.producto,
                state.almacenDestino, 
              );
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductInfoCard(producto: widget.producto),
                  
                  const SizedBox(height: 24),
                  
                  BlocBuilder<ProductoDetalleBloc, ProductoDetalleState>(
                    builder: (context, state) {
                      return ProductActionButtons(
                        state: state,
                        onTrasladarPressed: _mostrarDialogoTraslado,
                        onVolverPressed: () => Navigator.pop(context),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
