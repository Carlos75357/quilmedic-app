import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/widgets/list/product_traslado_popup.dart';

/// Clase utilitaria que maneja el flujo de traslado de productos entre hospitales.
/// Proporciona métodos para mostrar diálogos, confirmar traslados y procesar
/// las solicitudes de traslado de productos.

class ProductTrasladoHandler {
  /// Muestra un diálogo de carga mientras se obtienen los hospitales disponibles
  /// para el traslado de productos. Inicia la carga de hospitales a través del BLoC.
  /// 
  /// @param context Contexto de la aplicación para mostrar el diálogo y acceder al BLoC
  static Future<void> mostrarDialogoCargaHospitales(
    BuildContext context,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ProductTrasladoLoadingDialog();
      },
    );

    try {
      Provider.of<ListaProductosBloc>(
        context,
        listen: false,
      ).add(CargarHospitalesEvent());
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar hospitales'),
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

  /// Muestra el diálogo principal de traslado de productos que permite al usuario
  /// seleccionar el hospital destino y los productos a trasladar.
  /// 
  /// @param context Contexto de la aplicación para mostrar el diálogo
  /// @param hospitales Lista de hospitales disponibles como destino
  /// @param productos Lista de productos que pueden ser trasladados
  /// @param hospitalIdOrigen ID del hospital de origen (no aparecerá como destino)
  static void mostrarDialogoConfirmacionTraslado(
    BuildContext context,
    List<Hospital> hospitales,
    List<Producto> productos,
    int hospitalIdOrigen,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => ProductTrasladoPopup(
            productos: productos,
            hospitales: hospitales,
            hospitalIdOrigen: hospitalIdOrigen,
            onTrasladoConfirmado: (
              hospitalIdDestino,
              hospitalNombreDestino,
              email,
              selectedProducts,
            ) {
              realizarTrasladoMasivo(
                context,
                hospitalIdDestino,
                hospitalNombreDestino,
                email,
                selectedProducts,
              );
            },
          ),
    );
  }

  /// Procesa la solicitud de traslado de productos y maneja las respuestas del servidor.
  /// Configura listeners para detectar cuando la solicitud ha sido completada o ha fallado,
  /// y muestra notificaciones apropiadas al usuario.
  /// 
  /// @param context Contexto de la aplicación para mostrar notificaciones
  /// @param hospitalIdDestino ID del hospital destino seleccionado
  /// @param hospitalNombreDestino Nombre del hospital destino para mostrar en notificaciones
  /// @param email Correo electrónico para notificaciones de traslado
  /// @param selectedProducts Lista de productos seleccionados para trasladar
  static void realizarTrasladoMasivo(
    BuildContext context,
    int hospitalIdDestino,
    String hospitalNombreDestino,
    String email,
    List<Producto> selectedProducts,
  ) {

    final bloc = Provider.of<ListaProductosBloc>(context, listen: false);
    late final void Function() listener;

    listener = () {
      final currentState = bloc.state;

      if (currentState is SolicitudTrasladoEnviadaState) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).popUntil((route) => route.isFirst);

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

            bloc.add(CargarProductosEvent());
          }
        });

        bloc.stream.listen(null).cancel();
        bloc.stream.listen((state) {}).cancel();
      } else if (currentState is ErrorSolicitudTrasladoState) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).popUntil((route) => route.isFirst);

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

        bloc.stream.listen(null).cancel();
        bloc.stream.listen((state) {}).cancel();
      }
    };

    bloc.stream.listen((_) => listener());

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
