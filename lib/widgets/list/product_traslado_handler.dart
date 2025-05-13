import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/widgets/list/product_traslado_popup.dart';

/// Clase que maneja la funcionalidad de traslado de productos
class ProductTrasladoHandler {
  /// Muestra el diálogo de carga de hospitales
  static Future<void> mostrarDialogoCargaHospitales(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ProductTrasladoLoadingDialog();
      },
    );

    try {
      Provider.of<ListaProductosBloc>(context, listen: false).add(CargarHospitalesEvent());
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar hospitales: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
          ),
        );
      }
    }
  }

  /// Muestra el diálogo de confirmación de traslado
  static void mostrarDialogoConfirmacionTraslado(
    BuildContext context,
    List<Hospital> hospitales,
    List<Producto> productos,
    int hospitalIdOrigen,
  ) {
    showDialog(
      context: context,
      builder: (context) => ProductTrasladoPopup(
        productos: productos,
        hospitales: hospitales,
        hospitalIdOrigen: hospitalIdOrigen,
        onTrasladoConfirmado: (hospitalIdDestino, hospitalNombreDestino, email, selectedProducts) => 
            realizarTrasladoMasivo(context, hospitalIdDestino, hospitalNombreDestino, email, selectedProducts),
      ),
    );
  }

  /// Realiza el traslado masivo de productos
  static void realizarTrasladoMasivo(
    BuildContext context, 
    int hospitalIdDestino, 
    String hospitalNombreDestino,
    String email,
    List<Producto> selectedProducts
  ) {
    // Mostrar diálogo de procesamiento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.swap_horiz, color: Colors.blue),
              SizedBox(width: 8),
              Text('Trasladando productos'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Procesando traslado de ${selectedProducts.length} productos...'),
            ],
          ),
        );
      },
    );

    // Configurar listener para estados del bloc
    final bloc = Provider.of<ListaProductosBloc>(context, listen: false);
    late final void Function() listener;
    
    listener = () {
      final currentState = bloc.state;
      
      if (currentState is SolicitudTrasladoEnviadaState) {
        // Forzar el cierre de todos los diálogos después de 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            // Cerrar todos los diálogos abiertos
            Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
            
            // Mostrar mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(currentState.mensaje),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
              ),
            );
            
            // Recargar la lista de productos
            bloc.add(CargarProductosEvent());
          }
        });
        
        // Eliminar el listener
        bloc.stream.listen(null).cancel();
        bloc.stream.listen((state) {}).cancel();
      } else if (currentState is ErrorSolicitudTrasladoState) {
        // Forzar el cierre de todos los diálogos después de 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            // Cerrar todos los diálogos abiertos
            Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
            
            // Mostrar mensaje de error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(currentState.mensaje),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
              ),
            );
          }
        });
        
        // Eliminar el listener
        bloc.stream.listen(null).cancel();
        bloc.stream.listen((state) {}).cancel();
      }
    };
    
    // Añadir listener al stream del bloc
    bloc.stream.listen((_) => listener());
    
    // Enviar la solicitud de traslado al bloc
    bloc.add(
      EnviarSolicitudTrasladoEvent(
        productos: selectedProducts,
        hospitalDestinoId: hospitalIdDestino,
        hospitalDestinoNombre: hospitalNombreDestino,
        email: email,
      ),
    );
  }
}
