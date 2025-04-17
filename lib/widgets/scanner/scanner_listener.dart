import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/ui/list/lista_productos_page.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';

class ScannerListener extends StatelessWidget {
  final Widget child;
  final Function() resetSelections;
  final Function(List<ProductoEscaneado>) onProductosUpdated;
  final Function(bool) onPendingProductsChanged;

  const ScannerListener({
    Key? key,
    required this.child,
    required this.resetSelections,
    required this.onProductosUpdated,
    required this.onPendingProductsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<EscanerBloc, EscanerState>(
      listener: (context, state) {
        if (state is EscanerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(milliseconds: 5000),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 180, right: 20, left: 20),
            ),
          );
        } else if (state is ProductoEscaneadoExistenteState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'El producto ${state.producto.serialnumber} ya existe',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
            ),
          );
        } else if (state is ProductoEscaneadoGuardadoState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto ${state.producto.serialnumber} guardado'),
              backgroundColor: Colors.green,
              duration: const Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
            ),
          );
        } else if (state is ProductosListadosState) {
          onProductosUpdated(state.productos);
        } else if (state is GuardarSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Productos guardados correctamente'),
              backgroundColor: Colors.green,
              duration: const Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
            ),
          );
        } else if (state is GuardarOfflineSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
            ),
          );
          onProductosUpdated([]);
          onPendingProductsChanged(true);
        } else if (state is SincronizacionCompletaState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Productos sincronizados correctamente'),
              backgroundColor: Colors.green,
              duration: const Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
            ),
          );
          onPendingProductsChanged(false);
        } else if (state is ProductosRecibidosState) {
          if (state.mensaje != null && state.mensaje!.contains("No se encontraron")) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje!),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
              ),
            );
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListaProductosPage(
                productos: state.productos,
                location: context.read<EscanerBloc>().locationSeleccionada,
                notFounds: state.productosNotFound,
                hospitalId: context.read<EscanerBloc>().hospitalSeleccionado?.id ?? 0,
                locationId: context.read<EscanerBloc>().locationSeleccionada?.id,
                almacenName: context.read<EscanerBloc>().hospitalSeleccionado?.description ?? '',
              ),
            ),
          ).then((_) {
            resetSelections();
          });
        } else if (state is SinProductosPendientesState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
            ),
          );
          onPendingProductsChanged(false);
        } else if (state is HospitalesCargados) {
          // Manejar el estado de hospitales cargados si es necesario
        }
      },
      child: child,
    );
  }
}
