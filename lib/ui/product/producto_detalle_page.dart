import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/ui/product/producto_detalle_bloc.dart';

class ProductoDetallePage extends StatefulWidget {
  final Producto producto;

  const ProductoDetallePage({super.key, required this.producto});

  @override
  State<ProductoDetallePage> createState() => _ProductoDetallePageState();
}

class _ProductoDetallePageState extends State<ProductoDetallePage> {
  late final ProductoDetalleBloc _productoDetalleBloc;
  
  @override
  void initState() {
    super.initState();
    _productoDetalleBloc = ProductoDetalleBloc();
    _productoDetalleBloc.add(CargarHospitalesEvent());
  }
  
  @override
  void dispose() {
    _productoDetalleBloc.close();
    super.dispose();
  }

  void _mostrarDialogoTraslado(List<Hospital> hospitales) {
    final hospitalesFiltrados = hospitales
        .where((h) => h.id != widget.producto.codigoalmacen)
        .toList();

    if (hospitalesFiltrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay otros hospitales disponibles para trasladar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trasladar Producto'),
        content: DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Seleccionar Hospital Destino',
            border: OutlineInputBorder(),
          ),
          items: hospitalesFiltrados.map((hospital) {
            return DropdownMenuItem<int>(
              value: hospital.id,
              child: Text(hospital.nombre),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              Navigator.of(context).pop();
              _productoDetalleBloc.add(
                TrasladarProductoEvent(
                  productoId: widget.producto.numproducto,
                  nuevoHospitalId: value,
                ),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoConfirmacionTraslado(
    BuildContext context,
    String mensaje,
    dynamic producto,
    int almacenDestino,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Traslado'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _productoDetalleBloc.add(
                ConfirmarTrasladoProductoEvent(
                  productoId: widget.producto.numproducto,
                  nuevoHospitalId: almacenDestino,
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _productoDetalleBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Producto'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: BlocListener<ProductoDetalleBloc, ProductoDetalleState>(
          listener: (context, state) {
            if (state is ErrorCargaHospitalesState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensaje),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ProductoTrasladadoState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensaje),
                  backgroundColor: Colors.green,
                ),
              );
              // Regresamos a la página anterior con un resultado que indique que se debe recargar
              Navigator.pop(context, true);
            } else if (state is ErrorTrasladoProductoState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensaje),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ProductoEnOtroAlmacenState) {
              // Mostrar diálogo de confirmación
              _mostrarDialogoConfirmacionTraslado(
                context,
                state.mensaje,
                state.producto,
                state.almacenDestino, // Pasamos el almacén de destino
              );
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context),
                  
                  const SizedBox(height: 24),
                  
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.producto.descripcion ?? 'Sin descripción',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            
            const Divider(height: 32),
            
            _buildInfoRow(
              context, 
              'Serie:', 
              widget.producto.serie,
              Icons.qr_code,
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow(
              context, 
              'ID Producto:', 
              widget.producto.numproducto.toString(),
              Icons.tag,
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow(
              context, 
              'Lote:', 
              widget.producto.numerolote.toString(),
              Icons.inventory_2,
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow(
              context, 
              'Descripción del lote:', 
              widget.producto.descripcionlote,
              Icons.description,
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow(
              context, 
              'Fecha de caducidad:', 
              _formatDate(widget.producto.fechacaducidad),
              Icons.calendar_today,
            ),
            
            const SizedBox(height: 16),
            
            _buildStockRow(context),
            
            const SizedBox(height: 16),
            
            _buildInfoRow(
              context, 
              'Código de almacén:', 
              widget.producto.codigoalmacen.toString(),
              Icons.warehouse,
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow(
              context, 
              'Ubicación:', 
              widget.producto.ubicacion,
              Icons.place,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String? value, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value ?? 'No disponible',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockRow(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.inventory,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stock:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getColorForStock(widget.producto.stock),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${widget.producto.stock}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForStock(int stock) {
    if (stock <= 0) {
      return Colors.red[400]!.withOpacity(0.3); // Sin stock
    } else {
      return Colors.green[400]!.withOpacity(0.3); // Con stock
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<ProductoDetalleBloc, ProductoDetalleState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: state is HospitalesCargadosState
                ? () => _mostrarDialogoTraslado(state.hospitales as List<Hospital>)
                : null,
              icon: const Icon(Icons.swap_horiz, size: 28),
              label: Text(
                state is TrasladandoProductoState
                  ? 'Trasladando...'
                  : 'Trasladar de almacén',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, size: 28),
              label: const Text(
                'Volver a la lista',
                style: TextStyle(fontSize: 18),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
