import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:quilmedic/widgets/scanner/scanner_app_bar.dart';
import 'package:quilmedic/widgets/scanner/scanner_content.dart';
import 'package:quilmedic/widgets/scanner/scanner_listener.dart';
import 'package:quilmedic/widgets/scanner/scanner_handler.dart';
import 'package:quilmedic/widgets/scanner/datalogic_scanner_listener.dart';
import 'dart:async';
import 'escaner_bloc.dart';

/// Pantalla principal del escáner de productos
/// Permite escanear productos mediante la cámara o el escáner Datalogic,
/// seleccionar hospitales y ubicaciones, y gestionar los productos escaneados
class EscanerPage extends StatefulWidget {
  /// Constructor de la página del escáner
  const EscanerPage({super.key});

  /// Crea el estado mutable para este widget
  @override
  State<EscanerPage> createState() => _EscanerPageState();
}

/// Estado mutable para la pantalla del escáner
/// Implementa WidgetsBindingObserver para detectar cambios en el ciclo de vida de la aplicación
class _EscanerPageState extends State<EscanerPage> with WidgetsBindingObserver {
  /// Controlador para el campo de texto de hospitales
  final TextEditingController _hospitalesController = TextEditingController();

  /// Hospital seleccionado actualmente
  Hospital? selectedHospital;

  /// Ubicación seleccionada dentro del hospital
  Location? selectedLocation;

  /// Lista de productos escaneados
  List<ProductoEscaneado> productos = [];

  /// Lista de hospitales disponibles
  List<Hospital> hospitales = [];

  /// Lista de ubicaciones disponibles para el hospital seleccionado
  List<Location> locations = [];

  /// Indica si se está escaneando actualmente
  bool isScanning = false;

  /// Indica si se está mostrando la entrada manual de códigos
  bool _isManualInput = false;

  /// Indica si hay conexión a Internet
  final bool _hayConexion = true;

  /// Indica si hay productos pendientes de sincronización
  bool _hayProductosPendientes = false;

  /// Temporizador para la detección del escáner
  Timer? _scannerDetectionTimer;

  /// Nodo de enfoque global para capturar eventos de teclado
  final FocusNode _globalFocusNode = FocusNode();

  /// Inicializa el estado del widget
  /// Comprueba si hay productos pendientes y carga la lista de hospitales
  /// También registra el observador para detectar cambios en el ciclo de vida
  @override
  void initState() {
    super.initState();
    BlocProvider.of<EscanerBloc>(context).add(LoadHospitales());

    WidgetsBinding.instance.addObserver(this);
  }

