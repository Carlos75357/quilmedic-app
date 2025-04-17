import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';

/// Clase que maneja la lógica del escáner separada de la UI
class ScannerHandler {
  /// Muestra un SnackBar con un mensaje de error
  static void mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(milliseconds: 5000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
      ),
    );
  }

  /// Muestra un SnackBar con un mensaje de éxito
  static void mostrarExito(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
      ),
    );
  }

  /// Muestra un SnackBar con un mensaje de advertencia
  static void mostrarAdvertencia(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
      ),
    );
  }

  /// Muestra un SnackBar con un mensaje informativo
  static void mostrarInfo(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
      ),
    );
  }

  /// Procesa un código escaneado
  static void procesarCodigoEscaneado(BuildContext context, String code, Hospital? selectedHospital) {
    BlocProvider.of<EscanerBloc>(context).add(SubmitCodeEvent(code));
    
    if (selectedHospital == null) {
      mostrarAdvertencia(
        context, 
        'Escaneando sin almacén seleccionado. Selecciona un almacén antes de guardar.'
      );
    }
  }

  /// Elimina un producto de la lista
  static void eliminarProducto(BuildContext context, ProductoEscaneado producto) {
    BlocProvider.of<EscanerBloc>(context).add(EliminarProductoEvent(producto));
  }

  /// Guarda los productos escaneados
  static void guardarProductos(BuildContext context) {
    BlocProvider.of<EscanerBloc>(context).add(GuardarProductosEvent());
  }

  /// Sincroniza los productos pendientes
  static void sincronizarProductosPendientes(BuildContext context) {
    BlocProvider.of<EscanerBloc>(context).add(SincronizarProductosPendientesEvent());
  }

  /// Selecciona un hospital
  static void seleccionarHospital(BuildContext context, Hospital hospital) {
    BlocProvider.of<EscanerBloc>(context).add(ChooseStoreEvent(hospital));
  }

  /// Selecciona una ubicación
  static void seleccionarUbicacion(BuildContext context, Location location) {
    BlocProvider.of<EscanerBloc>(context).add(ChooseLocationEvent(location));
  }

  /// Carga los hospitales
  static void cargarHospitales(BuildContext context) {
    BlocProvider.of<EscanerBloc>(context).add(LoadHospitales());
  }
}
