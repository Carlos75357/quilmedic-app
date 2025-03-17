import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/ui/list/lista_productos_page.dart';
import 'package:quilmedic/widgets/scanner/empty_products_view.dart';
import 'package:quilmedic/widgets/scanner/manual_code_input.dart';
import 'package:quilmedic/widgets/scanner/productos_list.dart';
import 'package:quilmedic/widgets/scanner/save_button.dart';
import 'package:quilmedic/widgets/scanner/scanner_button.dart';
import 'package:quilmedic/widgets/scanner/scanner_view.dart';
import 'package:quilmedic/widgets/scanner/selector_hospital.dart';
import 'escaner_bloc.dart';

class EscanerPage extends StatefulWidget {
  const EscanerPage({super.key});

  @override
  State<EscanerPage> createState() => _EscanerPageState();
}

class _EscanerPageState extends State<EscanerPage> {
  final TextEditingController _hospitalesController = TextEditingController();
  MobileScannerController? _scannerController;
  Hospital? selectedHospital;
  List<ProductoEscaneado> productos = [];
  bool isScanning = false;
  bool _isManualInput = false;
  bool _isProcessingBarcode = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<EscanerBloc>(context).add(LoadHospitales());
  }

  @override
  void dispose() {
    _hospitalesController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  void _startScanner() {
    _scannerController ??= MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: const [
        BarcodeFormat.ean8,
        BarcodeFormat.ean13,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.code128,
        BarcodeFormat.itf,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.codabar,
        BarcodeFormat.dataMatrix,
        BarcodeFormat.qrCode,
      ],
    );
    _scannerController!.start();
  }

  void _stopScanner() {
    if (_scannerController != null) {
      _scannerController!.stop();
      setState(() => isScanning = false);
    }
  }

  void _toggleManualInput() {
    setState(() {
      _isManualInput = !_isManualInput;
      if (isScanning) {
        _stopScanner();
      }
    });
  }

  void _onBarcodeDetected(Barcode barcode, BuildContext context) {
    if (barcode.rawValue != null && !_isProcessingBarcode) {
      setState(() {
        _isProcessingBarcode = true;
      });

      final String qrCode = barcode.rawValue!;
      _stopScanner();
      BlocProvider.of<EscanerBloc>(context).add(QrCodeScannedEvent(qrCode));

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isProcessingBarcode = false;
          });
        }
      });
    }
  }

  void _onManualCodeSubmitted(String code, BuildContext context) {
    BlocProvider.of<EscanerBloc>(context).add(QrCodeScannedEvent(code));
    setState(() {
      _isManualInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Escáner de productos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_isManualInput ? Icons.qr_code_scanner : Icons.keyboard),
            onPressed: _toggleManualInput,
            tooltip:
                _isManualInput ? 'Usar escáner' : 'Ingresar código manualmente',
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<EscanerBloc, EscanerState>(
          listener: (context, state) {
            if (state is EscanerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ProductoEscaneadoExistenteState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'El producto ${state.producto.serie} ya existe',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (state is ProductoEscaneadoGuardadoState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Producto ${state.producto.serie} guardado'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ProductoEnOtroAlmacenState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'El producto ${state.productoEscaneado.serie} está asignado al almacén ${state.almacenCorrecto}',
                  ),
                  backgroundColor: Colors.amber,
                  duration: const Duration(seconds: 5),
                ),
              );
            } else if (state is ProductosListadosState) {
              setState(() {
                productos = state.productos;
              });
            } else if (state is GuardarSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Productos guardados correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ProductosRecibidosState) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListaProductosPage(
                        productos: state.productos,
                        hospitalId: context.read<EscanerBloc>().hospitalSeleccionado?.id ?? 0,
                      ),
                    ),
                  );
            }
          },
          child: BlocBuilder<EscanerBloc, EscanerState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Selector de hospital
                      BlocBuilder<EscanerBloc, EscanerState>(
                        buildWhen:
                            (previous, current) =>
                                current is HospitalesCargados ||
                                previous is EscanerInitial,
                        builder: (context, state) {
                          List<Hospital> hospitales = [];
                          if (state is HospitalesCargados) {
                            hospitales = state.hospitales;
                          }
                          return SelectorHospital(
                            hospitales: hospitales,
                            selectedHospital: selectedHospital,
                            onHospitalSelected: (hospital) {
                              setState(() {
                                selectedHospital = hospital;
                              });
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Botón de escaneo
                      if (isScanning)
                        ScannerView(
                          controller: _scannerController!,
                          onBarcodeDetected:
                              (barcode) => _onBarcodeDetected(barcode, context),
                          onClose: () {
                            setState(() {
                              isScanning = false;
                            });
                            _stopScanner();
                          },
                        )
                      else if (_isManualInput)
                        ManualCodeInput(
                          onCodeSubmitted:
                              (code) => _onManualCodeSubmitted(code, context),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ScannerButton(
                              onPressed: () {
                                if (selectedHospital != null) {
                                  setState(() {
                                    isScanning = true;
                                  });
                                  BlocProvider.of<EscanerBloc>(
                                    context,
                                  ).add(ElegirHospitalEvent(selectedHospital!));
                                  BlocProvider.of<EscanerBloc>(
                                    context,
                                  ).add(EscanearCodigoEvent());
                                  _startScanner();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Debe seleccionar un hospital',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                            ElevatedButton.icon(
                              onPressed: _toggleManualInput,
                              icon: const Icon(Icons.keyboard),
                              label: const Text('Ingresar código'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Título de la lista de productos
                      if (productos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Productos escaneados (${productos.length})',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Listado de productos o mensaje de vacío
                      SizedBox(
                        height: 300,
                        child:
                            productos.isNotEmpty
                                ? ProductosList(
                                  productos: productos,
                                  onRemove: (producto) {
                                    setState(() {
                                      productos.removeWhere(
                                        (p) =>
                                            p.id == producto.id &&
                                            p.serie == producto.serie,
                                      );
                                    });
                                  },
                                  onUndoRemove: (producto, index) {
                                    setState(() {
                                      if (index < productos.length) {
                                        productos.insert(index, producto);
                                      } else {
                                        productos.add(producto);
                                      }
                                    });
                                  },
                                )
                                : const EmptyProductsView(),
                      ),

                      // Botón de guardar
                      if (productos.isNotEmpty)
                        SaveButton(
                          onPressed: () {
                            BlocProvider.of<EscanerBloc>(
                              context,
                            ).add(GuardarProductosEvent());
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
