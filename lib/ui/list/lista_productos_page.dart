import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/ui/product/producto_detalle_page.dart';
import 'package:provider/provider.dart';
import 'package:quilmedic/widgets/list/empty_products_message.dart';
import 'package:quilmedic/widgets/list/product_list_section.dart';

class ListaProductosPage extends StatefulWidget {
  final List<Producto>? productos;
  final int hospitalId;

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

  @override
  void initState() {
    super.initState();
    productos = widget.productos ?? [];

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
        actions: isVerySmallScreen ? [] : [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (context.read<ListaProductosBloc?>() != null) {
                BlocProvider.of<ListaProductosBloc>(context)
                    .add(CargarProductosEvent());
              }
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: isVerySmallScreen ? null : FloatingActionButton(
        onPressed: () {
          if (context.read<ListaProductosBloc?>() != null) {
            BlocProvider.of<ListaProductosBloc>(context)
                .add(CargarProductosEvent());
          }
        },
        child: const Icon(Icons.refresh),
      ),
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
    
    final int hospitalId = widget.hospitalId; 

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
                    onProductTap: (producto) => _navegarADetalle(context, producto),
                  ),
                  
                  if (productosOtrosAlmacenes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ProductListSection(
                      title: 'Productos de otros almacenes',
                      productos: productosOtrosAlmacenes,
                      headerColor: Colors.orange,
                      rowColor: Colors.orange.shade50,
                      onProductTap: (producto) => _navegarADetalle(context, producto),
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
      if (widget.productos == null && Provider.of<ListaProductosBloc?>(context, listen: false) != null) {
        Provider.of<ListaProductosBloc>(context, listen: false).add(CargarProductosEvent());
      } else if (widget.productos != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ListaProductosPage(
              productos: null, 
              hospitalId: widget.hospitalId,
            ),
          ),
        );
      }
    }
  }
}