  /// Libera los recursos utilizados por este objeto
  /// Cancela temporizadores, libera controladores y elimina el observador
  @override
  void dispose() {
    _hospitalesController.dispose();
    _scannerDetectionTimer?.cancel();
    _globalFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Reinicia las selecciones de hospital y ubicación
  /// Actualiza el estado local y envía un evento al bloc
  void _resetSelections() {
    setState(() {
      selectedHospital = null;
      selectedLocation = null;
    });
    BlocProvider.of<EscanerBloc>(context).add(ResetSelectionsEvent());
  }

  /// Comprueba si hay productos pendientes en el caché local
  /// Los carga en el array de productos sin intentar sincronizarlos con el servidor
  Future<void> _checkPendingProducts() async {
    final hayPendientes = await ProductoLocalStorage.hayProductosPendientes();

    if (mounted) {
      setState(() {
        _hayProductosPendientes = hayPendientes;
      });

      if (hayPendientes) {
        final productosPendientes =
            await ProductoLocalStorage.obtenerProductosPendientes();

        final hospitalId =
            await ProductoLocalStorage.obtenerHospitalPendiente();

        if (hospitalId != null && productosPendientes.isNotEmpty) {
          final List<ProductoEscaneado> productosNuevos = [];

          for (final productoPendiente in productosPendientes) {
            final bool yaExiste = productos.any(
              (p) => p.serialnumber == productoPendiente.serialnumber,
            );

            if (!yaExiste) {
              productosNuevos.add(productoPendiente);
            }
          }

          if (productosNuevos.isNotEmpty) {
            setState(() {
              productos.addAll(productosNuevos);
            });
          }

          if (hospitales.isNotEmpty) {
            final hospital = hospitales.firstWhere(
              (h) => h.id == hospitalId,
              orElse: () => hospitales.first,
            );

            setState(() {
              selectedHospital = hospital;
            });

            ScannerHandler.seleccionarHospital(context, hospital);
          }
        }
      }
    }
  }

  Future<void> _putPendingLocation() async {
    final locationId = await ProductoLocalStorage.obtenerLocationPendiente();

    if (locations.isNotEmpty && locationId != null) {
      final location = locations.firstWhere(
        (l) => l.id == locationId,
        orElse: () => locations.first,
      );

      setState(() {
        selectedLocation = location;
      });

      if (mounted) {
        ScannerHandler.seleccionarUbicacion(context, location);
      }
    }
  }

  /// Alterna la visibilidad del campo de entrada manual de códigos
  void _toggleManualInput() {
    setState(() {
      _isManualInput = !_isManualInput;
    });
  }

  /// Procesa un código ingresado manualmente
  /// Envía el código al bloc y muestra una advertencia si no hay hospital seleccionado
  /// @param code Código ingresado por el usuario
  /// @param context Contexto de construcción
  void _onManualCodeSubmitted(String code, BuildContext context) {
    BlocProvider.of<EscanerBloc>(context).add(SubmitCodeEvent(code));

    if (selectedHospital == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Escaneando sin almacén seleccionado. Selecciona un almacén antes de guardar.',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
        ),
      );
    }
  }

  /// Cierra el campo de entrada manual de códigos
  void _closeManualInput() {
    setState(() {
      _isManualInput = false;
    });
  }

  /// Construye la interfaz de usuario de la pantalla del escáner
  /// @param context Contexto de construcción
  /// @return Widget con la estructura completa de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScannerAppBar(hayProductosPendientes: _hayProductosPendientes),
      body: KeyboardListener(
        focusNode: _globalFocusNode,
        autofocus: true,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SafeArea(
            child: ScannerListener(
              resetSelections: _resetSelections,
              onProductosUpdated: (newProductos) {
                setState(() {
                  productos = newProductos;
                });
              },
              onPendingProductsChanged: (hasPending) {
                setState(() {
                  _hayProductosPendientes = hasPending;
                });
              },
              onSelectionsReset: () {
                setState(() {
                  selectedHospital = null;
                  selectedLocation = null;
                });
              },
              child: BlocBuilder<EscanerBloc, EscanerState>(
                builder: (context, state) {
                  if (state is HospitalesCargados) {
                    selectedHospital = null;
                    hospitales = state.hospitales;

                    if (hospitales.isNotEmpty) {
                      _checkPendingProducts();
                    }
                  }
                  if (state is LocationsCargadas) {
                    selectedLocation = null;
                    locations = state.locations;

                    // Retrasar la ejecución de _putPendingLocation para asegurar que las ubicaciones
                    // se hayan cargado completamente en la interfaz de usuario
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted && locations.isNotEmpty) {
                        _putPendingLocation();
                      }
                    });
                  }

                  return DatalogicScannerListener(
                    onBarcodeScanned: (code) {
                      ScannerHandler.procesarCodigoEscaneado(
                        context,
                        code,
                        selectedHospital,
                      );
                    },
                    child: ScannerContent(
                      state: state,
                      hospitales: hospitales,
                      locations: locations,
                      productos: productos,
                      selectedHospital: selectedHospital,
                      selectedLocation: selectedLocation,
                      isManualInput: _isManualInput,
                      hayConexion: _hayConexion,
                      onHospitalSelected: (hospital) {
                        setState(() {
                          selectedHospital = hospital;
                        });
                        ScannerHandler.seleccionarHospital(context, hospital);
                      },
                      onLocationSelected: (location) {
                        setState(() {
                          selectedLocation = location;
                        });
                        print(selectedLocation?.toJson());
                        ScannerHandler.seleccionarUbicacion(context, location);
                      },
                      onToggleManualInput: _toggleManualInput,
                      onManualCodeSubmitted: _onManualCodeSubmitted,
                      onCloseManualInput: _closeManualInput,
                      onRemoveProduct: (producto) {
                        ScannerHandler.eliminarProducto(context, producto);
                      },
                      onUndoRemoveProduct: (producto, index) {
                        setState(() {
                          if (index < productos.length) {
                            productos.insert(index, producto);
                          } else {
                            productos.add(producto);
                          }
                        });
                      },
                      onSaveProducts: () {
                        ScannerHandler.guardarProductos(context);
                        setState(() {
                          _isManualInput = false;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
