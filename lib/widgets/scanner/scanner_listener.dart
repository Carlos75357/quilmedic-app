import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/ui/list/lista_productos_page.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';

/// Widget que escucha los cambios de estado del BLoC del escáner
/// y ejecuta acciones en respuesta a esos cambios, como mostrar
/// mensajes, actualizar listas de productos o navegar a otras pantallas.

class ScannerListener extends StatelessWidget {
  /// Widget hijo que será envuelto por el listener
  final Widget child;
  /// Función para reiniciar las selecciones (hospital y ubicación)
  final Function() resetSelections;
  /// Función que se ejecuta cuando la lista de productos es actualizada
  /// Recibe la lista actualizada de productos escaneados
  final Function(List<ProductoEscaneado>) onProductosUpdated;
  /// Función que se ejecuta cuando cambia el estado de productos pendientes
  /// Recibe un booleano que indica si hay productos pendientes
  final Function(bool) onPendingProductsChanged;
  /// Función opcional que se ejecuta cuando las selecciones son reiniciadas
  final Function()? onSelectionsReset;

  /// Constructor del widget ScannerListener
  /// @param child Widget hijo que será envuelto por el listener
  /// @param resetSelections Función para reiniciar las selecciones
  /// @param onProductosUpdated Función para actualizar la lista de productos
  /// @param onPendingProductsChanged Función para manejar cambios en productos pendientes
  /// @param onSelectionsReset Función opcional para cuando se reinician las selecciones
  const ScannerListener({
    super.key,
    required this.child,
    required this.resetSelections,
    required this.onProductosUpdated,
    required this.onPendingProductsChanged,
    this.onSelectionsReset,
  });

  /// Construye un BlocListener que escucha los cambios de estado del EscanerBloc
  /// y ejecuta acciones en respuesta a esos cambios
  @override
  Widget build(BuildContext context) {
    return BlocListener<EscanerBloc, EscanerState>(
      /// Función que se ejecuta cuando cambia el estado del EscanerBloc
      /// Maneja diferentes estados y ejecuta acciones correspondientes
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
          // No vaciamos la lista de productos para que el usuario pueda ver lo que se guardó localmente
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
          // Pasar directamente a la siguiente vista sin mostrar el SnackBar de error
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
        } else if (state is SelectionsResetState) {
          // Notificar que las selecciones han sido reseteadas
          if (onSelectionsReset != null) {
            onSelectionsReset!();
          }
        }
      },
      child: child,
    );
  }
}
