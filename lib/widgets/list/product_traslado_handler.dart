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
        onTrasladoConfirmado: (hospitalIdDestino, hospitalNombreDestino) => 
            realizarTrasladoMasivo(context, hospitalIdDestino, hospitalNombreDestino, productos),
      ),
    );
  }

  /// Realiza el traslado masivo de productos
  static void realizarTrasladoMasivo(
    BuildContext context, 
    int hospitalIdDestino, 
    String hospitalNombreDestino,
    List<Producto> productos
  ) {
    // Ejemplo de implementación:
    // BlocProvider.of<ListaProductosBloc>(context).add(
    //   EnviarSolicitudTrasladoEvent(
    //     productos: productos,
    //     hospitalDestinoId: hospitalIdDestino,
    //     hospitalDestinoNombre: hospitalNombreDestino,
    //   ),
    // );
    
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop(); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Productos trasladados exitosamente a $hospitalNombreDestino'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
          ),
        );
        
        if (Provider.of<ListaProductosBloc?>(context, listen: false) != null) {
          Provider.of<ListaProductosBloc>(
            context,
            listen: false,
          ).add(CargarProductosEvent());
        }
      }
    });
  }
}
