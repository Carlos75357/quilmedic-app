import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/utils/alarm_utils.dart';

class ProductoDetallePage extends StatefulWidget {
  final Producto producto;

  const ProductoDetallePage({super.key, required this.producto});

  @override
  State<ProductoDetallePage> createState() => _ProductoDetallePageState();
}

class _ProductoDetallePageState extends State<ProductoDetallePage> {
  Color? expiryColor;
  Color? stockColor;
  bool isLoading = true;
  final AlarmUtils _alarmUtils = AlarmUtils();

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  Future<void> _loadColors() async {
    try {
      
      final expColor = await _alarmUtils.setColorExpirationDate(
        widget.producto.fechacaducidad, 
        widget.producto.numerodeproducto
      );
      
      final stColor = _getStockColor(widget.producto.cantidad);

      if (mounted) {
        setState(() {
          expiryColor = expColor;
          stockColor = stColor;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          expiryColor = Colors.grey.withOpacity(0.3);
          stockColor = widget.producto.cantidad > 0 
              ? Colors.green.withOpacity(0.3) 
              : Colors.red.withOpacity(0.3);
          isLoading = false;
        });
      }
    }
  }

  Color _getStockColor(int stock) {
    if (stock <= 0) {
      return Colors.red.withOpacity(0.3); // Sin stock
    } else {
      return Colors.green.withOpacity(0.3); // Con stock
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context),
                  const SizedBox(height: 16),
                  _buildExpiryInfo(context),
                  const SizedBox(height: 16),
                  _buildStockInfo(context),
                  const SizedBox(height: 24),
                  _buildLocationInfo(context),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.producto.descripcion ?? 'Sin descripción',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('ID Producto:', widget.producto.numerodeproducto),
            _buildInfoRow('Serie:', widget.producto.serie),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryInfo(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Caducidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Row(
              children: [
                const Text(
                  'Fecha de Caducidad:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: expiryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDate(widget.producto.fechacaducidad),
                    style: TextStyle(
                      color: expiryColor == Colors.red ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Stock',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Row(
              children: [
                const Text(
                  'Cantidad Disponible:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: stockColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.producto.cantidad.toString(),
                    style: TextStyle(
                      color: stockColor == Colors.red ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('Almacén:', 'ID: ${widget.producto.codigoalmacen}'),
            _buildInfoRow('Lote:', widget.producto.numerolote.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
