import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/widgets/list/product_traslado_popup.dart';

class ProductTrasladoHandler {
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
        // Navigator.of(context).pop();
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
