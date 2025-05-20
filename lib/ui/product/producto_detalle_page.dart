import 'package:flutter/material.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/utils/alarm_utils.dart';
import 'package:quilmedic/utils/services.dart';

/// Pantalla que muestra el detalle completo de un producto
/// Incluye información sobre descripción, fecha de caducidad, stock y ubicación
class ProductoDetallePage extends StatefulWidget {
  /// Producto a mostrar en detalle
  final Producto producto;
  /// Ubicación actual del producto
  final Location? location;
  /// Nombre del almacén o hospital donde se encuentra el producto
  final String? almacenName;

  /// Constructor de la página de detalle de producto
  /// @param [key] Clave del widget
  /// @param [producto] Producto a mostrar en detalle
  /// @param [location] Ubicación actual del producto
  /// @param [almacenName] Nombre del almacén o hospital
  const ProductoDetallePage({
    super.key,
    required this.producto,
    this.location,
    required this.almacenName,
  });

  /// Crea el estado mutable para este widget
  /// @return Una instancia de [_ProductoDetallePageState]
  @override
  State<ProductoDetallePage> createState() => _ProductoDetallePageState();
}

/// Estado mutable para la pantalla de detalle de producto
class _ProductoDetallePageState extends State<ProductoDetallePage> {
  /// Color para mostrar el estado de la fecha de caducidad
  Color? expiryColor;
  /// Color para mostrar el estado del stock
  Color? stockColor;
  /// Indica si se están cargando los datos
  bool isLoading = true;
  /// Utilidad para gestionar alarmas de productos
  final AlarmUtils _alarmUtils = AlarmUtils();

  /// Inicializa el estado del widget
  /// Carga los colores para las alarmas de caducidad y stock
  @override
  void initState() {
    super.initState();
    _loadColors();
  }
  
  /// Obtiene el stock mínimo para un producto específico
  /// Busca alarmas específicas para el producto y solo devuelve el stock mínimo
  /// si la alarma corresponde exactamente a la ubicación actual
  /// @param [productId] ID del producto
  /// @return [Future] Stock mínimo o null si no está definido o si la alarma no es para esta ubicación
  Future<int?> _getStockMinimo(int productId) async {
    final hasSpecific = await _alarmUtils.hasSpecificAlarms(productId);
    final locationId = widget.producto.locationid;
    
    if (hasSpecific) {
      final alarms = await _alarmUtils.getSpecificAlarmsForProduct(productId);
      for (var alarm in alarms) {
        if (alarm.type?.toLowerCase() == 'stock') {
          if (alarm.locationId != null && alarm.locationId == locationId) {
            final condition = alarm.condition;
            if (condition != null && condition.isNotEmpty) {
              final RegExp regExp = RegExp(r'(\D*)(\d+)');
              final Match? match = regExp.firstMatch(condition);

              if (match != null) {
                final value = int.parse(match.group(2)!);
                return value;
              }
            }
          }
        }
      }
    }
    
    return null;
  }

  /// Carga los colores para las alarmas de caducidad y stock
  /// Utiliza la caché de alarmas para obtener los colores
  /// @return [Future] Future que se completa cuando se han cargado los colores
  Future<void> _loadColors() async {
    try {
      await _alarmUtils.loadAlarmsFromCache();
      
      final expColor = _alarmUtils.getColorForExpiryFromCache(
        widget.producto.id, 
        widget.producto.expirationdate,
      );

      final stColor = _alarmUtils.getColorForStockFromCache(
        widget.producto.stock,
        widget.producto.id,
        widget.producto.locationid,
      );

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
          expiryColor = Colors.grey.withValues(alpha: 0.3);
          stockColor =
              widget.producto.stock > 0
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.3);
          isLoading = false;
        });
      }
    }
  }

  /// Construye la interfaz de usuario de la pantalla de detalle de producto
  /// @param [context] Contexto de construcción
  /// @return [Widget] con la estructura completa de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body:
          isLoading
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

  /// Construye la tarjeta con la información general del producto
  /// @param [context] Contexto de construcción
  /// @return [Widget] con la tarjeta de información
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.producto.description ?? 'Sin descripción',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('ID Producto:', widget.producto.productcode),
            _buildInfoRow('serialnumber:', widget.producto.serialnumber),
          ],
        ),
      ),
    );
  }

  /// Construye la sección de información sobre la fecha de caducidad
  /// Muestra la fecha con un color de fondo según su estado
  /// @param [context] Contexto de construcción
  /// @return [Widget] con la información de caducidad
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: expiryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    formatDate(widget.producto.expirationdate),
                    style: TextStyle(
                      color:
                          expiryColor == Colors.red
                              ? Colors.white
                              : Colors.black,
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

  /// Construye la sección de información sobre el stock
  /// Muestra el stock actual y el stock mínimo
  /// @param [context] Contexto de construcción
  /// @return [Widget] con la información de stock
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // Mostrar el stock mínimo solo si hay una alarma específica para esta ubicación
            FutureBuilder<int?>(  
              future: _getStockMinimo(widget.producto.id),
              builder: (context, snapshot) {
                return Row(
                  children: [
                    const Text(
                      'Stock Mínimo:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    else if (snapshot.hasData && snapshot.data != null)
                      Text(
                        snapshot.data.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    else if (widget.producto.minStock != null)
                      Text(
                        widget.producto.minStock.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    else
                      const Text(
                        'No hay stock mínimo asignado',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                );
              },
            ),  
          ],
        ),
      ),
    );
  }

  /// Construye la sección de información sobre la ubicación
  /// Muestra el almacén y la ubicación específica del producto
  /// @param [context] Contexto de construcción
  /// @return [Widget] con la información de ubicación
  Widget _buildLocationInfo(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Localización',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Almacén:', '${widget.almacenName}'),
            _buildInfoRow('Ubicación:', '${widget.location?.name}'),
          ],
        ),
      ),
    );
  }

  /// Construye una fila de información con etiqueta y valor
  /// Utilizado para mostrar datos en formato clave-valor
  /// @param [label] Etiqueta o nombre del campo
  /// @param [value] Valor del campo
  /// @return [Widget] con la fila de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
