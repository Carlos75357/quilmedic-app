import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/ui/product/producto_detalle_page.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: SafeArea(
        child:
            widget.productos != null
                ? _buildProductosTable()
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
                      return _buildProductosTable();
                    },
                  ),
                ),
      ),
    );
  }

  Widget _buildProductosTable() {
    if (productos.isEmpty) {
      return const Center(
        child: Text(
          'No hay productos para mostrar',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

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
          
          // Contenedor para ambas tablas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Primera tabla
                Text(
                  'Productos del almacén $hospitalId (${productosAlmacenActual.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: WidgetStateColor.resolveWith(
                        (states) => Colors.blue.shade100,
                      ),
                      dataRowMinHeight: 64,
                      dataRowMaxHeight: 80,
                      columnSpacing: 24,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      dataTextStyle: const TextStyle(fontSize: 16),
                      columns: const [
                        DataColumn(label: Expanded(child: Text('Descripción'))),
                        DataColumn(label: Expanded(child: Text('Caducidad'))),
                        DataColumn(label: Expanded(child: Text('Stock'))),
                        DataColumn(label: Expanded(child: Text('Acciones'))),
                      ],
                      rows: List<DataRow>.generate(
                        productosAlmacenActual.length,
                        (index) => DataRow(
                          color: WidgetStateProperty.resolveWith<Color?>((
                            Set<WidgetState> states,
                          ) {
                            if (index % 2 == 0) {
                              return Colors.grey.shade50;
                            }
                            return null;
                          }),
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 100,
                                child: Text(
                                  productosAlmacenActual[index].descripcion ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              onTap: () => _navegarADetalle(context, productosAlmacenActual[index]),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getColorForExpiryDate(productosAlmacenActual[index].fechacaducidad),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _formatDate(productosAlmacenActual[index].fechacaducidad),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () => _navegarADetalle(context, productosAlmacenActual[index]),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getColorForStock(productosAlmacenActual[index].stock),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${productosAlmacenActual[index].stock}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () => _navegarADetalle(context, productosAlmacenActual[index]),
                            ),
                            DataCell(
                              ElevatedButton.icon(
                                onPressed:
                                    () => _navegarADetalle(context, productosAlmacenActual[index]),
                                icon: const Icon(Icons.visibility, size: 20),
                                label: const Text('Ver'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Segunda tabla (si hay productos de otros almacenes)
                if (productosOtrosAlmacenes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Productos de otros almacenes (${productosOtrosAlmacenes.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: WidgetStateColor.resolveWith(
                          (states) => Colors.orange.shade100,
                        ),
                        dataRowMinHeight: 64,
                        dataRowMaxHeight: 80,
                        columnSpacing: 24,
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        dataTextStyle: const TextStyle(fontSize: 16),
                        columns: const [
                          DataColumn(label: Expanded(child: Text('Descripción'))),
                          DataColumn(label: Expanded(child: Text('Caducidad'))),
                          DataColumn(label: Expanded(child: Text('Stock'))),
                          DataColumn(label: Expanded(child: Text('Acciones'))),
                        ],
                        rows: List<DataRow>.generate(
                          productosOtrosAlmacenes.length,
                          (index) => DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              if (index % 2 == 0) {
                                return Colors.orange.shade50;
                              }
                              return null;
                            }),
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    productosOtrosAlmacenes[index].descripcion ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                onTap: () => _navegarADetalle(context, productosOtrosAlmacenes[index]),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getColorForExpiryDate(productosOtrosAlmacenes[index].fechacaducidad),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _formatDate(productosOtrosAlmacenes[index].fechacaducidad),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onTap: () => _navegarADetalle(context, productosOtrosAlmacenes[index]),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getColorForStock(productosOtrosAlmacenes[index].stock),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${productosOtrosAlmacenes[index].stock}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onTap: () => _navegarADetalle(context, productosOtrosAlmacenes[index]),
                              ),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed:
                                      () => _navegarADetalle(context, productosOtrosAlmacenes[index]),
                                  icon: const Icon(Icons.visibility, size: 20),
                                  label: const Text('Ver'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navegarADetalle(BuildContext context, Producto producto) async {
    // Esperamos el resultado de la navegación
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoDetallePage(producto: producto),
      ),
    );
    
    // Si result es true, significa que se realizó un traslado y debemos recargar los datos
    if (result == true) {
      // Recargamos los productos
      if (widget.productos == null && context.read<ListaProductosBloc?>() != null) {
        BlocProvider.of<ListaProductosBloc>(context).add(CargarProductosEvent());
      } else if (widget.productos != null) {
        // Si tenemos productos pasados como parámetro, necesitamos recargar la página completa
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ListaProductosPage(
              productos: null,  // Forzamos a que se carguen nuevamente
              hospitalId: widget.hospitalId,
            ),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getColorForExpiryDate(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    
    if (difference <= 1) {
      return Colors.grey[800]!.withValues(alpha: 0.3); // <= 1 día
    } else if (difference < 30) {
      return Colors.red[400]!.withValues(alpha: 0.3); // < 1 mes
    } else if (difference < 90) {
      return Colors.orange[300]!.withValues(alpha: 0.3); // < 3 meses
    } else if (difference < 180) {
      return Colors.yellow[300]!.withValues(alpha: 0.3); // < 6 meses
    } else if (difference < 365) {
      return Colors.green[200]!.withValues(alpha: 0.3); // > 6 meses
    } else {
      return Colors.green[600]!.withValues(alpha: 0.3); // > 1 año
    }
  }

  Color _getColorForStock(int stock) {
    if (stock <= 0) {
      return Colors.red[400]!.withValues(alpha: 0.3); // Sin stock
    } else {
      return Colors.green[400]!.withValues(alpha: 0.3); // Con stock
    }
  }
}
