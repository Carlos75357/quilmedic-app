import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';

/// Página que muestra una lista de productos
class ListaProductosPage extends StatefulWidget {
  final List<Producto>? productos;
  
  const ListaProductosPage({super.key, this.productos});

  @override
  State<ListaProductosPage> createState() => _ListaProductosPageState();
}

class _ListaProductosPageState extends State<ListaProductosPage> {
  late List<Producto> productos;

  @override
  void initState() {
    super.initState();
    // Inicializar la lista con los productos recibidos o una lista vacía
    productos = widget.productos ?? [];
    
    // Si no hay productos recibidos y hay un BlocProvider disponible, cargar productos
    if (productos.isEmpty && context.read<ListaProductosBloc?>() != null) {
      BlocProvider.of<ListaProductosBloc>(context).add(CargarProductosEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: SafeArea(
        child: widget.productos != null 
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
        child: Text('No hay productos para mostrar', 
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Productos: ${productos.length}',
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(1),  // Descripción
              1: FlexColumnWidth(2),  // Fecha
              2: FlexColumnWidth(1),  // Serie
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Encabezado de la tabla
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Caducidad', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Serie', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              // Filas de productos
              ...List.generate(
                productos.length,
                (index) => TableRow(
                  decoration: index % 2 == 0
                      ? BoxDecoration(color: Colors.grey.shade100)
                      : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(productos[index].descripcion ?? ''),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_formatDate(productos[index].fechacaducidad)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(productos[index].serie),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
