import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class EscanerPage extends StatefulWidget {
  const EscanerPage({super.key});

  @override
  State<EscanerPage> createState() => _EscanerPageState();
}

class _EscanerPageState extends State<EscanerPage> with WidgetsBindingObserver {
  final TextEditingController _hospitalesController = TextEditingController();
  Hospital? selectedHospital;
  Location? selectedLocation;
  List<ProductoEscaneado> productos = [];
  List<Hospital> hospitales = [];
  List<Location> locations = [];
  bool isScanning = false;
  bool _isManualInput = false;
  final bool _hayConexion = true;
  bool _hayProductosPendientes = false;
  
  DateTime _lastKeyEventTime = DateTime.now();
  int _consecutiveKeyEvents = 0;
  Timer? _scannerDetectionTimer;
  final FocusNode _globalFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkPendingProducts();
    BlocProvider.of<EscanerBloc>(context).add(LoadHospitales());
    
    WidgetsBinding.instance.addObserver(this);
  }

  // Future<void> _updateAlarmsIfNeeded() async {
  //   final alarmUtils = AlarmUtils();

  //   await alarmUtils.loadAlarmsFromCache();
  // }

  @override
  void dispose() {
    _hospitalesController.dispose();
    _scannerDetectionTimer?.cancel();
    _globalFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _consecutiveKeyEvents = 0;
    }
  }

  void _resetSelections() {
    setState(() {
      selectedHospital = null;
      selectedLocation = null;
    });
    BlocProvider.of<EscanerBloc>(context).add(ResetSelectionsEvent());
  }

  Future<void> _checkPendingProducts() async {
    final hayPendientes = await ProductoLocalStorage.hayProductosPendientes();
    if (mounted) {
      setState(() {
        _hayProductosPendientes = hayPendientes;
      });
    }
  }

  void _toggleManualInput() {
    setState(() {
      _isManualInput = !_isManualInput;
    });
  }

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

  void _closeManualInput() {
    setState(() {
      _isManualInput = false;
    });
  }

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
                  }
                  if (state is LocationsCargadas) {
                    selectedLocation = null;
                    locations = state.locations;
                  }

                  return DatalogicScannerListener(
                    onBarcodeScanned: (code) {
                      debugPrint('Código recibido del escáner Datalogic: $code');
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
