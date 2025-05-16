import 'package:flutter/material.dart';
import 'package:quilmedic/utils/alarm_utils.dart';

/// Widget que muestra el nivel de stock de un producto
/// Presenta el stock actual y, si está disponible, el stock mínimo configurado
/// en las alarmas del producto, en formato "actual/mínimo".

class ProductStockBadge extends StatefulWidget {
  /// Nivel de stock actual del producto
  final int stock;
  /// Indica si se debe usar un tamaño más compacto para pantallas pequeñas
  final bool isSmallScreen;
  /// Utilidad para acceder a las alarmas configuradas
  final AlarmUtils alarmUtils;
  /// ID del producto para buscar alarmas específicas
  final int productId;
  /// ID de la ubicación para filtrar alarmas por ubicación
  final int locationId;
  
  /// Constructor del widget ProductStockBadge
  const ProductStockBadge({
    super.key,
    required this.stock,
    this.isSmallScreen = false,
    required this.alarmUtils,
    required this.productId,
    required this.locationId,
  });

  @override
  State<ProductStockBadge> createState() => _ProductStockBadgeState();
}

/// Estado interno del widget ProductStockBadge
class _ProductStockBadgeState extends State<ProductStockBadge> {
  /// Stock mínimo configurado para el producto (null si no está configurado)
  int? stockMinimo;
  /// Indica si se está cargando la información de stock mínimo
  bool isLoading = true;
  
  /// Inicializa el estado y carga el stock mínimo configurado
  @override
  void initState() {
    super.initState();
    _loadStockMinimo();
  }
  
  /// Carga el stock mínimo configurado para el producto desde las alarmas
  /// Busca primero alarmas específicas para el producto y luego alarmas generales
  Future<void> _loadStockMinimo() async {
    try {
      // Verificar si hay alarmas específicas para este producto
      final hasSpecific = await widget.alarmUtils.hasSpecificAlarms(widget.productId);
      
      if (hasSpecific) {
        // Obtener las alarmas específicas para este producto
        final alarms = await widget.alarmUtils.getSpecificAlarmsForProduct(widget.productId);
        
        // Buscar una alarma de tipo 'stock' para este producto y esta ubicación
        for (var alarm in alarms) {
          if (alarm.type?.toLowerCase() == 'stock' && 
              (alarm.locationId == null || alarm.locationId == widget.locationId)) {
            final condition = alarm.condition;
            if (condition != null && condition.isNotEmpty) {
              final RegExp regExp = RegExp(r'(\D*)(\d+)');
              final Match? match = regExp.firstMatch(condition);

              if (match != null) {
                final value = int.parse(match.group(2)!);
                if (mounted) {
                  setState(() {
                    stockMinimo = value;
                    isLoading = false;
                  });
                }
                return;
              }
            }
          }
        }
      }
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Construye la interfaz del badge de stock
  /// Muestra un indicador de carga mientras se obtiene el stock mínimo
  /// y luego muestra el stock actual y mínimo si está disponible
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSmallScreen ? 4 : 8, 
        vertical: widget.isSmallScreen ? 2 : 4
      ),
      alignment: Alignment.center,
      child: isLoading
        ? const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(
            stockMinimo != null ? '${widget.stock}/$stockMinimo' : '${widget.stock}',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: widget.isSmallScreen ? 11 : null,
            ),
            textAlign: TextAlign.center,
          ),
    );
  }
}
