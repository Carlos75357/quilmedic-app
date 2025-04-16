import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/ui/list/lista_productos_page.dart';
import 'package:quilmedic/utils/alarm_utils.dart';
import 'package:quilmedic/widgets/scanner/empty_products_view.dart';
import 'package:quilmedic/widgets/scanner/manual_code_input.dart';
import 'package:quilmedic/widgets/scanner/productos_list.dart';
import 'package:quilmedic/widgets/scanner/save_button.dart';
import 'package:quilmedic/widgets/scanner/selector.dart';
import 'package:quilmedic/widgets/scanner/datalogic_scanner.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'dart:async';
import 'escaner_bloc.dart';

class EscanerPage extends StatefulWidget {
  const EscanerPage({super.key});

  @override
  State<EscanerPage> createState() => _EscanerPageState();
}

class _EscanerPageState extends State<EscanerPage> {
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

  @override
  void initState() {
    super.initState();
    _checkPendingProducts();
    _updateAlarmsIfNeeded();
    BlocProvider.of<EscanerBloc>(context).add(LoadHospitales());
  }
  
  Future<void> _updateAlarmsIfNeeded() async {
    final alarmUtils = AlarmUtils();
    
    await alarmUtils.loadAlarmsFromCache();
  }

  @override
  void dispose() {
    _hospitalesController.dispose();
    super.dispose();
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
          content: const Text('Escaneando sin almacén seleccionado. Selecciona un almacén antes de guardar.'),
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
          if (_hayProductosPendientes)
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () {
                BlocProvider.of<EscanerBloc>(
                  context,
                ).add(SincronizarProductosPendientesEvent());
              },
              tooltip: 'Sincronizar productos pendientes',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Recargar hospitales
              BlocProvider.of<EscanerBloc>(context).add(LoadHospitales());
              
              // Forzar actualización de alarmas
              final alarmUtils = AlarmUtils();
              alarmUtils.forceRefresh().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alarmas actualizadas correctamente'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              });
            },
            tooltip: 'Recargar datos',
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
              setState(() {
                productos = state.productos;
              });
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
              setState(() {
                productos = [];
                _hayProductosPendientes = true;
              });
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
              setState(() {
                _hayProductosPendientes = false;
              });
            } else if (state is ProductosRecibidosState) {
              if (state.mensaje != null && state.mensaje!.contains("No se encontraron")) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.mensaje!),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 5),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
                  ),
                );
              }
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ListaProductosPage(
                        productos: state.productos,
                        location: context
                            .read<EscanerBloc>()
                            .locationSeleccionada,
                        notFounds: state.productosNotFound,
                        hospitalId:
                            context
                                .read<EscanerBloc>()
                                .hospitalSeleccionado
                                ?.id ??
                            0,
                        locationId: context
                            .read<EscanerBloc>()
                            .locationSeleccionada
                            ?.id,
                        almacenName: context
                            .read<EscanerBloc>()
                            .hospitalSeleccionado
                            ?.description ?? '',
                      ),
                ),
              ).then((_) {
                _resetSelections();
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
              setState(() {
                _hayProductosPendientes = false;
              });
            } else if (state is HospitalesCargados) {
              setState(() {
                selectedHospital = null;
              });
            }
          },
          child: BlocBuilder<EscanerBloc, EscanerState>(
            builder: (context, state) {
              return DatalogicScanner(
                child: _buildContent(state),
                onBarcodeScanned: (code) {
                  BlocProvider.of<EscanerBloc>(context).add(SubmitCodeEvent(code));
                  if (selectedHospital == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Escaneando sin almacén seleccionado. Selecciona un almacén antes de guardar.'),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.only(bottom: 80, right: 20, left: 20),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(EscanerState state) {
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<EscanerBloc, EscanerState>(
            builder: (context, state) {
              if (state is HospitalesCargados) {
                hospitales = state.hospitales;
              }
              if (state is LocationsCargadas) {
                locations = state.locations;
              }
              return Selector(
                hospitales: hospitales,
                selectedHospital: selectedHospital,
                onOptionsSelected: (hospital) {
                  setState(() {
                    selectedHospital = hospital;
                  });
                },
                locations: locations,
                onLocationSelected: (location) {
                  setState(() {
                    selectedLocation = location;
                  });
                },
              );
            },
          ),

          const SizedBox(height: 12),

          if (_isManualInput)
            ManualCodeInput(
              onCodeSubmitted: (code) => _onManualCodeSubmitted(code, context),
              onClose: _closeManualInput,
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: _toggleManualInput,
                  icon: const Icon(Icons.keyboard, size: 18),
                  label: const Text('Ingresar código manualmente'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          if (productos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Productos escaneados (${productos.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

          Expanded(
            child:
                productos.isNotEmpty
                    ? ProductosList(
                      productos: productos,
                      onRemove: (producto) {
                        BlocProvider.of<EscanerBloc>(
                          context,
                        ).add(EliminarProductoEvent(producto));
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
                    : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: const EmptyProductsView(),
                          ),
                        );
                      },
                    ),
          ),


          if (state is! EscanerLoading) ...[
            if (selectedHospital != null)
              SaveButton(
                onPressed: () {
                  BlocProvider.of<EscanerBloc>(
                    context,
                  ).add(GuardarProductosEvent());
                },
                hayConexion: _hayConexion,
              ),
          ],
        ],
      ),
    );
  }
}
