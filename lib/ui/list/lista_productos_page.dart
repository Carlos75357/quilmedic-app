import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/ui/product/producto_detalle_page.dart';
import 'package:provider/provider.dart';
import 'package:quilmedic/widgets/list/empty_products_message.dart';
import 'package:quilmedic/widgets/list/product_list_section.dart';
import 'package:quilmedic/data/respository/hospital_repository.dart';
import 'package:quilmedic/data/json/api_client.dart';

class ListaProductosPage extends StatefulWidget {
  final List<Producto>? productos;
  final String hospitalId;

  const ListaProductosPage({
    super.key,
    this.productos,
    required this.hospitalId,
  });

  @override
  State<ListaProductosPage> createState() => _ListaProductosPageState();
}

class _ListaProductosPageState extends State<ListaProductosPage> {
  late List<Producto> productos;
  final ApiClient _apiClient = ApiClient();
  late final HospitalRepository _hospitalRepository;
  List<Hospital> _hospitales = [];
  String? _errorCargaHospitales;

  @override
  void initState() {
    super.initState();
    productos = widget.productos ?? [];
    _hospitalRepository = HospitalRepository(apiClient: _apiClient);

    if (productos.isEmpty && context.read<ListaProductosBloc?>() != null) {
      BlocProvider.of<ListaProductosBloc>(context).add(CargarProductosEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerySmallScreen = MediaQuery.of(context).size.width < 320;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions:
            isVerySmallScreen
                ? []
                : [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      if (context.read<ListaProductosBloc?>() != null) {
                        BlocProvider.of<ListaProductosBloc>(
                          context,
                        ).add(CargarProductosEvent());
                      }
                    },
                    tooltip: 'Actualizar',
                  ),
                  if (productos.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () => _cargarHospitalesYMostrarDialogo(),
                      tooltip: 'Trasladar todos',
                    ),
                ],
      ),
      floatingActionButton: productos.isNotEmpty 
          ? FloatingActionButton.extended(
              onPressed: () => _cargarHospitalesYMostrarDialogo(),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Trasladar todos'),
              backgroundColor: Colors.orange,
            )
          : null,
      body: SafeArea(
        child:
            widget.productos != null
                ? _buildProductosContent()
                : BlocListener<ListaProductosBloc, ListaProductosState>(
                  listener: (context, state) {
                    if (state is ListaProductosError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (state is ProductosCargadosState) {
                      setState(() {
                        productos = state.productos;
                      });
                    }
                  },
                  child: BlocBuilder<ListaProductosBloc, ListaProductosState>(
                    builder: (context, state) {
                      if (state is ListaProductosLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return _buildProductosContent();
                    },
                  ),
                ),
      ),
    );
  }

  Widget _buildProductosContent() {
    if (productos.isEmpty) {
      return const EmptyProductsMessage();
    }

    return _buildProductosLayout();
  }

  Widget _buildProductosLayout() {
    final List<Producto> productosAlmacenActual = [];
    final List<Producto> productosOtrosAlmacenes = [];

    final String hospitalId = widget.hospitalId;

    for (var producto in productos) {
      if (producto.codigoalmacen == hospitalId) {
        productosAlmacenActual.add(producto);
      } else {
        productosOtrosAlmacenes.add(producto);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Productos: ${productos.length}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Toca una fila para ver detalles',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductListSection(
                    title: 'Productos del almacén $hospitalId',
                    productos: productosAlmacenActual,
                    headerColor: Colors.blue,
                    rowColor: Colors.grey.shade50,
                    onProductTap:
                        (producto) => _navegarADetalle(context, producto),
                  ),

                  if (productosOtrosAlmacenes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ProductListSection(
                      title: 'Productos de otros almacenes',
                      productos: productosOtrosAlmacenes,
                      headerColor: Colors.orange,
                      rowColor: Colors.orange.shade50,
                      onProductTap:
                          (producto) => _navegarADetalle(context, producto),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navegarADetalle(BuildContext context, Producto producto) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoDetallePage(producto: producto),
      ),
    );

    if (result == true && context.mounted) {
      if (widget.productos == null &&
          Provider.of<ListaProductosBloc?>(context, listen: false) != null) {
        Provider.of<ListaProductosBloc>(
          context,
          listen: false,
        ).add(CargarProductosEvent());
      } else if (widget.productos != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ListaProductosPage(
              productos: widget.productos,
              hospitalId: widget.hospitalId,
            ),
          ),
        );
      }
    }
  }
  
  Future<void> _cargarHospitalesYMostrarDialogo() async {
    setState(() {
      _errorCargaHospitales = null;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Cargando hospitales'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando lista de hospitales...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    
    try {
      final response = await _hospitalRepository.getAllHospitals();
      
      if (context.mounted) {
        Navigator.of(context).pop();
        
        if (response.success) {
          setState(() {
            _hospitales = List<Hospital>.from(response.data);
          });
          
          _mostrarDialogoConfirmacionTrasladoMasivo(context, _hospitales);
        } else {
          setState(() {
            _errorCargaHospitales = response.message ?? 'Error al cargar hospitales';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorCargaHospitales!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        
        setState(() {
          _errorCargaHospitales = 'Error al cargar hospitales: ${e.toString()}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorCargaHospitales!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _mostrarDialogoConfirmacionTrasladoMasivo(BuildContext context, List<Hospital> hospitales) {
    String? selectedHospitalId;
    String? selectedHospitalName;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trasladar productos'),
        content: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Seleccionar Hospital Destino',
            border: OutlineInputBorder(),
          ),
          items: hospitales
              .where((h) => h.id != widget.hospitalId)
              .map((hospital) {
            return DropdownMenuItem<String>(
              value: hospital.id,
              child: Text(hospital.nombre),
            );
          }).toList(),
          onChanged: (value) {
            selectedHospitalId = value;
            if (value != null) {
              selectedHospitalName = hospitales
                  .firstWhere((h) => h.id == value)
                  .nombre;
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (selectedHospitalId != null && selectedHospitalName != null) {
                Navigator.of(context).pop();
                
                _enviarSolicitudTrasladoMasivo(
                  selectedHospitalId!,
                  selectedHospitalName!,
                  "",
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes seleccionar un hospital destino'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
  
  void _enviarSolicitudTrasladoMasivo(String hospitalDestinoId, String hospitalDestinoNombre, String comentarios) {
    // En una implementación real, aquí enviaríamos los datos al backend
    // Por ejemplo:
    // final Map<String, dynamic> data = {
    //   'productos': productos.map((p) => p.numerodeproducto).toList(),
    //   'hospital_origen_id': widget.hospitalId,
    //   'hospital_destino_id': hospitalDestinoId,
    //   'hospital_destino_nombre': hospitalDestinoNombre,
    // };
    // apiClient.post('/solicitudes-traslado-masivo', data);
    
    // Por ahora, solo mostramos un mensaje de éxito
    if (productos.isNotEmpty) {
      BlocProvider.of<ListaProductosBloc>(context).add(
        EnviarSolicitudTrasladoEvent(
          producto: productos.first, 
          hospitalDestinoId: hospitalDestinoId,
          hospitalDestinoNombre: hospitalDestinoNombre,
          comentarios: "",
        )
      );
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitud de traslado enviada correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
