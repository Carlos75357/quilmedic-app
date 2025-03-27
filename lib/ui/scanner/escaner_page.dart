import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/ui/list/lista_productos_page.dart';
import 'package:quilmedic/widgets/scanner/empty_products_view.dart';
import 'package:quilmedic/widgets/scanner/manual_code_input.dart';
import 'package:quilmedic/widgets/scanner/productos_list.dart';
import 'package:quilmedic/widgets/scanner/save_button.dart';
import 'package:quilmedic/widgets/scanner/selector_hospital.dart';
import 'package:quilmedic/data/local/producto_local_storage.dart';
import 'package:quilmedic/utils/connectivity_service.dart';
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
  List<ProductoEscaneado> productos = [];
  bool isScanning = false;
  bool _isManualInput = false;
  bool _hayConexion = true;
  bool _hayProductosPendientes = false;
  Timer? _conectividadTimer;

  @override
  void initState() {
    super.initState();
    _checkPendingProducts();
    BlocProvider.of<EscanerBloc>(context).add(LoadHospitales());
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _verificarConectividad();
        _conectividadTimer = Timer.periodic(const Duration(seconds: 30), (
          timer,
        ) {
          if (mounted) {
            _verificarConectividad();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _hospitalesController.dispose();
    _conectividadTimer?.cancel();

    super.dispose();
  }

  Future<void> _verificarConectividad() async {
    try {
      final hayConexion = await ConnectivityService.hayConexionInternet();
      if (mounted) {
        if (hayConexion && !_hayConexion && _hayProductosPendientes) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              BlocProvider.of<EscanerBloc>(
                context,
              ).add(SincronizarProductosPendientesEvent());
            }
          });
        }
        setState(() {
          _hayConexion = hayConexion;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hayConexion = false;
        });
      }
      debugPrint('Error al verificar la conectividad: $e');
    }
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
            } else if (state is GuardarOfflineSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 5),
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
                ),
              );
              setState(() {
                _hayProductosPendientes = false;
              });
            } else if (state is ProductosRecibidosState) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ListaProductosPage(
                        productos: state.productos,
                        hospitalId:
                            context
                                .read<EscanerBloc>()
                                .hospitalSeleccionado
                                ?.id ??
                            0,
                      ),
                ),
              );
            } else if (state is SinProductosPendientesState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.blue,
                ),
              );
              setState(() {
                _hayProductosPendientes = false;
              });
            }
          },
          child: BlocBuilder<EscanerBloc, EscanerState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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

                    const SizedBox(height: 12),

                    if (_isManualInput)
                      ManualCodeInput(
                        onCodeSubmitted:
                            (code) => _onManualCodeSubmitted(code, context),
                      )
                    else
                      Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _toggleManualInput,
                            icon: const Icon(Icons.keyboard, size: 28),
                            label: const Text(
                              'Ingresar código',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 44,
                                vertical: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
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
                              style: theme.textTheme.titleMedium?.copyWith(
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

                    if (_hayProductosPendientes)
                      Container(
                        margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.amber.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8.0),
                            onTap: () {
                              BlocProvider.of<EscanerBloc>(
                                context,
                              ).add(SincronizarProductosPendientesEvent());
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.sync_problem,
                                    color: Colors.amber.shade800,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Productos pendientes',
                                          style: TextStyle(
                                            color: Colors.amber.shade900,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Hay productos guardados localmente pendientes de sincronizar',
                                          style: TextStyle(
                                            color: Colors.amber.shade800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade600,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.sync,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Sincronizar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
            },
          ),
        ),
      ),
    );
  }
}
