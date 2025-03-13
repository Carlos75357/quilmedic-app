import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

class EscanerPage extends StatefulWidget {
  const EscanerPage({super.key});

  @override
  State<EscanerPage> createState() => _EscanerPageState();
}

class _EscanerPageState extends State<EscanerPage> {
  late TextEditingController _hospitalesController;
  MobileScannerController? _scannerController;
  Hospital? selectedHospital;
  List<Hospital> hospitales = [];
  List<ProductoScaneado> productos = [];
  bool isScanning = false;
  bool _isProcessingQR = false;

  @override
  void initState() {
    super.initState();
    _hospitalesController = TextEditingController();
    BlocProvider.of<EscanerBloc>(context).add(LoadHospitales());
  }

  @override
  void dispose() {
    _hospitalesController.dispose();
    _stopScanner();
    super.dispose();
  }
  
  void _startScanner() {
    _scannerController ??= MobileScannerController();
    _scannerController!.start();
  }
  
  void _stopScanner() {
    if (_scannerController != null) {
      _scannerController!.stop();
      _scannerController!.dispose();
      _scannerController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Escáner QR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,
      ),
      body: SafeArea(
        child: BlocListener<EscanerBloc, EscanerState>(
          listener: (context, state) {
            if (state is HospitalesCargados) {
              setState(() {
                hospitales = state.hospitales;
              });
            } else if (state is ProductoScaneadoGuardadoState) {
              setState(() {
                isScanning = false;
                _isProcessingQR = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Producto "${state.producto.nombre}" guardado correctamente',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ProductoScaneadoExistenteState) {
              setState(() {
                isScanning = false;
                _isProcessingQR = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'El producto "${state.producto.nombre}" ya existe en la base de datos',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (state is EscanerError) {
              setState(() {
                isScanning = false;
                _isProcessingQR = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ProductosListadosState) {
              setState(() {
                productos = state.productos;
              });
            } else if (state is GuardarSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Productos guardados correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: BlocBuilder<EscanerBloc, EscanerState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selector de hospital
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seleccionar Hospital',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Hospital>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'Seleccionar Hospital',
                              ),
                              value: selectedHospital,
                              items: hospitales.map<DropdownMenuItem<Hospital>>(
                                (Hospital value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value.nombre),
                                  );
                                },
                              ).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedHospital = value;
                                    _hospitalesController.text = value.nombre;
                                  });
                                  BlocProvider.of<EscanerBloc>(
                                    context,
                                  ).add(ElegirHospitalEvent(value));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botón de escaneo
                    isScanning
                        ? Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    height: screenSize.height * 0.3,
                                    width: double.infinity,
                                    child: MobileScanner(
                                      controller: _scannerController,
                                      onDetect: (capture) {
                                        if (_isProcessingQR) return;
                                        
                                        final List<Barcode> barcodes =
                                            capture.barcodes;
                                        for (final barcode in barcodes) {
                                          if (barcode.rawValue != null) {
                                            final String qrCode = barcode.rawValue!;
                                            setState(() {
                                              _isProcessingQR = true;
                                            });
                                            BlocProvider.of<EscanerBloc>(
                                              context,
                                            ).add(QrCodeScannedEvent(qrCode));
                                            _stopScanner();
                                            break;
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: FloatingActionButton.small(
                                    onPressed: () {
                                      setState(() {
                                        isScanning = false;
                                        _isProcessingQR = false;
                                      });
                                      _stopScanner();
                                    },
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 4,
                                    child: const Icon(Icons.close),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  width: screenSize.width * 0.5,
                                  height: screenSize.width * 0.5,
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Escanear Código QR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (selectedHospital != null) {
                                  setState(() {
                                    isScanning = true;
                                    _isProcessingQR = false;
                                  });
                                  _startScanner();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Debe seleccionar un hospital primero',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
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
                              'Productos Escaneados',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              '${productos.length} items',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Listado de productos
                    Expanded(
                      child: productos.isNotEmpty
                          ? Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.separated(
                                padding: const EdgeInsets.all(8),
                                itemCount: productos.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: Colors.grey.shade300,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final producto = productos[index];
                                  return Dismissible(
                                    key: Key(producto.id.toString() + producto.serie.toString()),
                                    background: Container(
                                      color: Colors.red.shade100,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 16),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      setState(() {
                                        productos.remove(producto);
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Producto "${producto.nombre}" eliminado'),
                                          action: SnackBarAction(
                                            label: 'Deshacer',
                                            onPressed: () {
                                              setState(() {
                                                productos.insert(index, producto);
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      title: Text(
                                        producto.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.numbers,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'ID: ${producto.id}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.qr_code,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Serie: ${producto.serie}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.red.shade400,
                                        onPressed: () {
                                          setState(() {
                                            productos.remove(producto);
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hay productos escaneados',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Escanea un código QR para comenzar',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    
                    // Botón de guardar
                    if (productos.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('GUARDAR PRODUCTOS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            BlocProvider.of<EscanerBloc>(
                              context,
                            ).add(GuardarProductosEvent(productos));
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
